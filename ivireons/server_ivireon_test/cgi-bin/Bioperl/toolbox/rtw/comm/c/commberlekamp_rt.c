/*
 * File:  commberlekamp_rt.c
 * Abstract:  The file defines functions for performing the Berlekamp algorithm
 *            to decode BCH and RS codes.  The algorithm is primarily taken from 
 *            Figure 5-8 on page 206 of Clark and Cain.
 *
 *  Copyright 2006-2007 The MathWorks, Inc.
 *  $Revision: 1.1.6.4 $  $Date: 2009/03/09 19:25:13 $
 */

#include "commberlekamp_rt.h"

/*================================================================================
 * ASSIGNINPUTS -- Populate the codeword and erasure vectors with the proper data
 *
 * args:
 *   CCode        - corrected code
 *   erasPuncVec  - combined erasures and puncture vector
 *   numErasPuncs - number of erasures and punctures
 *   input        - input to the decoder
 *   shortened    - length by which a codeword is shortened
 *   k            - message word length
 *   n            - codeword length (including punctures)
 *   currWordIdx  - index of the current word of (possibly) many
 *   numPuncs     - number of punctures per codeword
 *   punctVec     - puncture vector
 *   erasures     - erasure vector
 *   numParity    - number of parity symbols (n-k)
 */

static void assignInputs(      int32_T   *CCode,
                               boolean_T *erasPuncVec,
                               int32_T   *numErasPuncs,
                               int32_T   *input,
                         const int32_T    shortened,
                         const int32_T    k,
                         const int32_T    n,
                               int32_T    currWordIdx,
                         const int32_T    numPuncs,
                         const boolean_T *punctVec,
                               boolean_T *erasures,
                         const int32_T    numParity)

{
    int32_T i;

    /* Prepend current input word with zeros to form CCode. */
    for (i=0; i<shortened; i++) {
        CCode[i] = 0;
    }

    /* Assign message symbols.  If there are erasures, insert zeros in
     * the erased positions. */
    for (i=shortened; i<shortened+k; i++) {
        int_T inIdx = currWordIdx*(n-numPuncs) + i - shortened;
        if (erasures[inIdx]) {
            CCode[i] = 0;
            erasPuncVec[i-shortened] = 1;
            (*numErasPuncs)++;
        } else {
            CCode[i] = input[inIdx];
            erasPuncVec[i-shortened] = 0;
        }
    }

    /* Assign parity symbols, again accounting for erasures.  For punctured codewords, 
     * insert zeros in the punctured positions. */
    if (numPuncs>0) {
        int_T inIdx  = (currWordIdx*(n-numPuncs)) + k;
        int_T outIdx = shortened + k;
        int_T puncIdx;
        for (puncIdx=0; puncIdx<numParity; puncIdx++) {
            if (punctVec[puncIdx] == 1) {
                if (erasures[inIdx]) {
                    CCode[outIdx] = 0;
                    erasPuncVec[outIdx-shortened] = 1;
                    (*numErasPuncs)++;
                } else {
                    CCode[outIdx] = input[inIdx];
                    erasPuncVec[outIdx-shortened] = 0;
                }
                inIdx++;
            } else {  /* punctVec[puncIdx] == 0 */
                CCode[outIdx] = 0;
                erasPuncVec[outIdx-shortened] = 1;
                (*numErasPuncs)++;
            }
            outIdx++;
        }

    } else {  /* no puncturing */

        /* Initialize latter part of current word in CCode to input word.  Again,
         * if there are erasures, insert zeros in the punctured positions. */
        for(i=k+shortened; i<n+shortened; i++) {
            int_T inIdx = currWordIdx*n+i-shortened;
            if (erasures[inIdx]) {
                CCode[i] = 0;
                erasPuncVec[i-shortened] = 1;
                (*numErasPuncs)++;
            } else {
                CCode[i] = input[inIdx];
                erasPuncVec[i-shortened] = 0;
            }
        }
    }
}


/*==============================================================================
 * CALCULATEGAMMAZ -- Calculate the erasure locator polynomial
 *
 * args:
 *   GammaZTemp  - temporary (degree one) erasure locator polynomial
 *   GammaZ      - final erasure locaator polynomial
 *   degGammaZ   - degree of GammaZ
 *   n           - codeword length
 *   erasPuncVec - combined erasure/puncture vector
 *   m           - exponent of extension GF field
 *   table1      - table for faster GF ops
 *   table2      - ditto
 *   t2PlusOne   - 2*t+1
 *   TempVec2t1  - work vector
 */

