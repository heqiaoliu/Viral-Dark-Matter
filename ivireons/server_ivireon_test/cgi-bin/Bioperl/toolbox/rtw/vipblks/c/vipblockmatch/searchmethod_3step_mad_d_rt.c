                                                                     /*
 *  SEARCHMETHOD_3STEP_MAD_D_RT Helper function for Block Matching block.
 *
 *  Copyright 1995-2005 The MathWorks, Inc.
 *  $Revision: 1.1.10.2 $  $Date: 2005/12/22 18:35:32 $
 */
#include "vipblockmatch_rt.h"  

EXPORT_FCN void MWVIP_SearchMethod_3Step_MAD_D(const real_T *blkCS, const real_T *blkPB, /* CS = current image (smaller block), PB = previous image (bigger block) */
                                             int_T rowsImgCS,   int_T rowsImgPB,  
                                             int_T blkCSWidthX, int_T blkCSHeightY,  
                                             int_T blkPBWidthX, int_T blkPBHeightY,  
                                             int_T *xIdx,         int_T *yIdx)
{
    const int_T endRowIdx = blkPBHeightY-blkCSHeightY+1;
    const int_T endColIdx = blkPBWidthX -blkCSWidthX +1;
    real_T sum3= 0.0;  /* holds the minimum value */
    int_T p;
    int_T flag = 0;
    int_T midIdxR = endRowIdx/2;
    int_T midIdxC = endColIdx/2;
    int_T range = MIN(midIdxR,midIdxC);

    int_T delta = (int_T)(range/2) + 1;
    while (delta > 0) {
      int_T iy = MAX((midIdxC - delta),0);
      int_T ix = MAX((midIdxR - delta),0);
      int_T colPts = 3;
      p = iy;
      while (colPts--) {
        int_T rowPts = 3;
        int_T q = ix;
        while (rowPts--) {
          real_T sum2 = 0.0;
          int_T idxCol_PB = rowsImgPB*p; 
          int_T idxCS = 0;
          int_T m;
          for (m = 0; m < blkCSWidthX; m++) {
            int_T n;
            for (n = 0; n < blkCSHeightY; n++) {
              int_T idxPB = q + n + idxCol_PB;  
              const real_T valPB = blkPB[idxPB];  /* PB = previous image (bigger block) */
              const real_T valCS = blkCS[idxCS+n];/* CS = current image (smaller block) */
              const real_T dist = valPB-valCS;
              /* accumulate sum of absolute differences */
              sum2 +=   fabs(dist);
            }
            idxCS += rowsImgCS;
            idxCol_PB += rowsImgPB;  
          }
          /* Store the new minimum and get the corresponding indices. */
          if (flag == 0) {
            sum3 = sum2;
            yIdx[0] = q;
            xIdx[0] = p;
            flag = 1;
          } else {
            if (sum2 < sum3) {
              sum3 = sum2;
              yIdx[0] = q;
              xIdx[0] = p;
            }
          }
          q += delta;
          while ((rowPts > 0) && (q >= endRowIdx)) q--;
        }
        p += delta;
        while ((colPts > 0) && (p >= endColIdx)) p--;
      }
      midIdxC = xIdx[0];
      midIdxR = yIdx[0];
      delta--;
    }
}

/* [EOF] searchmethod_3step_mad_d_rt.c */
