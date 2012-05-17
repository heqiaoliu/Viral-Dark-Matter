/*
 *  OPTICALFLOW_HS_Z_RT runtime function for Optical Flow Block
 *  (Horn & Schunck method).
 *
 *  Copyright 1995-2005 The MathWorks, Inc.
 *  $Revision: 1.1.8.3 $  $Date: 2007/03/13 19:40:56 $
 */
#include "vipopticalflow_rt.h"

EXPORT_FCN void MWVIP_OpticalFlow_HS_Z( const real_T  *inImgA,
                                        const real_T  *inImgB,
                                        creal_T  *outVel,
                                        real_T  *buffCprev, /* length nRows */
                                        real_T  *buffCnext,
                                        real_T  *buffRprev, /* length nCols */
                                        real_T  *buffRnext,
                                        real_T  *gradCC,
                                        real_T  *gradRC,
                                        real_T  *gradRR,
                                        real_T  *gradCT,
                                        real_T  *gradRT,
                                        real_T  *alpha,
                                        real_T  *velBufCcurr,
                                        real_T  *velBufCprev,
                                        real_T  *velBufRcurr,
                                        real_T  *velBufRprev,
                                        const real_T  *lambda,
                                        boolean_T useMaxIter,
                                        boolean_T useAbsVelDiff,
                                        const int32_T *maxIter,
                                        const real_T  *maxAllowableAbsDiffVel,
                                        int_T  inRows,
                                        int_T  inCols)
{
    const int_T inSize  = inRows*inCols;
    real_T *outVelC    = (real_T *)outVel; 
    real_T *outVelR    = (outVelC + inSize);
    const int_T bytesPerInpCol = inRows * sizeof( real_T );

    int_T i, j;

	int_T prevCol;
	const int_T endCol = (inCols-1)*inRows;

    int_T numIter;
	real_T maxAbsVelDiff=0;

    MWVIP_SobelDerivative_HS_D( inImgA,
                                inImgB,
                                outVelC,/* tmpGradC */
                                outVelR,/* tmpGradR */
                                buffCprev,
                                buffCnext,
                                buffRprev,
                                buffRnext,
                                gradCC,
                                gradRC,
                                gradRR,
                                gradCT,
                                gradRT,
                                alpha,
                                lambda,
                                inRows,
                                inCols);

    /* set initial motion vector to zero */
    memset(outVelC, 0, sizeof(real_T)*inSize);
    memset(outVelR, 0, sizeof(real_T)*inSize);
    
    /* Gauss-Seidel iterative solution for Optical Flow constraint equation */
    numIter = 1;
    do
    {
        int_T ij = 0;
        int_T ijM1, ijP1, ijMinRows, ijPinRows;
        
        real_T *velBufCcurrT, *velBufCprevT = NULL, *velBufRcurrT, *velBufRprevT = NULL;

		maxAbsVelDiff = 0;
        velBufCcurrT = velBufCcurr;
        velBufCprevT = velBufCprev;
        velBufRcurrT = velBufRcurr;
        velBufRprevT = velBufRprev;

        for( j = 0; j < inCols; j++ )
        {
  		    prevCol = (j-1)*inRows;/* it is used only when j>0 */
            for( i = 0; i < inRows; i++ )  /* scanning along column */
            {
                real_T avgVelC, avgVelR;
				real_T absVelDiffC, absVelDiffR;

                /* at each iteration we need to use the velocity of the previous iteration
                 * (we need velocity of 4 neighboring pixels from prev iteration)
                 * that's why we can't store the velocity at each iteration to output.
                 * we need to maintain temporary line buffers at each iteration
                 */

                /* mask for computing avg velocity (for prev iteration) (init vel=0):
                 * here (i,j) th element (in 2D) means ==> (ij) th element (in 1D)
                 *
                 *
                 *                                1
                 *                              (i-1,j)
                 *                              = ij-1
                 *
                 *       
                 *                   1            0            1
                 *             (i,j-1)          (i,j)        (i,j+1)
                 *             =ij-inRows       = ij         =ij+inRows
                 *
                 *          
                 *                                1
                 *                             (i+1,j)
                 *                             = ij+1
                 */
                ijM1 = (i==0)          ? ij : ij-1;
                ijP1 = (i==(inRows-1)) ? ij : ij+1;

                ijMinRows = (j==0)          ? ij : ij-inRows;
                ijPinRows = (j==(inCols-1)) ? ij : ij+inRows;
 

                avgVelC = (outVelC[ijM1]      +
                           outVelC[ijP1]      +
						   outVelC[ijMinRows] +
                           outVelC[ijPinRows]) / 4;
                avgVelR = (outVelR[ijM1]      +
                           outVelR[ijP1]      +
                           outVelR[ijMinRows] +
                           outVelR[ijPinRows]) / 4;

                velBufCcurrT[i] = avgVelC -
                    (gradCC[ij] * avgVelC +
                     gradRC[ij] * avgVelR + gradCT[ij]) * alpha[ij];

                velBufRcurrT[i] = avgVelR -
                    (gradRC[ij] * avgVelC +
                     gradRR[ij] * avgVelR + gradRT[ij]) * alpha[ij];

                /* compute max(vel diff along row, vel diff along col) for this frame */
                if(useAbsVelDiff)
                {
                    
					absVelDiffC   = (real_T)fabs(outVelC[ij] - velBufCcurrT[i]);
                    absVelDiffR   = (real_T)fabs(outVelR[ij] - velBufRcurrT[i]);
                    maxAbsVelDiff = MAX( MAX(absVelDiffC,absVelDiffR), maxAbsVelDiff );
                }
                ij++;
            }

            /* 
			 * since we are done scanning this column, we save velocity buffer content 
			 * of the previous column to output. 
			 */
            if( j > 0 )/* skip first column */
            {
                memcpy( &outVelC[prevCol], velBufCprevT, bytesPerInpCol);
                memcpy( &outVelR[prevCol], velBufRprevT, bytesPerInpCol);
            }

            /* switch the next and prev velocity buffers */
            {
                real_T *tmpBuff;
                /* column velocity buffers */
                tmpBuff      = velBufCcurrT;
                velBufCcurrT = velBufCprevT;
                velBufCprevT = tmpBuff;
                /* row velocity buffers */
                tmpBuff      = velBufRcurrT;
                velBufRcurrT = velBufRprevT;
                velBufRprevT = tmpBuff;

            }
        }

        /* copy the last column of velocity (j=inCols) to output */ 
        memcpy( &outVelC[endCol], velBufCprevT, bytesPerInpCol);
        memcpy( &outVelR[endCol], velBufRprevT, bytesPerInpCol);
    }
	while (!(  ( useMaxIter && (numIter++ == maxIter[0]) )  
		  ||   ( useAbsVelDiff && (maxAbsVelDiff < maxAllowableAbsDiffVel[0]) ))); 
    
    /* copy velocity to output port in complex form */
    memcpy(gradCC, outVelC, inSize*sizeof(real_T));
    memcpy(gradRR, outVelR, inSize*sizeof(real_T));
    for( i = 0; i < inSize; i++ )
    {
        outVel[i].re = gradCC[i];
        outVel[i].im = gradRR[i];
    }
}

/* [EOF] opticalflow_hs_z_rt.c */
