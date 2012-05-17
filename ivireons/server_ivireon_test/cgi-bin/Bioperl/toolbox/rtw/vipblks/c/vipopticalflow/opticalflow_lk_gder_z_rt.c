/*
*  OPTICALFLOW_LK_GDER_Z_RT runtime function for Optical Flow Block
*  (Lucas & Kanade method): complex double output
*
*  Copyright 1995-2007 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2007/05/23 19:01:09 $
*/
#include "vipopticalflow_rt.h"  

#include "vipopticalflow_rt.h"  

/*
* ordering for INPORT Index and for TEMPORAL FILTERING
*   
*  INPORT index: 
* -------------
*                                                                _____________
*  (Latest Frame ->) --------------------------------------------|InportIdx=0
*                       |--DELAY---------------------------------|InportIdx=1
*                                 |--DELAY-----------------------|InportIdx=2
*                                           |--DELAY-------------|InportIdx=3
*                                  (Oldest Frame -->) |--DELAY---|InportIdx=4
*                                                                -------------
* 
*  TEMPORAL FILTERING:
*  -------------------
* 
*  For temporal filtering each frame is reshaped to a column vector.
*  The i-th element (0<=i<frameWidth) of each column are filtered 
*    with temporal filter
* 
*             Old                     Latest
* InportIdx=>  4     3     2     1     0
*              |     |     |     |     |   
*              |     |     |     |     |   
*              |     |     |     |     |   
*              |     |     |     |     |   
*              |     |     |     |     |   
* 
*   so, the signal with Highest InportIdx is multiplied with the 
*      first filter coeff 
* 
*   Note: InportIdx=2 contains "current" signal, 
*                     We are computing Optical Flow for this frame
*         InportIdx=(3&4) are "previous" frames
*         InportIdx=(1&0) are "look-ahead" frames
* 
*/

/* 
* CGIR code calls the following function with (pointer_T * => void **) 
* as the first argument type.
* Since, we can't cast it explicitly to (const real_T **) in codegen, 
* we are changing the first argument type to (void **) in this function
*/

