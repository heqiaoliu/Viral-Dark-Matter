/*  This file contains the function declarations of all the Galois-field math functions. 
 *
 *    Copyright 1996-2006 The MathWorks, Inc.
 *    $Revision: 1.1.6.3 $ $Date: 2009/03/09 19:25:36 $
 */

#ifndef __GF_MATH_H__
#define __GF_MATH_H__

#ifdef MATLAB_MEX_FILE
#include "tmwtypes.h"
#else
#include "rtwtypes.h"
#endif

#include "spc_decl.h"

#ifdef __cplusplus
extern "C" {
#endif

/* gf_mul multiplies the scalars  a * b */
SPC_DECL int gf_mul( int a, int b, int m, const int32_T *table1, const int32_T *table2 );

/* gf_deconv deconvolves A from B, and the result of the deconvolution is stored in A */
SPC_DECL void gf_deconv(int *A,int *B,int *tmpQuotient,int lengthA, int m, const int32_T *table1, const int32_T *table2);

/* gf_div divides the scalars x/b */
SPC_DECL int gf_div(int x, int b, int m, const int32_T *table1, const int32_T *table2);

/*gf_pow raises x^yd */
SPC_DECL int gf_pow(int x, int Yd,  int m, const int32_T *table1, const int32_T *table2);

/* gf_roots finds the roots of X and store them in roots, and return the number of roots */
SPC_DECL int gf_roots(int *roots, int *X, int *d,int *newPoly,int *tmpQuotient, int width, int m, const int32_T *table1, const int32_T *table2);

/* gf_conv convolves A with B and stores the result in retValue */
SPC_DECL void gf_conv(int *retValue, int *A, int *B,int aWidth, int bWidth, int m, const int32_T *table1, const int32_T *table2);

#ifdef __cplusplus
} // end of extern "C" scope
#endif

#endif /* EOF */
