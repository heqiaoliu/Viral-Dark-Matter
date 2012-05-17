/*
 *  INTERPOLATION_D_RT  helper function for Projective
 *  transformation block.
 *  Copyright 1995-2006 The MathWorks, Inc.
 *  $Revision: 1.1.8.5 $  $Date: 2006/06/27 23:22:03 $
 */
#include "vipprojective_rt.h"  

EXPORT_FCN void MWVIP_NN_Interp_D(real_T *I, real_T u, real_T v,
                      int_T nRowsIn, real_T *y, int_T outIdx, 
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

/* Handles bilinear interpolation of both positive and negative
 * values. 
 * Uncomment it when there is a use for this function. 
 */
/*
EXPORT_FCN real_T MWVIP_Bilinear_Interpolation(real_T *I, real_T u,
                               real_T v, int_T rows,int_T cols)
{
    real_T deltaU,deltaV,val0,val1,y;
    int_T v0,v1;
    int_T u0 = (int_T)u;
    int_T u1 = (u0 < 0) ? u0-1 : u0+1;
    if (u1 > (rows-1)) u1 = rows-1;
    v0 = (int_T)v;
    v1 = (v0 < 0) ? v0-1 : v0+1;
    if (v1 > (cols-1)) v1 = cols-1;
    deltaU = u - u0;
    deltaV = v - v0;
    val0 = deltaU*I[u1+v0*rows] + (1-deltaU)*I[u0+v0*rows];
    val1 = deltaU*I[u1+v1*rows] + (1-deltaU)*I[u0+v1*rows];
    y = val1*deltaV + val0*(1-deltaV);
    return y;
}
*/


EXPORT_FCN void MWVIP_PosVal_BL_Interp_D(real_T *I, real_T u,
                               real_T v, int_T rows,int_T cols,
                               real_T *y, int_T outIdx, int_T nChans,
                               int_T inChanWidth, int_T outChanWidth)
{
#define DTYPE   real_T
#define VAL_ONE 1.0
#include "mwvip_posval_bl_interp_tplt.c"
#undef DTYPE
#undef VAL_ONE
}


/* Reference - Digital Image Warping by Wolberg, Ch. 5, 
 * Topic:- Cubic convolution, used value of a = -1; 
 */
EXPORT_FCN void MWVIP_PosVal_BC_Interp_D(real_T *I, real_T u, 
                              real_T v, int_T nRows,int_T nCols,
                              real_T *y, int_T outIdx, int_T nChans,
                              int_T inChanWidth, int_T outChanWidth)
{
#define DTYPE real_T
#define VAL_ONE 1.0
#include "mwvip_posval_bc_interp_tplt.c"
#undef DTYPE
#undef VAL_ONE
}

/* [EOF] interpolation_d_rt.c */
