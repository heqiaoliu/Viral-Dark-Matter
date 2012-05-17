/*
 *  CALCULATEQ2QXFORMMTRX_D_RT  helper function for Projective
 *  transformation block.
 *	Calculates transformation matrix for projective transformation in quad
 *   to quad mode. Input datatype is double precision. 
 *  Copyright 1995-2006 The MathWorks, Inc.
 *  $Revision: 1.1.8.3 $  $Date: 2006/06/27 23:21:53 $
 */
#include "vipprojective_rt.h"  

EXPORT_FCN void MWVIP_CalculateQ2QXformMtrx_D(int_T *inPtsValid,
            int_T nRowsIn, int_T nColsIn,
            real_T *A, int_T *outPts, boolean_T useSubdivision)
{
#define DTYPE real_T
#define CALCULATE_XFROM_MATRIX_FCN  MWVIP_CalculateXformMtrx_D
#include "mwvip_calculate_q2q_xform_mtrx_tplt.c"
#undef DTYPE
#undef CALCULATE_XFROM_MATRIX_FCN
}

/* [EOF] calculateQ2QXformMtrx_d_rt.c */
