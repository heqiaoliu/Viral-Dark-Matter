/*
 *  getInPtsFrmOutPts_r_rt.c  helper function for Projective
 *  transformation block.
 *	Using inverse mapping transformation matrix, computes the points of 
 *  input image corresponding the given output image points. 
 *  Copyright 1995-2005 The MathWorks, Inc.
 *  $Revision: 1.1.8.1 $  $Date: 2005/08/20 13:23:33 $
 */
#include "vipprojective_rt.h"  

EXPORT_FCN void MWVIP_GetInPtsFrmOutPts_R(int_T r, int_T c,
                                real32_T *A,real32_T *u, real32_T *v, real32_T *w)
{
    *v = A[0]*c + A[1]*r + A[2];
    *u = A[3]*c + A[4]*r + A[5];
    *w = A[6]*c + A[7]*r + A[8];
}

/* [EOF] getInPtsFrmOutPts_r_rt.c */