static void calculateGammaZ(      int32_T   *GammaZTemp,
                                  int32_T   *GammaZ,
                                  int32_T   *degGammaZ,
                            const int32_T    n,
                                  boolean_T *erasPuncVec,
                            const int32_T    m,
                            const int32_T   *table1,
                            const int32_T   *table2,
                            const int32_T    t2PlusOne,
                                  int32_T   *TempVec2t1)
{
    int32_T i, j;
    GammaZTemp[0] = 1;
    *degGammaZ = 0;
    for (i=n-1; i>-1; i--) {
            
        if (erasPuncVec[i]) {

            /* Raise alpha (2) to the erasure power, and put it in GammaZTemp[1] */
            GammaZTemp[1] = gf_pow(2, n-1-i, m, table1, table2);

            /* Convolve GammaZ with GammaZTemp */
            for (j=0; j<t2PlusOne; j++) {
                TempVec2t1[j] = GammaZ[j];
            }
            gf_conv(GammaZ, GammaZTemp, TempVec2t1, 2, (*degGammaZ)+1, m, table1, table2);
            (*degGammaZ)++;
            for (j=0; j<t2PlusOne; j++) {
            }
        }
    }
}


/*==============================================================================
 * CALCULATEPSIZ -- Calculate the error/erasure locator polynomial PsiZ
 *
 * args:
 *   PsiZ         - error/erasure locator polynomial
 *   numerasPuncs - number of combined erasures and punctures
 *   t2PlusOne    - 2*t+1
 *   GammaZ       - erasure locator polynomial
 *   t2           - 2*t
 *   Syndrome     - vector of codewords evaluated at successive powers of alpha
 *   m            - exponent of extension GF field
 *   table1       - table to speed up GF ops
 *   table2       - ditto
 *   TempVec2t1   - work vector
 *   PsiZStar     - temporary value of PsiZ
 */

