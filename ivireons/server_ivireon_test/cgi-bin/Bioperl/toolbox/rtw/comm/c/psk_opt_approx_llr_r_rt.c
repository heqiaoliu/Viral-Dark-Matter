/*    
 *    File: psk_opt_approx_llr_r_rt.c
 *    Abstract: The file defines optimized function for computing Approximate  
 *              log-likelihood ratio for soft-demodulation feature of MPSK
 *              Demodulator Baseband block of Communicatios Blockset for single
 *              data-type.
 *
 *    Copyright 2006-2007 The MathWorks, Inc.
 *    $Revision: 1.1.6.4 $ $Date: 2009/03/09 19:25:24 $
 */

#include "psk_opt_approx_llr_r_rt.h"
#include "comm_roundnear_r.h"

SPC_DECL void psk_opt_approx_llr_r(const cArray32   inputSignal,       /* input signal */
                          const int_T      numElements,       /* number of input signal elements */
                          const real32_T  *noiseVariance,     /* noise variance */
                          const int_T      M,                 /* M            */
                          const int_T      nBits,             /* number of bits in symbol (log2(M)) */
                          const real32_T   normFactor,        /* normalization factor (M/DSP_PI) */
                          const real32_T  *cosInitialPhase,   /* cos of initial phase */
                          const real32_T  *sinInitialPhase,   /* sin of initial phase */
                          const cArray32   constellation,     /* signal constellation */
                          const int32_T   *minIdx0,           /* index of nearest symbol having 0 */
                          const int32_T   *minIdx1,           /* index of nearest symbol having 1 */
                          real32_T        *approxLLR)         /* output values - Approximate LLR */
{
    int_T           bitIdx            = 0;
    int_T           elementIdx        = 0;
    int32_T         indx              = 0;
    int32_T         tmpIndx           = 0;    
    real32_T        minS0             = 0.0F;
    real32_T        minS1             = 0.0F;
    real32_T        derotatedRe       = 0.0F;
    real32_T        derotatedIm       = 0.0F;
    real32_T        angle             = 0.0F;    
    real32_T        tmpVal            = 0.0F;

    for (elementIdx = 0; elementIdx < numElements; elementIdx++)
    {
        /* De-rotate */
        derotatedRe = Re(inputSignal, elementIdx)*cosInitialPhase[0] + 
            Im(inputSignal, elementIdx)*sinInitialPhase[0];
        derotatedIm = Im(inputSignal, elementIdx)*cosInitialPhase[0] - 
            Re(inputSignal, elementIdx)*sinInitialPhase[0];

        /* get angle */
        angle = atan2f(derotatedIm, derotatedRe);
        
        /* convert angle to linear domain; rnd value to get */ 
        /* temporary constellation pts                      */
        tmpVal  = (angle * normFactor) - 0.5F;
        tmpIndx = (int32_T)commROUNDnear_R(tmpVal);
        
        /* move all the negative integers by 2*M */
        tmpIndx = ((tmpIndx < 0) ? (2*M + tmpIndx) : tmpIndx);

        for (bitIdx = 0; bitIdx < nBits; bitIdx++)
        {
            indx = tmpIndx*nBits + bitIdx;
            /* minS0 = (S0x - X)^2; (S0x, S0y) represet constellation symbols */
            /* with bit 0                                                      */
            minS0 = (Re(constellation, minIdx0[indx]) - 
                     Re(inputSignal, elementIdx)) * 
                (Re(constellation, minIdx0[indx]) - 
                 Re(inputSignal, elementIdx));
            
            /* minS0 = (S0x - X)^2 + (S0y - Y)^2 */
            minS0 +=  (Im(constellation, minIdx0[indx]) - 
                       Im(inputSignal, elementIdx)) * 
                (Im(constellation, minIdx0[indx]) - 
                 Im(inputSignal, elementIdx));
            
            /* minS1 = (S1x - X)^2; (S1x, S1y) represet constellation symbols */
            /* with bit 1                                                      */
            minS1 = (Re(constellation, minIdx1[indx]) - 
                     Re(inputSignal, elementIdx)) * 
                (Re(constellation, minIdx1[indx]) - 
                 Re(inputSignal, elementIdx));
            
            /* tempS1 = (S1x - X)^2 + (S1y - Y)^2 */
            minS1 +=  (Im(constellation, minIdx1[indx]) - 
                       Im(inputSignal, elementIdx)) * 
                (Im(constellation, minIdx1[indx]) - 
                 Im(inputSignal, elementIdx));
            
            approxLLR[(elementIdx * nBits) + bitIdx] = -1*(minS0 - minS1)/noiseVariance[0];
        }
    } /* end of "for (elementIdx = 0 ..." */
} /* end of psk_opt_approx_llr_r() */

/* [EOF] */
