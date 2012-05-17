/*    
 *    File: llr_r_rt.c
 *    Abstract: The file defines function for computing Log-likelihood ratio
 *              for soft-demodulation feature (supported by several blocks)
 *              of Communicatios Blockset. 
 *
 *    Copyright 2006 The MathWorks, Inc.
 *    $Revision: 1.1.6.2 $ $Date: 2009/03/09 19:25:20 $
 */

#include "llr_r_rt.h"

/* Compute single precision LLR */
SPC_DECL void llr_r(const cArray32  inputSignal,    /* input signal */
           const int_T     numElements,    /* number of input signal elements */
           const real32_T *noiseVariance,  /* noise variance */
           const int_T     M,              /* M            */
           const int_T     nBits,          /* number of bits in symbol (log2(M)) */
           const cArray32  constellation,  /* signal constellation */
           const int32_T  *S0,             /* symbols having 0 */
           const int32_T  *S1,             /* symbols having 1 */
           real32_T       *llr)            /* output values - LLR */
{
    int_T    elementIdx = 0;
    int_T    symbolIdx  = 0;
    int_T    bitIdx     = 0;
    real32_T tempS0     = 0.0F;
    real32_T tempS1     = 0.0F;
    real32_T expSumS0   = 0.0F;
    real32_T expSumS1   = 0.0F;

    for (elementIdx = 0; elementIdx < numElements; elementIdx++)
    {
        for (bitIdx = 0; bitIdx < nBits; bitIdx++)
        {
            expSumS0 = 0.0F;
            expSumS1 = 0.0F;

            for (symbolIdx = 0; symbolIdx < M/2; symbolIdx++)
            {
                /* tempS0 = (S0x - X)^2; (S0x, S0y) represet constellation symbols */
                /* with bit 0                                                      */
                tempS0 = (Re(constellation, S0[(bitIdx*M/2)+symbolIdx]) - 
                          Re(inputSignal, elementIdx)) * 
                    (Re(constellation, S0[(bitIdx*M/2)+symbolIdx]) - 
                     Re(inputSignal, elementIdx));

                /* tempS0 = (S0x - X)^2 + (S0y - Y)^2 */
                tempS0 +=  (Im(constellation, S0[(bitIdx*M/2)+symbolIdx]) - 
                            Im(inputSignal, elementIdx)) * 
                    (Im(constellation, S0[(bitIdx*M/2)+symbolIdx]) - 
                     Im(inputSignal, elementIdx));
                
                expSumS0 += expf(-1  * tempS0 / noiseVariance[0]);

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
                
                expSumS1 += expf(-1  * tempS1 / noiseVariance[0]);
            }
            llr[(elementIdx * nBits) + bitIdx] = logf(expSumS0 / expSumS1);
        }
    } /* end of "for (elementIdx = 0 ..." */
} /* end of llr_r() */

/* [EOF] */
