/*
 *  divideRectXform_r_rt.c  helper function for Projective
 *  transformation block.
 *	Subdivide input rectangle and convert each subdivisions into quadrilateral
 *  Handles single precision input datatype. 
 *  Copyright 1995-2006 The MathWorks, Inc.
 *  $Revision: 1.1.8.4 $  $Date: 2006/06/27 23:22:00 $
 */
#include "vipprojective_rt.h"  

EXPORT_FCN void MWVIP_DivideRectXform_R(
            int32_T *allEdges,int_T *inRectPts,
            sort_item *sortItemArray, real32_T *y, real32_T *yg,real32_T *yb,ViewPortStruct vp, 
            int_T nRowsIn, boolean_T isInputRGB,real32_T *A,real32_T *inR,real32_T *inG,real32_T *inB,
            boolean_T isExactSoln, int_T nRowsOut, int_T nColsOut,int_T nColsIn,
            INTERPMETHOD interpMethod,int_T inStartRowIdx,int_T inStartColIdx,
            int_T numSubDivs, boolean_T isInRectSizeUserDef,int_T nChans)
{
#define DTYPE real32_T
#define XFORM_FCN MWVIP_XformOneSubdivision_R
#include "mwvip_divide_rect_xform_tplt.c"
#undef DTYPE
#undef XFORM_FCN
}


/* [EOF] divideRectXform_r_rt.c */
