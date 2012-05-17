/*
 *  BLOCKMATCHING_FULL_MAD_D_RT Helper function for Block Matching block.
 *
 *  Copyright 1995-2008 The MathWorks, Inc.
 *  $Revision: 1.1.10.3 $  $Date: 2008/08/01 12:24:50 $
 */
#include "vipblockmatch_rt.h"  

EXPORT_FCN void MWVIP_BlockMatching_Full_MAD_D(
                                const real_T *uImgCurr,
                                const real_T *uImgPrev,
                                real_T *paddedImgC,
                                real_T *paddedImgP,
                                real_T *yMVsqmag,
                                int32_T *blockSize,
                                int32_T *overlapSize,
                                int32_T *maxDisplSize,
                                const int_T inRows,
                                const int_T inCols,
                                const int_T rowsPadImgC,
                                const int_T colsPadImgC,
                                const int_T rowsPadImgP,
                                const int_T colsPadImgP)
{ 
    int_T i;
    int_T  c1, r1, dx, dy, xIdx=0, yIdx=0;
    real_T *tmpC, *tmpP;
    const real_T *tmpU;

    const int_T blkHeightY = blockSize[0]; /* [rows=Height(y)     cols=width(x)] */
    const int_T blkWidthX  = blockSize[1]; 

    const int_T yOverlap   = overlapSize[0];   
    const int_T xOverlap   = overlapSize[1];

    const int_T maxDY      = maxDisplSize[0];
    const int_T maxDX      = maxDisplSize[1];
      
    const int_T xPadLside = xOverlap/2; /* padding at left */
    const int_T yPadTside = yOverlap/2; /* padding at top  */

    const int_T xIncr = blkWidthX  - xOverlap;
    const int_T yIncr = blkHeightY - yOverlap;

    const int_T searchRegionWidthX  = blkWidthX  + 2*maxDX;
    const int_T searchRegionHeightY = blkHeightY + 2*maxDY;   

    const int_T bytesPerInputCol = inRows*sizeof(real_T);

    const int_T startXpadImgP = maxDX+xPadLside;
    const int_T startYpadImgP = maxDY+yPadTside;

    /*
            ----------> (x = along column)
            |
            |
            |
            |
           \|/
            '  (y = along row)
    */

    if (paddedImgC != uImgCurr)
    {
        /* copy input (uImgCurr) to dwork (paddedImgC) and pad in all sides */
        memset(paddedImgC,0, (rowsPadImgC*colsPadImgC*sizeof(real_T)));
        tmpC = &paddedImgC[xPadLside*rowsPadImgC + yPadTside];
        tmpU = uImgCurr;
        for (i=0; i<inCols; i++) 
        {
        memcpy(tmpC, tmpU, bytesPerInputCol);
        tmpC += rowsPadImgC;
        tmpU += inRows;
        }
    }
    
    /* copy input (uImgPrev) to dwork (paddedImgP) and pad in all sides */

    memset(paddedImgP,0, (rowsPadImgP*colsPadImgP*sizeof(real_T)));
    tmpP = &paddedImgP[startXpadImgP*rowsPadImgP + startYpadImgP];
    tmpU = uImgPrev;
    for (i=0; i<inCols; i++) 
    {
       memcpy(tmpP, tmpU, bytesPerInputCol);
       tmpP += rowsPadImgP;
       tmpU += inRows;
    }

    i=0; 
    for (c1 = startXpadImgP; c1 < colsPadImgP-startXpadImgP-xIncr+1; c1 += xIncr) 
    {
        int_T colIdx = c1-startXpadImgP;
        int_T offsetIdxImgC = colIdx*rowsPadImgC;
        int_T offsetIdxImgP = colIdx*rowsPadImgP;

        for (r1 = startYpadImgP; r1 < rowsPadImgP-startYpadImgP-yIncr+1; r1 += yIncr)
        {
            int_T rowIdx = r1-startYpadImgP;
            
            /* tmpC is pointer to this_block and tmpP is pointer to search_region */
            tmpC = &paddedImgC[offsetIdxImgC + rowIdx];
            tmpP = &paddedImgP[offsetIdxImgP + rowIdx];

            MWVIP_SearchMethod_Full_MAD_D(tmpC,tmpP,
                                          rowsPadImgC,rowsPadImgP,
                                          blkWidthX,blkHeightY,
                                          searchRegionWidthX, searchRegionHeightY,
                                          &xIdx, &yIdx);

            dx = xIdx-maxDX;
            dy = yIdx-maxDY;
            yMVsqmag[i++] = dx*dx + dy*dy; 
        }
    }
}

/* [EOF] blockmatching_full_mad_d_rt.c */
