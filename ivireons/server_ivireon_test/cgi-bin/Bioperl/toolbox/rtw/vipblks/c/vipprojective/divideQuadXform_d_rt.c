/*
 *  divideQuadXform_d_rt  helper function for Projective
 *  transformation block. Double precision input datatype
 *	Subdivide input quadrilateral and convert each subdivisions 
 *  into quadrilateral/rectangle
 *  Copyright 1995-2006 The MathWorks, Inc.
 *  $Revision: 1.1.8.6 $  $Date: 2006/12/27 21:26:04 $
 */
#include "vipprojective_rt.h"  

EXPORT_FCN void MWVIP_DivideQuadXform_D(int32_T *allEdges,
        int32_T *inPts,sort_item *sortItemArray,
        real_T *y, real_T *yg,real_T *yb,ViewPortStruct vp, int_T nRowsIn, boolean_T isInputRGB,
        real_T *A, real_T *inR, real_T *inG,real_T *inB, boolean_T isExactSoln,
        int_T nRowsOut, int_T nColsOut,int_T nColsIn, INTERPMETHOD interpMethod,int_T numSubDivs,
        int_T nChans)
{
#define DTYPE real_T
#define XFORM_FCN MWVIP_XformOneSubdivision_D
#include "mwvip_divide_quad_xform_tplt.c"
#undef DTYPE
#undef XFORM_FCN
}

/* [EOF] divideQuadXform_d_rt.c */
