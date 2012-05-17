/* Copyright 2010 The MathWorks, Inc. */
/*
* File: mw_ippm.c
* 
* Abstract: the source file for Mathworks IPP library for matrix functions.
*
*/

#include <stdlib.h>
#include "mw_ipp.h"

void mw_ipp_dot_vv_single(real32_T in1[], real32_T in2[], real32_T out[], int32_T length)
{
    int32_T in1Stride = sizeof(real32_T);
    int32_T in2Stride = sizeof(real32_T);
    ippmDotProduct_vv_32f (in1, in1Stride, in2, in2Stride, out, length);
}

void mw_ipp_dot_vv_double(real_T in1[], real_T in2[], real_T out[], int32_T length)
{
    int32_T in1Stride = sizeof(real_T);
    int32_T in2Stride = sizeof(real_T);
    ippmDotProduct_vv_64f (in1, in1Stride, in2, in2Stride, out, length);
}

void mw_ipp_mpy_mm_double(real_T in1[], int32_T src1Width, int32_T src1Height, 
                             real_T in2[], int32_T src2Width, int32_T src2Height, real_T out[])
{
    int32_T src1Stride2 = src1Height * sizeof(real_T);
    int32_T src1Stride1 = sizeof(real_T);
    int32_T src2Stride2 = src2Height * sizeof(real_T);
    int32_T src2Stride1 = sizeof(real_T);      
    int32_T dstStride2  = src1Height * sizeof(real_T);
    int32_T dstStride1  = sizeof(real_T);

    ippmMul_mm_64f(in1, src1Stride1, src1Stride2, src1Width, src1Height, 
                   in2, src2Stride1, src2Stride2, src2Width, src2Height, 
                   out, dstStride1, dstStride2);
}

void mw_ipp_mpy_mm_single(real32_T in1[], int32_T src1Width, int32_T src1Height, 
                          real32_T in2[], int32_T src2Width, int32_T src2Height, real32_T out[])
{
    int32_T src1Stride2 = src1Height * sizeof(real32_T);
    int32_T src1Stride1 = sizeof(real32_T);
    int32_T src2Stride2 = src2Height * sizeof(real32_T);
    int32_T src2Stride1 = sizeof(real32_T);      
    int32_T dstStride2  = src1Height * sizeof(real32_T);
    int32_T dstStride1  = sizeof(real32_T);

    ippmMul_mm_32f(in1, src1Stride1, src1Stride2, src1Width, src1Height,  
                   in2, src2Stride1, src2Stride2, src2Width, src2Height, 
                   out, dstStride1, dstStride2);
}

void mw_ipp_add_vv_single(real32_T in1[], real32_T in2[], real32_T out[], int32_T length)
{
    int32_T in1Stride = sizeof(real32_T);
    int32_T in2Stride = sizeof(real32_T);
	int32_T dstStride = sizeof(real32_T);
    ippmAdd_vv_32f(in1, in1Stride, in2, in2Stride, out, dstStride, length);
}

void mw_ipp_add_vv_double(real_T in1[], real_T in2[], real_T out[], int32_T length)
{
    int32_T in1Stride = sizeof(real_T);
    int32_T in2Stride = sizeof(real_T);
	int32_T dstStride = sizeof(real_T);
    ippmAdd_vv_64f(in1, in1Stride, in2, in2Stride, out, dstStride, length);
}

void mw_ipp_sub_vv_single(real32_T in1[], real32_T in2[], real32_T out[], int32_T length)
{
    int32_T in1Stride = sizeof(real32_T);
    int32_T in2Stride = sizeof(real32_T);
	int32_T dstStride = sizeof(real32_T);
    ippmSub_vv_32f(in1, in1Stride, in2, in2Stride, out, dstStride, length);
}

void mw_ipp_sub_vv_double(real_T in1[], real_T in2[], real_T out[], int32_T length)
{
    int32_T in1Stride = sizeof(real_T);
    int32_T in2Stride = sizeof(real_T);
	int32_T dstStride = sizeof(real_T);
    ippmSub_vv_64f(in1, in1Stride, in2, in2Stride, out, dstStride, length);
}

