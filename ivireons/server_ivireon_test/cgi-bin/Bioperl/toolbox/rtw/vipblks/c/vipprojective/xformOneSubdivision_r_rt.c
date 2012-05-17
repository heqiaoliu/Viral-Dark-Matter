/*
 *  xformOneSubdivision_r_rt  helper function for Projective
 *  transformation block.
 *	Convert rectangle/quad into rectangle/quad 
 *  Copyright 1995-2006 The MathWorks, Inc.
 *  $Revision: 1.1.8.7 $  $Date: 2006/12/27 21:26:07 $
 */
#include "vipprojective_rt.h"  

EXPORT_FCN void MWVIP_XformOneSubdivision_R(
    int32_T *allEdges,int_T numPts,int32_T *outPts,
    sort_item *sortItemArray,real32_T *y, real32_T *yg,real32_T *yb,
    ViewPortStruct vp, int_T nRowsIn, boolean_T isInputRGB, real32_T *A,
    real32_T *inR,real32_T *inG,real32_T *inB,boolean_T isExactSoln, 
    int_T nRowsOut, int_T nColsOut,int_T nColsIn,INTERPMETHOD interpMethod,
    int_T inStartRowIdx,int_T inStartColIdx, int_T nChans)
{
#define DTYPE real32_T
#define COMPUTE_OUTVAL_FCN MWVIP_ProjComputeOutPixel_R
#define ISFILLPOLYGON 0
#define   CREATE_EDGES_TABLE_FCN         MWVIP_CreateEdgesTable
#define   DRAWANTIALIASED 0
#include "mwvip_xform_one_subdivision_tplt.c"
#undef DTYPE
#undef COMPUTE_OUTVAL_FCN
#undef ISFILLPOLYGON
#undef CREATE_EDGES_TABLE_FCN
#undef DRAWANTIALIASED
}

/* [EOF] xformOneSubdivision_r_rt.c */
