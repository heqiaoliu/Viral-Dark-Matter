/* Copyright 2009-2010 The MathWorks, Inc. */
/*
* File: mw_ipp.h
* 
* Abstract: the header file for Mathworks IPP library for video/image processing functions.
*/

#ifndef MW_IPP_H
#define MW_IPP_H

#include <ipp.h>
#include "rtwtypes.h"

#ifdef __cplusplus
#define EXTERNC extern "C"
#else
#define EXTERNC
#endif

/* 2D Convolution, single data type */
EXTERNC void mw_ipp_conv2d_single(const real32_T h[], const real32_T u[], real32_T y[],
                          const int32_T hDims[], const int32_T hCenter[],
                          const int32_T uDims[], const int32_T uOrigin[],
                          const int32_T yDims[], const int32_T yOrigin[],
                          int32_T inSStart[], int32_T inSEnd[]);

/* 2D Convolution, double data type */
EXTERNC void mw_ipp_conv2d_double(const real_T h[], const real_T u[], real_T y[],
                          const int32_T hDims[], const int32_T hCenter[],
                          const int32_T uDims[], const int32_T uOrigin[],
                          const int32_T yDims[], const int32_T yOrigin[],
                          int32_T inSStart[], int32_T inSEnd[]);

/* 2D Correlation, single data type */
EXTERNC void mw_ipp_corr2d_single(const real32_T h[], const real32_T u[], real32_T y[],
                          const int32_T hDims[], const int32_T hCenter[],
                          const int32_T uDims[], const int32_T uOrigin[],
                          const int32_T yDims[], const int32_T yOrigin[],
                          int32_T inSStart[], int32_T inSEnd[]);

/* 2D Correlation, double data type */
EXTERNC void mw_ipp_corr2d_double(const real_T h[], const real_T u[], real_T y[],
                          const int32_T hDims[], const int32_T hCenter[],
                          const int32_T uDims[], const int32_T uOrigin[],
                          const int32_T yDims[], const int32_T yOrigin[],
                          int32_T inSStart[], int32_T inSEnd[]);
                                                          
#undef EXTERNC

#endif
