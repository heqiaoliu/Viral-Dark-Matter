/* Copyright 2010 The MathWorks, Inc. */
/*
* File: mw_ippm.h
* 
* Abstract: the header file for Mathworks IPP library for matrix functions.
*/

#ifndef MW_IPPM_H
#define MW_IPPM_H

#include <ipp.h>
#include "rtwtypes.h"

#ifdef __cplusplus
#define EXTERNC extern "C"
#else
#define EXTERNC
#endif

/* DOT Product */
EXTERNC void mw_ipp_dot_vv_single(real32_T in1[], real32_T in2[], real32_T out[], int32_T length);
EXTERNC void mw_ipp_dot_vv_double(real_T in1[], real_T in2[], real_T out[], int32_T length);
/* Add */
EXTERNC void mw_ipp_add_vv_single(real32_T in1[], real32_T in2[], real32_T out[], int32_T length);
EXTERNC void mw_ipp_add_vv_double(real_T in1[], real_T in2[], real_T out[], int32_T length);
EXTERNC void mw_ipp_add_mm_single(real32_T in1[], int32_T src1Width, int32_T src1Height, real32_T in2[], int32_T src2Width, int32_T src2Height, real32_T out[]);
EXTERNC void mw_ipp_add_mm_double(real_T in1[], int32_T src1Width, int32_T src1Height, real_T in2[], int32_T src2Width, int32_T src2Height, real_T out[]);
/* Sub */
EXTERNC void mw_ipp_sub_vv_single(real32_T in1[], real32_T in2[], real32_T out[], int32_T length);
EXTERNC void mw_ipp_sub_vv_double(real_T in1[], real_T in2[], real_T out[], int32_T length);
EXTERNC void mw_ipp_sub_mm_single(real32_T in1[], int32_T src1Width, int32_T src1Height, real32_T in2[], int32_T src2Width, int32_T src2Height, real32_T out[]);
EXTERNC void mw_ipp_sub_mm_double(real_T in1[], int32_T src1Width, int32_T src1Height, real_T in2[], int32_T src2Width, int32_T src2Height, real_T out[]);
/* Mul */
EXTERNC void mw_ipp_mpy_mm_single(real32_T in1[], int32_T src1Width, int32_T src1Height, real32_T in2[], int32_T src2Width, int32_T src2Height, real32_T out[]);                                     
EXTERNC void mw_ipp_mpy_mm_double(real_T in1[], int32_T src1Width, int32_T src1Height, real_T in2[], int32_T src2Width, int32_T src2Height, real_T out[]);
/* Transpose */
EXTERNC void mw_ipp_transp_single(real32_T in1[], int32_T width, int32_T height, real32_T out[]);
EXTERNC void mw_ipp_transp_double(real_T in1[], int32_T width, int32_T height, real_T out[]);
                                                                   
#undef EXTERNC

#endif

/* LocalWords:  IPP Mul
 */
