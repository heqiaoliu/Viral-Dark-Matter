/*
 *  FILLBACKGROUNDVALUES_D_RT  helper function for Projective
 *  transformation block.
 *  Fill output space with background fill values 
 *  Copyright 1995-2006 The MathWorks, Inc.
 *  $Revision: 1.1.8.4 $  $Date: 2006/06/27 23:22:01 $
 */
#include "vipprojective_rt.h"  

EXPORT_FCN void MWVIP_FillBackgroundValues_D(real_T *fillValPtr, real_T *yr,
                               real_T *yg,real_T *yb,int_T nRowsOut, 
                               int_T nColsOut,boolean_T isInputRGB,
                               boolean_T isScalarFillVal, int_T nChans)
{
#define DTYPE real_T
#include "mwvip_fill_background_values_tplt.c"
#undef DTYPE
}



/* [EOF] fillBackgroundValues_d_rt.c */
