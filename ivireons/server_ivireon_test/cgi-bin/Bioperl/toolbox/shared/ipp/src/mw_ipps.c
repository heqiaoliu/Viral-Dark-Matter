/* Copyright 2010 The MathWorks, Inc. */
/*
* File: mw_ipps.c
* 
* Abstract: IPP library function wrappers for signal processing functions.
*
*/

#include <stdlib.h>

#include "mw_ipps.h"

#define MIN(X,Y) ((X) < (Y) ? (X) : (Y))

/* 1D Correlation, double data type */
void mw_ipp_corr1d_double(const real_T u1[], const int32_T in1Rows, 
                          const real_T u2[], const int32_T in2Rows, 
                          real_T y[])
{
    int32_T i;
    real_T tmp;
    int32_T dstlen = in1Rows + in2Rows - 1;
    int32_T dstlen2 = (int32_T) (dstlen/2);
    ippsCrossCorr_64f(u1, in1Rows, u2, in2Rows, y, dstlen, 1 - MIN(in1Rows, in2Rows));
    
    for (i=0; i<dstlen2; i++) 
    {
        tmp = y[i];
        y[i] = y[dstlen-1-i];
        y[dstlen-1-i] = tmp;
    }
}

/* 1D Correlation, single data type */
void mw_ipp_corr1d_single(const real32_T u1[], const int32_T in1Rows, 
                          const real32_T u2[], const int32_T in2Rows, 
                          real32_T y[])
{
    int32_T i;
    real32_T tmp;
    int32_T dstlen = in1Rows + in2Rows - 1;
    int32_T dstlen2 = (int32_T) (dstlen/2);
    ippsCrossCorr_32f(u1, in1Rows, u2, in2Rows, y, in1Rows + in2Rows - 1, 1 - MIN(in1Rows, in2Rows));
    for (i=0; i<dstlen/2; i++) 
    {
        tmp = y[i];
        y[i] = y[dstlen-1-i];
        y[dstlen-1-i] = tmp;
    }
}

/* 1D Convolution, double data type */
void mw_ipp_conv1d_double(const real_T u1[], const int32_T in1Rows, 
                          const real_T u2[], const int32_T in2Rows, 
                          real_T y[])
{
    ippsConv_64f(u1, in1Rows, u2, in2Rows, y);
}

/* 1D Convolution, single data type */
void mw_ipp_conv1d_single(const real32_T u1[], const int32_T in1Rows, 
                          const real32_T u2[], const int32_T in2Rows, 
                          real32_T y[])
{
    ippsConv_32f(u1, in1Rows, u2, in2Rows, y);
}