static void calculatePsiZ(      int32_T *PsiZ,
                                int32_T *L,
                          const int32_T  numErasPuncs,
                          const int32_T  t2PlusOne,
                                int32_T *GammaZ,
                                int32_T *Dz,
                          const int32_T  t2,
                                int32_T *Syndrome,
                          const int32_T  m,
                          const int32_T *table1,
                          const int32_T *table2,
                                int32_T *TempVec2t1,
                                int32_T *PsiZStar)
{
    int32_T i, Temp3;

    /* Length of linear feedback shift register (LFSR) */
    int32_T Lstar;

    /* Use the diagram in Fig. 5-8 of Clark and Cain to implement the algorithm.
     * Box 1 -- Initializations */

    /* Iterator variables in Clark and Cain's version of the Berlekamp algorithm.
     * kCC is the location of the oldest symbol in the LFSR at the point where the
     * register fails.
     */
    int32_T nCC;
    int32_T kCC = -1;

    /* discrep is the convolution of PsiZ and the syndrome */
    int32_T discrep = 0;

    /* L is the length of the linear feedback shift register (LFSR) */
    *L = numErasPuncs;

    /* Connection polynomial = 1.  ASCENDING order.  deg(PsiZ) = 2*t.
     * To account for erasures, PsiZ = LambdaZ * GammaZ, where LambdaZ is the 
     * error locator polynomial, and GammaZ is the erasure locator polynomial.
     * NOTE:  PsiZ is the coefficients of the connection polynomial in order of
     *        ASCENDING powers rather than the conventional descending order.
     *        This is such that after the set of iterations, the inverse of
     *        roots of PsiZ in descending order can be obtained directly by
     *        finding the roots of PsiZ in ascending order.  PsiZ is
     *        initialized as GammaZ in case there are erasures.
     */

    /* Initialize Psi(Z) = Gamma(Z) : ASCENDING ORDER.  length = 2t+1 */
    for (i=0; i<t2PlusOne; i++) {
        PsiZ[i] = GammaZ[i];
    }

    /* Initialize correction polynomial D(z) = z*GammaZ : ASCENDING ORDER.  
     * length = 2t+2 */
    Dz[0] = 0;
    for (i=1; i<t2+2; i++) {
        Dz[i] = GammaZ[i-1];
    }

    /* 2*t-numErasPuncs iterations (Diamond 3) */
    for (nCC=numErasPuncs; nCC<t2; nCC++) {

        /* Box 2 -- Calculate the discrepancy, which is the sum over i of 
         * PsiZ(i)*Syndrome(n-i) with i going from 0 to L */
        Temp3 = 0;   /* Initialize sum */
        for (i=0; i<(*L)+1; i++) {

            if ((nCC-i) >= 0) {   /* such that syndrome position is valid */

                /* Multiply the current Psi coefficient by the 
                 * (nCC-L)'th syndrome value.  Then update sum. */
                Temp3 = Temp3 ^ (gf_mul(PsiZ[i], Syndrome[nCC-i], m, table1, table2));

            }
        } /* end of sum of PsiZ(i)*Syndrome(n-i) */
        discrep = Temp3;

        /* Diamond 1 -- Continue if the discrepancy is not equal to zero */
        if (discrep) {

            /* Box 3 -- Connection polynomial
             *          PsiZ(n) = PsiZ(n-1) - discrep(n)*Dz
             */
            for (i=0; i<t2PlusOne; i++) {
                TempVec2t1[i] = discrep;
            }

            for (i=0; i<t2; i++) {
                PsiZStar[i] = PsiZ[i] ^ (gf_mul((int)TempVec2t1[i], (int)Dz[i], m, table1, table2));
            }

            /* Diamond 2 */
            if (*L < nCC-kCC) {

                /* Boxes 4-7 -- Correction polynomial
                 *              Dz = PsiZ(n-1) / discrep(n)
                 */
                Lstar = nCC - kCC;
                kCC = nCC - *L;
                for (i=0; i<t2PlusOne; i++) {
                    Dz[i] = gf_div(PsiZ[i], TempVec2t1[i], m, table1, table2);
                }
                *L = Lstar;
            }

            /* Box 8 -- Reset the error/erasure locator polynomial */
            for (i=0; i<t2PlusOne; i++) {
                PsiZ[i] = PsiZStar[i];
            }

        }  /* end of if (discrep) */
                        

        /* Box 9 -- Correction polynomial
         *          Dz = z * Dz 
         */
        for (i=t2; i>0; i--) {
            Dz[i] = Dz[i-1];
        }
        Dz[0] = 0;

    }/* end of 2*t iterations */
}


/*==============================================================================
 * CORRECTERRORS -- Calculate the error magnitude in the current error position,
 *                  and correct the errors.
 *
 * args:
 *   OmegaZ       - error magnitude polynomial
 *   PsiZ         - error/erasure locator polynomial
 *   Syndrome     - vector of codewords evaluated at successive powers of alpha
 *   t            - error correcting capability
 *   t2PlusOne    - 2*t+1
 *   t2           - 2*t
 *   m            - power of extension field
 *   table1       - table to speed up GF ops
 *   table2       - ditto
 *   OmegaZActual - truncated error magnitude polynomial
 *   PsiZDeriv    - formal derivative of error/erasure locator polynomial PsiZ
 *   cnumerr      - number of errors corrected
 *   b            - initial power of alpha for the generator polynomial
 *   Errloc       - vector of error/erasure locations
 *   nfull        - full codeword length
 *   CCode        - corrected code
 */

