/*
 *  divideQuadXform_d_rt  helper function for Projective
 *  transformation block. Double precision input datatype
 *	Subdivide input quadrilateral and convert each subdivisions 
 *  into quadrilateral/rectangle
 *  Copyright 1995-2006 The MathWorks, Inc.
 *  $Revision: 1.1.8.6 $  $Date: 2006/12/27 21:26:05 $
 */
#include "vipprojective_rt.h"  

EXPORT_FCN void MWVIP_DivideQuadXform_R(int32_T *allEdges,
        int32_T *inPts,sort_item *sortItemArray,
        real32_T *y, real32_T *yg,real32_T *yb,ViewPortStruct vp, int_T nRowsIn, boolean_T isInputRGB,
        real32_T *A, real32_T *inR, real32_T *inG,real32_T *inB, boolean_T isExactSoln,
        int_T nRowsOut, int_T nColsOut,int_T nColsIn, INTERPMETHOD interpMethod,int_T numSubDivs,
        int_T nChans)
{
#define DTYPE real32_T
#define XFORM_FCN MWVIP_XformOneSubdivision_R
#include "mwvip_divide_quad_xform_tplt.c"
#undef DTYPE
#undef XFORM_FCN
}

/* [EOF] divideQuadXform_r_rt.c */