void mw_ipp_add_mm_single(real32_T in1[], int32_T src1Width, int32_T src1Height, 
                          real32_T in2[], int32_T src2Width, int32_T src2Height, real32_T out[])
{
    int32_T src1Stride2 = src1Height * sizeof(real32_T);
    int32_T src1Stride1 = sizeof(real32_T);
    int32_T src2Stride2 = src1Height * sizeof(real32_T);
    int32_T src2Stride1 = sizeof(real32_T);      
    int32_T dstStride2  = src1Height * sizeof(real32_T);
    int32_T dstStride1  = sizeof(real32_T);

    ippmAdd_mm_32f(in1, src1Stride1, src1Stride2, 
                   in2, src2Stride1, src2Stride2, 
                   out, dstStride1, dstStride2, 
                   src1Width, src1Height);
}

void mw_ipp_add_mm_double(real_T in1[], int32_T src1Width, int32_T src1Height, 
                          real_T in2[], int32_T src2Width, int32_T src2Height, real_T out[])
{
    int32_T src1Stride2 = src1Height * sizeof(real_T);
    int32_T src1Stride1 = sizeof(real_T);
    int32_T src2Stride2 = src1Height * sizeof(real_T);
    int32_T src2Stride1 = sizeof(real_T);      
    int32_T dstStride2  = src1Height * sizeof(real_T);
    int32_T dstStride1  = sizeof(real_T);

    ippmAdd_mm_64f(in1, src1Stride1, src1Stride2, 
                   in2, src2Stride1, src2Stride2, 
                   out, dstStride1, dstStride2, 
                   src1Width, src1Height);
}

void mw_ipp_sub_mm_single(real32_T in1[], int32_T src1Width, int32_T src1Height, 
                          real32_T in2[], int32_T src2Width, int32_T src2Height, real32_T out[])
{
    int32_T src1Stride2 = src1Height * sizeof(real32_T);
    int32_T src1Stride1 = sizeof(real32_T);
    int32_T src2Stride2 = src1Height * sizeof(real32_T);
    int32_T src2Stride1 = sizeof(real32_T);      
    int32_T dstStride2  = src1Height * sizeof(real32_T);
    int32_T dstStride1  = sizeof(real32_T);

    ippmSub_mm_32f(in1, src1Stride1, src1Stride2, 
                   in2, src2Stride1, src2Stride2, 
                   out, dstStride1, dstStride2, 
                   src1Width, src1Height);
}

void mw_ipp_sub_mm_double(real_T in1[], int32_T src1Width, int32_T src1Height, 
                          real_T in2[], int32_T src2Width, int32_T src2Height, real_T out[])
{
    int32_T src1Stride2 = src1Height * sizeof(real_T);
    int32_T src1Stride1 = sizeof(real_T);
    int32_T src2Stride2 = src1Height * sizeof(real_T);
    int32_T src2Stride1 = sizeof(real_T);      
    int32_T dstStride2  = src1Height * sizeof(real_T);
    int32_T dstStride1  = sizeof(real_T);

    ippmSub_mm_64f(in1, src1Stride1, src1Stride2, 
                   in2, src2Stride1, src2Stride2, 
                   out, dstStride1, dstStride2, 
                   src1Width, src1Height);
}

void mw_ipp_transp_single(real32_T in1[], int32_T width, int32_T height, real32_T out[])
{
    int32_T srcStride2 = height * sizeof(real32_T);
    int32_T srcStride1 = sizeof(real32_T);     
    int32_T dstStride2 = width * sizeof(real32_T);
    int32_T dstStride1 = sizeof(real32_T);

    ippmTranspose_m_32f(in1, srcStride1, srcStride2,
                   width, height, out, dstStride1, dstStride2);
}

void mw_ipp_transp_double(real_T in1[], int32_T width, int32_T height, real_T out[])
{
    int32_T srcStride2 = height * sizeof(real_T);
    int32_T srcStride1 = sizeof(real_T);     
    int32_T dstStride2 = width * sizeof(real_T);
    int32_T dstStride1 = sizeof(real_T);

    ippmTranspose_m_64f(in1, srcStride1, srcStride2,
                  width, height, out, dstStride1, dstStride2);
}
/* LocalWords:  IPP
 */
