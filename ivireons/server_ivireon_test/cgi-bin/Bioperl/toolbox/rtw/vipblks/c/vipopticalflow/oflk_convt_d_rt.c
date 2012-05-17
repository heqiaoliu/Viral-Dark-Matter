/*
*  OFLK_CONVT_D_RT runtime function for Optical Flow Block
*  (Lucas & Kanade method - Gaussian derivative).
*  Temporal Convolution
*
*  Copyright 1995-2007 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2007/05/23 19:00:56 $
*/
#include "vipopticalflow_rt.h" 

EXPORT_FCN void MWVIP_OFLK_ConvT_D(const real_T **inPortAddr, 
                                   real_T *out, 
                                   const real_T *kernel, 
                                   int_T inWidth, 
                                   int_T kernelLen)
{
    int_T i, k, prtIdx; 
    int_T highestPrtIdx = kernelLen-1;
    for (i=0; i<inWidth; i++)
    {
        real_T tmpVal = 0.0;

        for (k=0, prtIdx=highestPrtIdx; k<kernelLen; k++, prtIdx--)
        {
            tmpVal += inPortAddr[prtIdx][i]*kernel[k];
        }
        out[i] = tmpVal;
    }
}

/* [EOF] oflk_convt_d_rt.c */
