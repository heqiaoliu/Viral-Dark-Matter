/*
 *  CALCULATEXFORMMATRIX_R_RT  helper function for Projective
 *  transformation block.
 *	Calculates transformation matrix for projective transformation when 
 *  input is single precision. 
 *  Copyright 1995-2006 The MathWorks, Inc.
 *  $Revision: 1.1.8.3 $  $Date: 2006/06/27 23:21:56 $
 */
#include "vipprojective_rt.h"  


EXPORT_FCN void MWVIP_CalculateXformMtrx_R(int_T *outPts,
            int_T *rectROIPts,int_T rectRows, int_T rectCols,MODE mode,
            int_T numSubDivs,boolean_T isInRectSizeUserDef,
            real32_T *Aptr)
{

#define DTYPE real32_T
#include "mwvip_calculate_xform_mtrx_tplt.c"
#undef DTYPE
}

/* [EOF] calculateTransformationMatrix_rt.c */