static void correctErrors(      int32_T *OmegaZ,
                                int32_T *PsiZ,
                                int32_T *Syndrome,
                          const int32_T  t2PlusOne,
                          const int32_T  t2,
                          const int32_T  m,
                          const int32_T *table1,
                          const int32_T *table2,
                                int32_T *OmegaZActual,
                                int32_T *PsiZDeriv,
                                int32_T  cnumerr,
                                int32_T  b,
                                int32_T *Errloc,
                                int32_T  nfull,
                                int32_T *CCode)
{
    int32_T i, j;
    int32_T Temp1 = 0;
    int32_T Temp2 = 0;
    int32_T Temp3 = 0;
    int32_T Temp4 = 0;
    int32_T Apower;   /* exponent to raise a gf scalar by */

    /* Initialize error magnitude polynomial OmegaZ for each word */
    for (i=0; i<2*t2PlusOne; i++) {   
        OmegaZ[i]=0;
    } 

    gf_conv(OmegaZ, PsiZ, Syndrome, t2PlusOne, t2, m, table1, table2);


    /* Disregard terms of x^(2t) and higher in Omega(Z)
     * because we have no knowledge of such terms in S(Z). 
     * That is, retain terms up to x^(2t-1)
     */
    for (i=0; i<t2; i++) {
        OmegaZActual[i] = OmegaZ[i];
    }

    /* Compute derivative of PsiZ */
    for (i=0; i<t2; i+=2) {
        PsiZDeriv[i]   = PsiZ[i+1];
        PsiZDeriv[i+1] = 0;
    }

    /* Find error magnitude at each error location.  Use the expression found
     * on pg. 222 of Wicker.  */
    for (j=0; j<cnumerr; j++) {

        /* Dot product for numerator term */
        Temp3 = 0;   /* Initialize temp sum */

        for (i=0; i<t2; i++) {
            Apower = 1-b-i;
            Temp1 = gf_pow(Errloc[j], Apower, m, table1, table2);

            Temp2 = OmegaZActual[i];
            if (Temp2>0) {
                Temp3 = Temp3 ^ (gf_mul(Temp2, Temp1, m, table1, table2));
            }
        }

        /* Dot product for denominator */
        Temp4 = 0;   /* Initialize temp sum */
        for (i=0; i<t2; i++) {
            Temp1 = gf_pow(Errloc[j], -i, m, table1, table2);

            Temp2 = PsiZDeriv[i];
            if (Temp2>0) {
                Temp4 = (int)Temp4 ^ (int)(gf_mul(Temp2, Temp1, m, table1, table2));
            }
        }

        /* Re-use space in Temp1 */
        Temp1 = gf_div(Temp3, Temp4, m, table1, table2);
        Temp2 = Errloc[j];

        /* Find exponent representations of Errloc ==> get actual error locations */
        Temp2 = table2[Temp2-1];

        /* Correct the current error */
        CCode[nfull-1-((int_T)Temp2)] = CCode[nfull-1-((int_T)Temp2)] ^ Temp1;

    }/* end each error location */

}
                        
/*==============================================================================
 * ASSIGNOUTPUTS -- Populate output vectors with proper data
 *
 * inputs:
 *   n           - codeword length
 *   k           - message length
 *   currWordIdx - index of the current word of (possibly) many
 *   input       - decoder input (needed for decoder failures)
 *   CCode       - corrected codeword
 *   cnumerr     - number of errors corrected
 *   shortened   - length by which a codeword is shortened
 *   punctVec    - puncture vector
 *   numPuncs    - number of punctures
 *   showNumErr  - flag to indicate whether the # of errors should be output
 *   outMsg      - corrected message
 *   outCNumErr  - number of errors corrected
 *   outCorrCode - corrected code
 */

static void assignOutputs(const int32_T    n,
                          const int32_T    k,
                                int32_T    currWordIdx,
                                int32_T   *input,
                                int32_T   *CCode,
                                int32_T    cnumerr,
                          const int32_T    shortened,
                          const boolean_T *punctVec,
                          const int32_T    numPuncs,
                          const boolean_T  showNumErr,
                                int32_T   *outMsg,
                                int32_T   *outCNumErr,
                                int32_T   *outCorrCode)
{
    int i;
    int_T bitIdx  = currWordIdx*(n-numPuncs) + k;
    int_T puncIdx = 0;
    int_T outIdx  = 0;
    
    /* Corrected message.  If there is a decoding failure, return the
     * input message. */
    for (i=0; i<k; i++) {
        int_T inIdx  = i+shortened;
        int_T outMsgIdx = currWordIdx*k + i;
        int_T outCodeIdx = currWordIdx*(n-numPuncs) + i;
        outMsg[outMsgIdx]       = cnumerr!=(int32_T)(-1) ? CCode[inIdx] : input[outCodeIdx];
        outCorrCode[outCodeIdx] = CCode[inIdx];  /* for Toolbox */
    }

    /* Optional output for # of errors corrected */
    if (showNumErr) {
        outCNumErr[currWordIdx] = cnumerr;
    }

    /* Parity of corrected codeword.  If it is punctured, remove the punctured 
     * symbols. If there is a decoding failure, return the input parity. */
    for (i=k+shortened; i<n+shortened; i++) {
        if (punctVec[puncIdx]) {
            outCorrCode[bitIdx + outIdx] = cnumerr!=(int32_T)(-1) ? CCode[i] : input[bitIdx + outIdx];
            outIdx++;
        }
        puncIdx++;
    }
}

