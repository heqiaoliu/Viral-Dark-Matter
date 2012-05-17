/*
 *  TRANSFORMONESUBDIVISION  helper function for Projective
 *  transformation block.
 *	Convert rectangle/quad into rectangle/quad 
 *  Copyright 1995-2006 The MathWorks, Inc.
 *  $Revision: 1.1.8.4 $  $Date: 2006/06/27 23:22:05 $
 */
#include "vipprojective_rt.h"  

EXPORT_FCN void MWVIP_ProjComputeOutPixel_D(
            real_T *y,real_T *yg, real_T *yb,int_T icurr_col,ViewPortStruct vp,
            int_T r0, int_T r2,int_T nRowsIn, boolean_T isInputRGB,
            real_T *inR, real_T *inG, real_T *inB,
            real_T *A,int_T nColsIn,int_T nRowsOut,int_T nColsOut,
            INTERPMETHOD interpMethod,boolean_T isExactSoln,
            int_T inStartRowIdx, int_T inStartColIdx, int_T nChans)
{
#define DTYPE                real_T
#define GET_INPTS_FRM_OUTPTS MWVIP_GetInPtsFrmOutPts_D
#define NN_INTERP_FCN        MWVIP_NN_Interp_D
#define BL_INTERP_FCN        MWVIP_PosVal_BL_Interp_D
#define BC_INTERP_FCN        MWVIP_PosVal_BC_Interp_D
#include "mwvip_proj_compute_outpixel_tplt.c"
#undef DTYPE
#undef GET_INPTS_FRM_OUTPTS
#undef NN_INTERP_FCN
#undef BL_INTERP_FCN
#undef BC_INTERP_FCN
}


/* [EOF] transformOneSubdivision_rt.c */
