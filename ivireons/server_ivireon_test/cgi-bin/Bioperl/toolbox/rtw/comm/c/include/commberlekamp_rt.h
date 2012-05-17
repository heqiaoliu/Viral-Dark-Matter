/*
 * File:  commberlekamp_rt.h
 *
 * Header file for the Berlekamp decoding algorithm code.
  
 * Copyright 2007 The MathWorks, Inc.
 * $Revision: 1.1.6.3 $ $Date: 2009/03/09 19:25:34 $
 */

#ifndef _COMMBERLEKAMP_RT_
#define _COMMBERLEKAMP_RT_

#ifdef __cplusplus
extern "C" {
#endif

#include <math.h>
#include "gf_math.h"

/*===============================================================================

 * MWCOMM_DOBERLEKAMP  Shared function to perform Berlekamp-Massey decoding for
 * the Comms Toolbox and the Comms Blockset.  The function uses the algorithm
 * described in Clark and Cain, Error-Correction Coding for Digital Communications,
 * 1981.
 *
 * Parameters:
 *    n            - codeword length; 3<=n<=65535
 *    k            - message length; 1<=k<=65533
 *    m            - exponent of the extentsion field 
 *                   (e.g. a (255,k) code has an m of 8); 3<=m<=16
 *    t            - error-correcting capability of the code 
 *                   (for RS codes, t=(n-k)/2); t>=1
 *    b            - exponent of the lowest power monomial of the generator 
 *                   polynomial.  For narrow-sense codes, b=1. b>=0
 *    shortened    - number of bits by which the code is shortened; 0<=shortened<=k-1
 *   *punctVec     - puncture vector; 1=not punctured, 0=punctured; Size is (n-k, 1).
 *    numPuncs     - number of punctures in a codeword;  0<=numPuncs<=n-k.
 *   *erasPuncVec  - composite erasure vector, including punctures.  Size is (inWidth, 1).
 *    showNumErr   - flag to indicate whether the # of errors is output; showNumErr is binary
 *    numWords     - number of codewords to be decoded; numWords = inWidth/n
 *   *table1       - pointer to a first table for speeding up GF ops.
 *                   Size is (pow(2,m)-1, 1).
 *   *table2       - pointer to a second table for speeding up GF ops.
 *                   Size is (pow(2,m)-1, 1).
 *   *Syndrome     - Syndrome polynomial, found by evaluating the codeword at the 
 *                   2t zeros of the generator polynomial.  Size is (2*t, 1).
 *   *GammaZ       - erasure locator polynomial.  Size is (2*t+1, 1).
 *   *GammaZTemp   - temp vector to be convolved with GammaZ.  Size is (2, 1).
 *   *PsiZ         - error/erasure locator polynomial.  Size is (2*t+1, 1).
 *   *PsiZStar     - temp value for PsiZ.  Size is (2*t+1, 1).
 *   *Dz           - correction polynomial.  Size is (2*t+1, 1).
 *   *Errloc       - error locations.  Size is (t, 1).
 *   *OmegaZ       - error magnitude polynomial.  Size is (3*t+1, 1).
 *   *OmegaZActual - actual error magnitude polynomial.  Size is (2*t+1, 1).
 *   *TempVec2t1   - temporary vector of size (2*t+1, 1).
 *   *CCode        - corrected code.  Size is ((n+shortened) * #codewords, 1).
 *   *PsiZDeriv    - derivative of PsiZ.  Size is (t, 1).
 *   *d            - temporary vector used with gf_roots.  Size is (t+1, 1).
 *   *tmp          - temp vector of size (t+1, 1).
 *   *tmpQuotient  - temp vector of size (t+1, 1).
 *   *input        - input codeword(s)
 *   *erasures     - erasure vector
 *   *outMsg       - output message word(s)
 *   *outCNumErr   - number of errors corrected
 *   *outCorrCode  - corrected codeword(s)
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
                              int32_T   *outCorrCode);

#ifdef __cplusplus
} // end of extern "C" scope
#endif

#endif  /* _COMMBERLEKAMP_RT_ */

/* [EOF] */