/*===============================================================================

 * MWCOMM_DOBERLEKAMP  For a description of the function and its arguments, see
 * commberlekamp_rt.h.
 */
 
SPC_DECL void MWCOMM_DoBerlekamp(const int32_T    n,             
                        const int32_T    k,             
                        const int32_T    m,            
                        const int32_T    t,            
                        const int32_T    b,            
                        const int32_T    shortened,
                        const boolean_T *punctVec,
                        const int32_T    numPuncs,
                              boolean_T *erasPuncVec,
                        const boolean_T  showNumErr,   
                        const int32_T    numWords,
                        const int32_T   *table1,       
                        const int32_T   *table2,
                              int32_T   *Syndrome,
                              int32_T   *GammaZ,
                              int32_T   *GammaZTemp,
                              int32_T   *PsiZ,
                              int32_T   *PsiZStar,
                              int32_T   *Dz,
                              int32_T   *Errloc,
                              int32_T   *OmegaZ,       
                              int32_T   *OmegaZActual,
                              int32_T   *TempVec2t1,
                              int32_T   *CCode,
                              int32_T   *PsiZDeriv,                       
                              int32_T   *d,
                              int32_T   *tmp,
                              int32_T   *tmpQuotient, 
                              int32_T   *input,
                              boolean_T *erasures,        
                              int32_T   *outMsg,         
                              int32_T   *outCNumErr,
                              int32_T   *outCorrCode)         

