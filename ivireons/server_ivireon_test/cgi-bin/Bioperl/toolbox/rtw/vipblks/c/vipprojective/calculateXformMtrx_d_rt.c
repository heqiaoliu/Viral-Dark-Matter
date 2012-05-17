/*
 *  CALCULATEXFORMMATRIX_D_RT  helper function for Projective
 *  transformation block.
 *	Calculates transformation matrix for projective transformation. 
 *  Copyright 1995-2006 The MathWorks, Inc.
 *  $Revision: 1.1.8.3 $  $Date: 2006/06/27 23:21:55 $
 */
#include "vipprojective_rt.h"  

EXPORT_FCN void MWVIP_CalculateXformMtrx_D(int_T *outPts,
            int_T *rectROIPts,int_T rectRows, int_T rectCols,MODE mode,
            int_T numSubDivs,boolean_T isInRectSizeUserDef,
            real_T *Aptr)
{

#define DTYPE real_T
#include "mwvip_calculate_xform_mtrx_tplt.c"
#undef DTYPE
}



/* [EOF] calculateXformMtrx_d_rt.c */
