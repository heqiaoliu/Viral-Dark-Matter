/*
 *  divideRectXform_d_rt.c  helper function for Projective
 *  transformation block.
 *	Subdivide input rectangle and convert each subdivisions into quadrilateral
 *  Handles double precision input datatype. 
 *  Copyright 1995-2006 The MathWorks, Inc.
 *  $Revision: 1.1.8.4 $  $Date: 2006/06/27 23:21:59 $
 */
#include "vipprojective_rt.h"  

EXPORT_FCN void MWVIP_DivideRectXform_D(
            int32_T *allEdges,int_T *inRectPts,
            sort_item *sortItemArray, real_T *y, real_T *yg,real_T *yb,ViewPortStruct vp, 
            int_T nRowsIn, boolean_T isInputRGB,real_T *A,real_T *inR,real_T *inG,real_T *inB,
            boolean_T isExactSoln, int_T nRowsOut, int_T nColsOut,int_T nColsIn,
            INTERPMETHOD interpMethod,int_T inStartRowIdx,int_T inStartColIdx,
            int_T numSubDivs, boolean_T isInRectSizeUserDef,int_T nChans)
{
#define DTYPE real_T
#define XFORM_FCN MWVIP_XformOneSubdivision_D
#include "mwvip_divide_rect_xform_tplt.c"
#undef DTYPE
#undef XFORM_FCN
}


/* [EOF] divideRectXform_d_rt.c */
