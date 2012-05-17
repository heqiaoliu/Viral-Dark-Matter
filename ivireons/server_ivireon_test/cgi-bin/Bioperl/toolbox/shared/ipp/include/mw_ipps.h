/* Copyright 2010 The MathWorks, Inc. */
/*
* File: mw_ipps.h
* 
* Abstract: IPP library function wrappers for signal processing functions.
*/

#ifndef MW_IPPS_H
#define MW_IPPS_H

#include <ipp.h>
#include "rtwtypes.h"

#ifdef __cplusplus
#define EXTERNC extern "C"
#else
#define EXTERNC
#endif

/* 1D Correlation, double data type */
EXTERNC void mw_ipp_corr1d_double(const real_T u1[], const int32_T in1Rows, 
                                  const real_T u2[], const int32_T in2Rows, 
                                  real_T y[]);

/* 1D Correlation, single data type */
EXTERNC void mw_ipp_corr1d_single(const real32_T u1[], const int32_T in1Rows, 
                                  const real32_T u2[], const int32_T in2Rows, 
                                  real32_T y[]);

/* 1D Convolution, double data type */
EXTERNC void mw_ipp_conv1d_double(const real_T u1[], const int32_T in1Rows, 
                                  const real_T u2[], const int32_T in2Rows, 
                                  real_T y[]);

/* 1D Convolution, single data type */
EXTERNC void mw_ipp_conv1d_single(const real32_T u1[], const int32_T in1Rows, 
                                  const real32_T u2[], const int32_T in2Rows, 
                                  real32_T y[]);
                                                                   
#undef EXTERNC

#endif
