/*
*  OFLK_CONVY_R_RT runtime function for Optical Flow Block
*  (Lucas & Kanade method - Gaussian derivative).
*  Spatial Convolution (along Y-direction)
*
*  Copyright 1995-2007 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2007/05/23 19:01:03 $
*/
#include "vipopticalflow_rt.h" 

EXPORT_FCN void MWVIP_OFLK_ConvY_R(const real32_T *in, 
                                   real32_T *out, 
                                   const real32_T *kernel, 
                                   int_T inRows, 
                                   int_T inCols, 
                                   int_T kernelLen)
{
    int_T i, j, k;
    int_T halfKernelLen = kernelLen>>1; /* kernelLen/2 */
    int_T offset = halfKernelLen;
    for (j = 0; j < inCols; j++)
    {
        int_T firstElem = j*inRows;
        for (i = 0; i < inRows; i++)
        {
            int_T outIdx = firstElem+i;
            out[outIdx] = 0;
            if inRange(i,j,halfKernelLen,inRows,inCols)
            {
                int_T inIdx = outIdx-offset;
                for (k = 0; k < kernelLen; k++)
                    out[outIdx] += in[inIdx+k]*kernel[k]; 
            }
        }
    }
}

/* [EOF] oflk_convy_r_rt.c */