{
    int32_T cnumerr;           /* number of corrected errors */
    int32_T i,j;
    int32_T numErasPuncs;      /* number of combined erasures and punctures */
    int32_T degPsiZ;           /* degree of PsiZ polynomial */
    int32_T degGammaZ;         /* degree of GammaZ polynomial */

    const int32_T t2        = 2*t;  /* t2 parity bits in a standard RS code */
    const int32_T t2PlusOne = t2+1;

    /* Other codeword parameters */
    int32_T nfull     = n+shortened;
    int32_T numParity = n-k;

    /* Flag to indicate no error detected */
    int32_T noErrorStatus = 1;
    
    /* Length of linear feedback shift register (LFSR) */
    int32_T L;

    int32_T Temp2 = 0;
    int32_T Temp3 = 0;

    int32_T currWordIdx; /* iterator over multiple codewords */

    
    /* PART I - ERROR LOCATOR POLYNOMIAL COMPUTATION */

    /* Compute syndrome series : length = 2*t */

    for (currWordIdx=0; currWordIdx<numWords; currWordIdx++) {

        /* Reset for each word */
        noErrorStatus = 1;
        numErasPuncs  = 0;
        for (i=0; i<n; i++) {
            erasPuncVec[i] = 0;
        }

        assignInputs( CCode, 
                      erasPuncVec,
                     &numErasPuncs,
                      input, 
                      shortened,
                      k,
                      n,
                      currWordIdx,
                      numPuncs,
                      punctVec,
                      erasures,
                      numParity);
 

        /* Initialize Gamma(Z) = 1 : ASCENDING ORDER.  length = 2t+1 */
        GammaZ[0] = 1;
        for(i=1; i<t2PlusOne; i++) {
            GammaZ[i] = 0;
        }

        /* Calculate the erasure polynomial GammaZ.  GammaZ is the set of coefficients
         * of the erasure polynomial in ASCENDING order, because the syndrome is 
         * calculated in ascending order as well.
         */
        calculateGammaZ( GammaZTemp,
                         GammaZ,
                        &degGammaZ,
                         n,
                         erasPuncVec,
                         m,
                         table1,
                         table2,
                         t2PlusOne,
                         TempVec2t1);


        /* Calculate the syndrome by evaluating the codeword at successive
         * powers of alpha.  The syndrome is in ASCENDING order. */
        for (i=0; i<t2; i++) {
            Temp3 = 0;       /* temp storage for sum */
            for (j=nfull-1; j>-1; j--) {

                /* alpha */
                Temp2 = gf_pow(2, ((b+i)*j), m, table1, table2);
       
                /* CCode[nfull-1-j] is the current input code symbol.  Multiply
                 * it by alpha, then get the sum so far */
                Temp3 = Temp3 ^ (gf_mul(CCode[nfull-1-j], Temp2, m, table1, table2));
            }
            Syndrome[i] = Temp3;

            if (noErrorStatus && Syndrome[i]) {
                noErrorStatus = 0;
            }
        }/* end of Syndrome calculation */

        /* Stop if all syndromes == 0 (i.e. input word is already a valid BCH/RS codeword) */
        if (noErrorStatus) {
            cnumerr = 0;

            assignOutputs(n, k, currWordIdx, input, CCode, cnumerr, shortened, 
                          punctVec, numPuncs, showNumErr, outMsg, outCNumErr,
                          outCorrCode);

        } else {

            /* Calclate the error/erasure locator polynomial PsiZ */
            calculatePsiZ( PsiZ,
                          &L,
                           numErasPuncs,
                           t2PlusOne,
                           GammaZ,
                           Dz,
                           t2,
                           Syndrome,
                           m,
                           table1,
                           table2,
                           TempVec2t1,
                           PsiZStar);


            /* FIND ERROR LOCATIONS */

            /* At this point, error/erasure locator polynomial has been found, 
             * which is PsiZ */
            
            /* Find degree of Psi(Z) */
            degPsiZ = 0;
            for (i=t2; i>-1; i--) {
                if (PsiZ[i]>0) {
                    degPsiZ = i;
                    break;
                }
            }

            /* Degree of Psi(Z) must be equal to L and larger than 0
             * (i.e. cannot be a constant) */
            if (degPsiZ!=L || degPsiZ<1) {
                cnumerr = -1;  /* Decoding failure */

                assignOutputs(n, k, currWordIdx, input, CCode, cnumerr,
                              shortened, punctVec, numPuncs, showNumErr,
                              outMsg, outCNumErr, outCorrCode);

            } else {

                /* Initialize contents at pointer Errloc */
                for (i=0; i<t2; i++) {
                    Errloc[i]=0;
                }

                /* Integer values.  Need to change to power form to get error locations, 
                 * then get the number of roots */
                cnumerr = gf_roots(Errloc, PsiZ, d, tmp, tmpQuotient, t2PlusOne, m, table1, table2);

                /* Decoding failure if one of the following conditions is met:
                 * (1) Psi(Z) has no roots in this field
                 * (2) Number of roots not equal to degree of PsiZ
                 */
                if (cnumerr != degPsiZ) {
                    cnumerr = -1;

                    assignOutputs(n, k, currWordIdx, input, CCode, cnumerr,
                                  shortened, punctVec, numPuncs, showNumErr,
                                  outMsg, outCNumErr, outCorrCode);

                } else {

                    /* Test if the error locations are unique */
                    int_T isunique = 1;
                    for (i=0; (i<cnumerr-1 && isunique); i++) {
                        for (j=i+1; (j<cnumerr && isunique); j++) {
                            if (Errloc[i]==Errloc[j]) {
                                isunique = 0;
                            }
                        }
                    }

                    if (!isunique) {
                        cnumerr = -1;
 
                        assignOutputs(n, k, currWordIdx, input, CCode, cnumerr,
                                      shortened, punctVec, numPuncs, showNumErr,
                                      outMsg, outCNumErr, outCorrCode);

                    } else {

                        /* PART II - FIND ERROR MAGNITUDES AT EACH OF THE ERROR/ERASURE LOCATIONS,
                         * AND CORRECT THEM */

                        correctErrors(OmegaZ,
                                      PsiZ,
                                      Syndrome,
                                      t2PlusOne,
                                      t2,
                                      m,
                                      table1,
                                      table2,
                                      OmegaZActual,
                                      PsiZDeriv,
                                      cnumerr,
                                      b,
                                      Errloc,
                                      nfull,
                                      CCode);

                        /* Assign outputs.  Reduce cnumerr by the number of punctures and erasures. */
                        cnumerr -= numErasPuncs;
                        assignOutputs(n, k, currWordIdx, input, CCode, cnumerr,
                                      shortened, punctVec, numPuncs, showNumErr,
                                      outMsg, outCNumErr, outCorrCode);

                    }/* end if(!unique) */

                }/* end if(cnumerr!=degPsiZ) */

            }/* end if(degPsiZ>t || degPsiZ<1) */

        }/* end if(noerrorStatus) */

    }/* end each word */

}/* end of MWCOMM_DoBerlekamp */

/* [EOF] */