EXPORT_FCN void MWVIP_OpticalFlow_LK_GDER_Z(void **inPortAddr,   
                                            creal_T  *outVel, 
                                            real_T  *dx, /* xx => gradCC */
                                            real_T  *dy, /* yy => gradRC */
                                            real_T  *dt, /* xy => gradRR */
                                            real_T  *xt, /* gradCT */
                                            real_T  *yt, /* gradRT */
                                            const real_T *eigTh,
                                            const real_T *tGradKernel,
                                            const real_T *sGradKernel,
                                            const real_T *tKernel,
                                            const real_T *sKernel,
                                            const real_T *wKernel,
                                            int_T   inRows,
                                            int_T   inCols,
                                            int_T tGradKernelLen,
                                            int_T sGradKernelLen,
                                            int_T tKernelLen,
                                            int_T sKernelLen,
                                            int_T wKernelLen,
                                            boolean_T includeNormalFlow)
{
    real_T threshEigen = eigTh[0]; 
    int_T i, j, idx;
    int_T numInFrames;
    const int_T inWidth = inRows*inCols;
    int_T startPortIdx_tKer=0;
    int_T startPortIdx_tGker=0;
    int_T halfwKernelLen = wKernelLen >>1; 
    real_T *tempBuf = (real_T *)outVel;
    real_T *xx;
    real_T *yy;
    real_T *xy;
    real_T tmp_dx, tmp_dy, tmp_dt;
    real_T velRe, velIm;

    if (tGradKernelLen > tKernelLen)
    {
        startPortIdx_tKer = (tGradKernelLen - tKernelLen)>>1;/* divide by 2 */
        numInFrames = tGradKernelLen;
    }
    else
    {
        startPortIdx_tGker = (tKernelLen - tGradKernelLen)>>1; 
        numInFrames = tKernelLen;
    }

    /* Temporal convolution */
    /* dx = convolvet(im, tKernel); */
    MWVIP_OFLK_ConvT_D((const real_T **)&inPortAddr[startPortIdx_tKer], 
                       dx, tKernel, inWidth, tKernelLen);
    /* dy = dx; */
    memcpy(dy, dx, inWidth*sizeof(real_T));
    /* dt = convolvet(im, tGradKernel); */
    MWVIP_OFLK_ConvT_D((const real_T **)&inPortAddr[startPortIdx_tGker], 
                       dt, tGradKernel, inWidth, tGradKernelLen);

    /* Spatial convolution */
    /* tempBuf = convolvex(dx, sGradKernel); */
    MWVIP_OFLK_ConvX_D(dx, tempBuf, sGradKernel, inRows, inCols, sGradKernelLen);
    /* dx = convolvey(tempBuf, sKernel'); */
    MWVIP_OFLK_ConvY_D(tempBuf, dx, sKernel, inRows, inCols, sKernelLen);

    /* tempBuf = convolvex(dy, sKernel); */
    MWVIP_OFLK_ConvX_D(dy, tempBuf, sKernel, inRows, inCols, sKernelLen);
    /* dy = convolvey(tempBuf, sGradKernel'); */
    MWVIP_OFLK_ConvY_D(tempBuf, dy, sGradKernel, inRows, inCols, sGradKernelLen);

    /* tempBuf = convolvex(dt, sKernel); */
    MWVIP_OFLK_ConvX_D(dt, tempBuf, sKernel, inRows, inCols, sKernelLen);
    /* dt = convolvey(tempBuf, sKernel'); */
    MWVIP_OFLK_ConvY_D(tempBuf, dt, sKernel, inRows, inCols, sKernelLen);

    /* xx = dx.*dx; */
    /* yy = dy.*dy; */
    /* xy = dx.*dy; */
    /* xt = dx.*dt; */
    /* yt = dy.*dt; */
    xx = dx;
    yy = dy;
    xy = dt; /* xt, yt new buffers */
    for (i = 0; i < inRows*inCols; i++)
    {
        tmp_dx = dx[i];
        tmp_dy = dy[i];
        tmp_dt = dt[i];

        xx[i] = tmp_dx * tmp_dx;
        yy[i] = tmp_dy * tmp_dy;
        xy[i] = tmp_dx * tmp_dy;
        xt[i] = tmp_dx * tmp_dt;
        yt[i] = tmp_dy * tmp_dt;
    }
    /* xx = convolvexy1D(xx, G);% convolving with G and G' */
    convolveXY1D_D(xx, tempBuf, wKernel, inRows, inCols, wKernelLen);/* output in xx */
    /* yy = convolvexy1D(yy, G);% convolving with G and G' */
    convolveXY1D_D(yy, tempBuf, wKernel, inRows, inCols, wKernelLen);/* output in yy */
    /* xy = convolvexy1D(xy, G);% convolving with G and G' */
    convolveXY1D_D(xy, tempBuf, wKernel, inRows, inCols, wKernelLen);/* output in xy */
    /* xt = convolvexy1D(xt, G);% convolving with G and G' */
    convolveXY1D_D(xt, tempBuf, wKernel, inRows, inCols, wKernelLen);/* output in xt */
    /* yt = convolvexy1D(yt, G);% convolving with G and G' */
    convolveXY1D_D(yt, tempBuf, wKernel, inRows, inCols, wKernelLen);/* output in yt */

    idx = 0;
    for (j = 0; j < inCols; j++)
    {
        for (i = 0; i < inRows; i++, idx++)
        {
            if ((i<halfwKernelLen) || (j<halfwKernelLen)) 
            {
                outVel[idx].re = 0;
                outVel[idx].im = 0;
            }
            else 
            {
                /* eigenvalue computation */
                real_T delta = (xy[idx] * xy[idx] - xx[idx] * yy[idx]);
                real_T A = (xx[idx]+yy[idx])/2.0;
                real_T tmp = xx[idx]-yy[idx];
                real_T B = 4*xy[idx]*xy[idx] + (tmp*tmp);
                real_T sqrtBby2 = sqrt(B)/2.0;
                real_T eig1=A+sqrtBby2;
                real_T eig2=A-sqrtBby2; 

                if ((eig2 >= threshEigen) && (delta <0))/* eig2>eig1 (>= threshEigen) */
                {
                    /* Solving by Cramer's rule  */
                    real_T deltaX = -(yt[idx] * xy[idx] - xt[idx] * yy[idx]);
                    real_T deltaY = -(xy[idx] * xt[idx] - xx[idx] * yt[idx]);
                    real_T Idelta = 1.0 / delta;

                    outVel[idx].re = deltaX * Idelta;
                    outVel[idx].im = deltaY * Idelta;
                }      /* always eig1 > eig2*/
                else if (includeNormalFlow && 
                         (eig1 >= threshEigen) && (fabs(delta) > THRESH_ABS_DELTA_GDER))
                {
                    /* always eig1 > eig2; Find eigenVector corresponding to largest eigenValue*/
                    /* eigVec = [xy; (eig1-xx)]./sqrt((xx-eig1)*(xx-eig1) + xy*xy); */
                    real_T mFactor = 1.0/sqrt((xx[idx]-eig1)*(xx[idx]-eig1) + xy[idx]*xy[idx]); 
                    real_T eigVec1_0 = xy[idx]*mFactor;
                    real_T eigVec1_1 = (eig1-xx[idx])*mFactor;
                    real_T tmpVel;
                    /**/ 
                    real_T deltaX = -(yt[idx] * xy[idx] - xt[idx] * yy[idx]);
                    real_T deltaY = -(xy[idx] * xt[idx] - xx[idx] * yt[idx]);
                    real_T Idelta = 1.0 / delta;

                    velRe = deltaX * Idelta;
                    velIm = deltaY * Idelta;
                    /**/
                    tmpVel = -(velRe*eigVec1_0 + velIm*eigVec1_1);
                    outVel[idx].re = tmpVel*eigVec1_1;
                    outVel[idx].im = tmpVel*eigVec1_0;
                }
                else
                {
                    outVel[idx].re = 0;
                    outVel[idx].im = 0;
                }
            }                
        }
    }
}

/* [EOF] opticalflow_lk_gder_d_rt.c */
