/*
 *  INTERPOLATION_R_RT  helper function for Projective
 *  transformation block.
 *  Copyright 1995-2006 The MathWorks, Inc.
 *  $Revision: 1.1.8.5 $  $Date: 2006/06/27 23:22:04 $
 */
#include "vipprojective_rt.h"  

EXPORT_FCN void MWVIP_NN_Interp_R(real32_T *I, real32_T u, real32_T v,
                      int_T nRowsIn, real32_T *y, int_T outIdx, 
                      int_T nChans, int_T inChanWidth, int_T outChanWidth)
{
    int_T uN = ROUND(u);
    int_T vN = ROUND(v);
    int_T chanIdx, inIdx = uN+vN*nRowsIn;
    for (chanIdx = 0; chanIdx < nChans; chanIdx++) {
        y[outIdx] = I[inIdx];
        outIdx   += outChanWidth;
        inIdx    += inChanWidth;
    }
}



EXPORT_FCN void MWVIP_PosVal_BL_Interp_R(real32_T *I, real32_T u,
                               real32_T v, int_T rows,int_T cols,
                               real32_T *y, int_T outIdx, int_T nChans,
                               int_T inChanWidth, int_T outChanWidth)
{
#define DTYPE real32_T
#define VAL_ONE 1.0F
#include "mwvip_posval_bl_interp_tplt.c"
#undef DTYPE
#undef VAL_ONE
}


/* Reference - Digital Image Warping by Wolberg, Ch. 5, 
 * Topic:- Cubic convolution, used value of a = -1; 
 */
EXPORT_FCN void MWVIP_PosVal_BC_Interp_R(real32_T *I, real32_T u, 
                              real32_T v, int_T nRows,int_T nCols,
                              real32_T *y, int_T outIdx, int_T nChans,
                              int_T inChanWidth, int_T outChanWidth)
{
#define DTYPE real32_T
#define VAL_ONE 1.0F
#include "mwvip_posval_bc_interp_tplt.c"
#undef DTYPE
#undef VAL_ONE
}

/* [EOF] interpolation_r_rt.c */
