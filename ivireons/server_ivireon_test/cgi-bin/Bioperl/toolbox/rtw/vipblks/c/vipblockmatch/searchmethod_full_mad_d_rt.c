/*
 *  SEARCHMETHOD_FULL_MAD_D_RT Helper function for Block Matching block.
 *
 *  Copyright 1995-2008 The MathWorks, Inc.
 *  $Revision: 1.1.10.3 $  $Date: 2008/08/01 12:24:57 $
 */
#include "vipblockmatch_rt.h"  

EXPORT_FCN void MWVIP_SearchMethod_Full_MAD_D(const real_T *blkCS, const real_T *blkPB, /* CS = current image (smaller block), PB = previous image (bigger block) */
                                             int_T rowsImgCS,   int_T rowsImgPB,  
                                             int_T blkCSWidthX, int_T blkCSHeightY,  
                                             int_T blkPBWidthX, int_T blkPBHeightY,  
                                             int_T *xIdx,         int_T *yIdx)
{
    real_T minVal= MAX_real_T; 
    int_T xEnd = blkPBWidthX  - blkCSWidthX  +1; /* 2*maxDX+1 */
    int_T yEnd = blkPBHeightY - blkCSHeightY +1; /* 2*maxDY+1 */
    int_T x,y, c1,r1;

    xIdx[0]=0;
    yIdx[0]=0;

    for (x=0; x<xEnd;x++)
    {
      int_T rowOffsetAll =   x*rowsImgPB; 
      for (y=0; y<yEnd; y++) 
      {
         const real_T *otherBlock = &blkPB[rowOffsetAll+y]; /* searchRegion */
         real_T mysum=0;
         for (c1=0; c1<blkCSWidthX;c1++)
         {
            int_T rowOffsetCS =  c1*rowsImgCS;
            int_T rowOffsetPB =  c1*rowsImgPB;
            for (r1=0; r1<blkCSHeightY; r1++) 
            {
               real_T dist = blkCS[rowOffsetCS+r1] - otherBlock[rowOffsetPB+r1]; 
               mysum += fabs(dist);
            }
         }
        
        if (mysum<minVal)
        {
              minVal=mysum;
              xIdx[0]=x;
              yIdx[0]=y;
        }
      }
    }
}

/* [EOF] searchmethod_full_mad_d_rt.c */
