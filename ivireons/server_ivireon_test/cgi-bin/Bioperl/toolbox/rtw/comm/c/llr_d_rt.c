/*    
 *    File: llr_d_rt.c
 *    Abstract: The file defines function for computing Log-likelihood ratio
 *              for soft-demodulation feature (supported by several blocks)
 *              of Communicatios Blockset. 
 *
 *    Copyright 2006 The MathWorks, Inc.
 *    $Revision: 1.1.6.2 $ $Date: 2009/03/09 19:25:19 $
 */

#include "llr_d_rt.h"

/* Compute double precision LLR */
SPC_DECL void llr_d(const cArray   inputSignal,    /* input signal */
           const int_T    numElements,    /* number of input signal elements */
           const real_T  *noiseVariance,  /* noise variance */
           const int_T    M,              /* M            */
           const int_T    nBits,          /* number of bits in symbol (log2(M)) */
           const cArray   constellation,  /* signal constellation */
           const int32_T *S0,             /* symbols having 0 */
           const int32_T *S1,             /* symbols having 1 */
           real_T        *llr)            /* output values - LLR */
{
    int_T  elementIdx = 0;
    int_T  symbolIdx  = 0;
    int_T  bitIdx     = 0;
    real_T tempS0     = 0.0;
    real_T tempS1     = 0.0;
    real_T expSumS0   = 0.0;
    real_T expSumS1   = 0.0;

    for (elementIdx = 0; elementIdx < numElements; elementIdx++)
    {
        for (bitIdx = 0; bitIdx < nBits; bitIdx++)
        {
            expSumS0 = 0.0;
            expSumS1 = 0.0;

            for (symbolIdx = 0; symbolIdx < M/2; symbolIdx++)
            {
                /* tempS0 = (S0x - X)^2; (S0x, S0y) represet constellation symbols */
                /* with bit 0                         
                 */
                /* cr: precompute (bitIdx*M/2)+symbolIdx */
                tempS0 = (Re(constellation, S0[(bitIdx*M/2)+symbolIdx]) - 
                          Re(inputSignal, elementIdx)) * 
                    (Re(constellation, S0[(bitIdx*M/2)+symbolIdx]) - 
                     Re(inputSignal, elementIdx));

                /* tempS0 = (S0x - X)^2 + (S0y - Y)^2 */
                tempS0 +=  (Im(constellation, S0[(bitIdx*M/2)+symbolIdx]) - 
                            Im(inputSignal, elementIdx)) * 
                    (Im(constellation, S0[(bitIdx*M/2)+symbolIdx]) - 
                     Im(inputSignal, elementIdx));
                
                expSumS0 += exp(-1  * tempS0 / noiseVariance[0]);

                /* tempS1 = (S1x - X)^2; (S1x, S1y) represet constellation symbols */
                /* with bit 1                                                      */
                tempS1 = (Re(constellation, S1[(bitIdx*M/2)+symbolIdx]) - 
                          Re(inputSignal, elementIdx)) * 
                    (Re(constellation, S1[(bitIdx*M/2)+symbolIdx]) - 
                     Re(inputSignal, elementIdx));

                /* tempS1 = (S1x - X)^2 + (S1y - Y)^2 */
                tempS1 +=  (Im(constellation, S1[(bitIdx*M/2)+symbolIdx]) - 
                            Im(inputSignal, elementIdx)) * 
                    (Im(constellation, S1[(bitIdx*M/2)+symbolIdx]) - 
                     Im(inputSignal, elementIdx));
                
                expSumS1 += exp(-1  * tempS1 / noiseVariance[0]);
            }
            llr[(elementIdx * nBits) + bitIdx] = log(expSumS0 / expSumS1);
        }
    } /* end of "for (elementIdx = 0 ..." */
} /* end of llr_d() */

/* [EOF] */
