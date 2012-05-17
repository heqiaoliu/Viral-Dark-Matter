/*
*  OPTICALFLOW_LK_R_RT runtime function for Optical Flow Block
*  (Lucas & Kanade method).
*
*  Copyright 1995-2005 The MathWorks, Inc.
*  $Revision: 1.1.8.3 $  $Date: 2007/03/13 19:40:59 $
*/
#include "vipopticalflow_rt.h"  

EXPORT_FCN void MWVIP_OpticalFlow_LK_R( const real32_T  *inImgA,  /* current */
                                       const real32_T  *inImgB,  /* previous */
                                       real32_T  *outVel, 
                                       real32_T  *gradCC,
                                       real32_T  *gradRC,
                                       real32_T  *gradRR,
                                       real32_T  *gradCT,
                                       real32_T  *gradRT,
                                       const real32_T  *eigTh,
                                       int_T   inRows,
                                       int_T   inCols)
{
    int_T i, j, ij, mn;
    int_T cFilterHalfLen = 2;
    int_T rFilterHalfLen = 2;
    int_T BytesPerInCol = sizeof(real32_T)*inRows;

    real32_T threshEigen      = eigTh[0]; 
    real32_T THRESH_ABS_DELTA = 0; /* delta is the determinant of the 2x2 matrix */
    real32_T THRESH_NORM      = 0;

    real32_T gradKernel[5] = {-1/12.0F,8/12.0F,0,-8/12.0F,1/12.0F};

    /* Gaussian separable kernels {1/16.0,4/16.0,6/16.0,4/16.0,1/16.0} */
    real32_T gauss1DFilt[5] = {0.0625F,0.25F,0.375F,0.25F,0.0625F};

    real32_T *cFilter;
    real32_T *rFilter;

    int_T colIdx=0;
    real32_T sum;
    int_T pixelIdx=0;

    cFilter = (real32_T *)&gradKernel[cFilterHalfLen];
    rFilter = (real32_T *)&gradKernel[rFilterHalfLen];

    ij=0;
    mn=0;

    for( colIdx = 0; colIdx < inCols; colIdx++ )
    {
        /***********************************************************************************************/		    
        /*************** FILTERING (TO FIND DERIVATIVE) ALONG COLUMN DIRECTION *************************/
        /***********************************************************************************************/
        int_T leftSpace;
        int_T rightSpace;

        if( colIdx < cFilterHalfLen )	 /* process first cFilterHalfLen pixels */
        {
            leftSpace = colIdx;
            rightSpace = cFilterHalfLen;

            pixelIdx = 0;
            for( j = 0; j < inRows; j++ )
            {
                int_T addr = 0;
                sum = 0;

                for( i = -leftSpace; i <= rightSpace; i++ )
                {
                    sum += inImgA[addr + j] * cFilter[i];
                    addr += inRows;
                }
                gradCC[ij++] = sum;
            }
        }
        else if( colIdx < inCols - cFilterHalfLen ) /* process middle part */
        {
            pixelIdx = (colIdx - cFilterHalfLen) * inRows;
            for( j = 0; j < inRows; j++ )
            {
                int_T addr = pixelIdx;
                gradCC[ij++] = (-inImgA[addr + j] + inImgA[addr+4*inRows + j])*cFilter[2]
                +(inImgA[addr+inRows + j] - inImgA[addr+3*inRows + j])*cFilter[-1];
            }
        }
        else  /* process last cFilterHalfLen pixels; if( colIdx >= inCols - cFilterHalfLen ) */
        {
            leftSpace = cFilterHalfLen;
            rightSpace = inCols - colIdx - 1;

            pixelIdx = (colIdx - leftSpace) * inRows;
            for( j = 0; j < inRows; j++ )
            {
                int_T addr = pixelIdx;
                sum = 0;

                for( i = -leftSpace; i <= rightSpace; i++ )
                {
                    sum += inImgA[addr + j] * cFilter[i];
                    addr += inRows;
                }
                gradCC[ij++] = sum;
            }
        }
        /***********************************************************************************************/		    
        /*************** FILTERING (TO FIND DERIVATIVE) ALONG ROW DIRECTION ****************************/
        /***********************************************************************************************/
        /* process first rFilterHalfLen pixels */
        for( j = 0; j < rFilterHalfLen; j++ )
        {
            int_T jj;

            sum = 0;

            for( jj = -j; jj <= rFilterHalfLen; jj++ )
            {
                sum += inImgA[mn + jj] * rFilter[jj];
            }
            gradRR[mn] = sum;
            mn++;
        }
        /* process inner part of line */
        for( j = rFilterHalfLen; j < inRows - rFilterHalfLen; j++ )
        {
            gradRR[mn]  = (inImgA[mn - 1] - inImgA[mn + 1])* rFilter[-1]  /* 8/12 */
            + (-inImgA[mn - 2] + inImgA[mn + 2])* rFilter[2]; /* 1/12 */
            mn++;
        }
        /* process right side */
        for( j = inRows - rFilterHalfLen; j < inRows; j++ )
        {
            int_T jj;

            sum = 0;

            for( jj = -rFilterHalfLen; jj < inRows - j; jj++ )
            {
                sum += inImgA[mn + jj] * rFilter[jj];
            }
            gradRR[mn] = sum;
            mn++;
        }
    }
    for( j = 0; j < inRows*inCols; j++ )
    {
        real32_T tmpGradR = gradRR[j]; 
        real32_T tmpGradC = gradCC[j];
        real32_T tmpGradT = inImgB[j] - inImgA[j]; /* GradT */

        gradRR[j] = tmpGradR*tmpGradR; 
        gradCC[j] = tmpGradC*tmpGradC; 
        gradRC[j] = tmpGradR*tmpGradC; 

        gradRT[j] = tmpGradR*tmpGradT; 
        gradCT[j] = tmpGradC*tmpGradT; 
    }

    /***********************************************************************************************/		    
    /************** GAUSSIAN FILTERING (TO INTRODUCE WEIGHT) ALONG ROW DIRECTION *******************/
    /***********************************************************************************************/
    mn = 0;
    cFilter = (real32_T *)&gauss1DFilt[cFilterHalfLen];
    rFilter = (real32_T *)&gauss1DFilt[rFilterHalfLen];

    for( colIdx = 0; colIdx < inCols; colIdx++ )
    {
        real32_T *tmpWGradRR = &outVel[0];
        real32_T *tmpWGradCC = &outVel[inRows];
        real32_T *tmpWGradRC = &outVel[2*inRows];
        real32_T *tmpWGradRT = &outVel[3*inRows];
        real32_T *tmpWGradCT = &outVel[4*inRows];
        int_T     colIdxTimesInRows = colIdx*inRows;

        memcpy(tmpWGradRR, &gradRR[colIdxTimesInRows],BytesPerInCol);
        memcpy(tmpWGradCC, &gradCC[colIdxTimesInRows],BytesPerInCol);
        memcpy(tmpWGradRC, &gradRC[colIdxTimesInRows],BytesPerInCol);
        memcpy(tmpWGradRT, &gradRT[colIdxTimesInRows],BytesPerInCol);
        memcpy(tmpWGradCT, &gradCT[colIdxTimesInRows],BytesPerInCol);
        ij=0;
        /* process top side */
        for( j = 0; j < rFilterHalfLen; j++ )
        {
            int_T jj;

            tmpWGradRR[ij] = 0;
            tmpWGradCC[ij] = 0;
            tmpWGradRC[ij] = 0;
            tmpWGradRT[ij] = 0;
            tmpWGradCT[ij] = 0;

            for( jj = -j; jj <= rFilterHalfLen; jj++ )
            {
                tmpWGradRR[ij] += gradRR[mn + jj] * rFilter[jj];
                tmpWGradCC[ij] += gradCC[mn + jj] * rFilter[jj];
                tmpWGradRC[ij] += gradRC[mn + jj] * rFilter[jj];
                tmpWGradRT[ij] += gradRT[mn + jj] * rFilter[jj];
                tmpWGradCT[ij] += gradCT[mn + jj] * rFilter[jj];
            }
            mn++;
            ij++;
        }
        /* process inner part of line */
        for( j = rFilterHalfLen; j < inRows - rFilterHalfLen; j++ )
        {
            int_T jj;
            tmpWGradRR[ij] = 0;
            tmpWGradCC[ij] = 0;
            tmpWGradRC[ij] = 0;
            tmpWGradRT[ij] = 0;
            tmpWGradCT[ij] = 0;

            for( jj = 1; jj <= rFilterHalfLen; jj++ )
            {
                tmpWGradRR[ij] += (gradRR[mn - jj] + gradRR[mn + jj]) * rFilter[jj];
                tmpWGradCC[ij] += (gradCC[mn - jj] + gradCC[mn + jj]) * rFilter[jj];
                tmpWGradRC[ij] += (gradRC[mn - jj] + gradRC[mn + jj]) * rFilter[jj];
                tmpWGradRT[ij] += (gradRT[mn - jj] + gradRT[mn + jj]) * rFilter[jj];
                tmpWGradCT[ij] += (gradCT[mn - jj] + gradCT[mn + jj]) * rFilter[jj];
            }
            tmpWGradRR[ij] += gradRR[mn] * rFilter[0];
            tmpWGradCC[ij] += gradCC[mn] * rFilter[0];
            tmpWGradRC[ij] += gradRC[mn] * rFilter[0];
            tmpWGradRT[ij] += gradRT[mn] * rFilter[0];
            tmpWGradCT[ij] += gradCT[mn] * rFilter[0];

            mn++;  
            ij++;
        }
        /* process bottom side */
        for( j = inRows - rFilterHalfLen; j < inRows; j++ )
        {
            int_T jj;

            tmpWGradRR[ij] = 0;
            tmpWGradCC[ij] = 0;
            tmpWGradRC[ij] = 0;
            tmpWGradRT[ij] = 0;
            tmpWGradCT[ij] = 0;

            for( jj = -rFilterHalfLen; jj < inRows - j; jj++ )
            {
                tmpWGradRR[ij] += gradRR[mn + jj] * rFilter[jj];
                tmpWGradCC[ij] += gradCC[mn + jj] * rFilter[jj];
                tmpWGradRC[ij] += gradRC[mn + jj] * rFilter[jj];
                tmpWGradRT[ij] += gradRT[mn + jj] * rFilter[jj];
                tmpWGradCT[ij] += gradCT[mn + jj] * rFilter[jj];
            }
            mn++;  
            ij++;
        }
        memcpy(&gradRR[colIdxTimesInRows],tmpWGradRR, BytesPerInCol);
        memcpy(&gradCC[colIdxTimesInRows],tmpWGradCC, BytesPerInCol);
        memcpy(&gradRC[colIdxTimesInRows],tmpWGradRC, BytesPerInCol);
        memcpy(&gradRT[colIdxTimesInRows],tmpWGradRT, BytesPerInCol);
        memcpy(&gradCT[colIdxTimesInRows],tmpWGradCT, BytesPerInCol);

    }

    /*******************************************************************************************/		    
    /************* GAUSSIAN FILTERING (TO INTRODUCE WEIGHT) ALONG COLUMN DIRECTION *************/
    /*******************************************************************************************/
    mn=0;
    for( colIdx = 0; colIdx < inCols; colIdx++ )
    {
        int_T leftSpace;
        int_T rightSpace;

        if( colIdx < cFilterHalfLen )
            leftSpace = colIdx;
        else
            leftSpace = cFilterHalfLen;

        if( colIdx >= inCols - cFilterHalfLen )
            rightSpace = inCols - colIdx - 1;
        else
            rightSpace = cFilterHalfLen;

        pixelIdx = (colIdx - leftSpace) * inRows;
        for( j = 0; j < inRows; j++ )
        {
            int_T addr = pixelIdx;

            real32_T WWGradRR = 0;
            real32_T WWGradCC = 0;
            real32_T WWGradRC = 0;
            real32_T WWGradRT = 0;
            real32_T WWGradCT = 0;

            for( i = -leftSpace; i <= rightSpace; i++ )
            {
                WWGradRR += gradRR[addr + j] * cFilter[i];
                WWGradCC += gradCC[addr + j] * cFilter[i];
                WWGradRC += gradRC[addr + j] * cFilter[i];
                WWGradRT += gradRT[addr + j] * cFilter[i];
                WWGradCT += gradCT[addr + j] * cFilter[i];

                addr += inRows;
            }
            /************************************************************************/
            /********************** Solve Linear System *****************************/
            /************************************************************************/
            {
                real32_T delta = (WWGradRC * WWGradRC - WWGradCC * WWGradRR);
                real32_T A = (WWGradCC+WWGradRR)/2.0F;
                real32_T tmp  = WWGradCC-WWGradRR;
                real32_T B = 4.0F*WWGradRC*WWGradRC + tmp*tmp;
                real32_T sqrtBby2 = sqrtf(B)/2.0F;
                real32_T eig1=A+sqrtBby2;   /* Largest eigenvalue first  */
                real32_T eig2=A-sqrtBby2;
                if ((eig1 >= threshEigen) && (eig2 >= threshEigen) && (fabsf(delta)>=THRESH_ABS_DELTA))
                {
                    /* Solving by Cramer's rule */
                    real32_T deltaC, deltaC_IDelta;
                    real32_T deltaR, deltaR_IDelta;
                    real32_T Idelta = 1.0F / delta;

                    deltaC = -(WWGradRT * WWGradRC - WWGradCT * WWGradRR);
                    deltaR = -(WWGradRC * WWGradCT - WWGradCC * WWGradRT);

                    deltaC_IDelta = deltaC * Idelta;
                    deltaR_IDelta = deltaR * Idelta;
                    outVel[mn] = deltaC_IDelta*deltaC_IDelta + deltaR_IDelta * deltaR_IDelta;
                    mn++;
                }
                else if ((eig1 >= threshEigen) && (eig2 < threshEigen))
                {
                    /* singular system - find optical flow in gradient direction */
                    /* singular system, determinant is non-invertible */
                    /* gradient flow is normalized */

                    real32_T tmpRC_CC = WWGradRC + WWGradCC;
                    real32_T tmpRR_RC = WWGradRR + WWGradRC;
                    real32_T norm = tmpRC_CC*tmpRC_CC + tmpRR_RC*tmpRR_RC;

                    if( norm >= THRESH_NORM )
                    {
                        real32_T invNorm = 1.0F / norm;
                        real32_T temp = -(WWGradRT + WWGradCT) * invNorm;
                        real32_T velReal = tmpRC_CC * temp;
                        real32_T velImag = tmpRR_RC * temp;

                        outVel[mn] = velReal * velReal + velImag * velImag;
                        mn++;
                    }
                    else
                    {
                        outVel[mn] = 0;
                        mn++;
                    }
                }
                else								            
                {
                    outVel[mn] = 0;
                    mn++;
                }

            }
        }
    }

}

/* [EOF] opticalflow_lk_r_rt.c */
