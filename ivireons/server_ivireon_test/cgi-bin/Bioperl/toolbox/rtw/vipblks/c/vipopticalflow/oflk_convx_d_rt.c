/*
*  OFLK_CONVX_D_RT runtime function for Optical Flow Block
*  (Lucas & Kanade method - Gaussian derivative).
*  Spatial Convolution (along X-direction)
*
*  Copyright 1995-2007 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2007/05/23 19:00:59 $
*/
#include "vipopticalflow_rt.h" 

EXPORT_FCN void MWVIP_OFLK_ConvX_D(const real_T *in, 
                                   real_T *out, 
                                   const real_T *kernel, 
                                   int_T inRows, 
                                   int_T inCols, 
                                   int_T kernelLen)
{
    int_T i, j, k;
    int_T halfKernelLen = kernelLen>>1;/* kernelLen/2 */
    int_T offset = halfKernelLen*inRows;
    for (i = 0; i < inRows; i++)
    {
        for (j = 0; j < inCols; j++)
        {
            int_T outIdx = j*inRows+i;
            out[outIdx] = 0;
            if inRange(i,j,halfKernelLen,inRows,inCols)
            {
                int_T inIdx;
                for (k = 0, inIdx = outIdx-offset; k < kernelLen; k++, inIdx += inRows)
                    out[outIdx] += in[inIdx]*kernel[k]; 
            }
        }
    }
}

/* [EOF] oflk_convx_d_rt.c */
