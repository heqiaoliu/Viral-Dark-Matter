/* Copyright 2009-2010 The MathWorks, Inc. */
/*
* File: mw_ipp.c
* 
* Abstract: the source file for Mathworks IPP library for video/image processing functions.
*
*/

#include <stdlib.h>
#include "mw_ipp.h"

/*
* Function: mw_ipp_conv2d_single
*
* Abstract: 2D Convolution for single data type
*/
void mw_ipp_conv2d_single(const real32_T u[], const real32_T h[], real32_T y[],
                          const int32_T hDims[], const int32_T hCenter[],
                          const int32_T uDims[], const int32_T uOrigin[],
                          const int32_T yDims[], const int32_T yOrigin[],
                          int32_T inSStart[], int32_T inSEnd[])
{
    /* Process Inner sector. */
    int32_T sStart[2];
    int32_T sEnd[2];
    int32_T offset[2];
    int32_T roiDims[2];
    int32_T uValidOffset;
    int32_T yValidOffset;
    int32_T uStrideInBytes;
    int32_T yStrideInBytes;
    IppiSize dstRoiSize;
    IppiSize kernelSize;
    IppiPoint anchor;

    /* setup indices for the loops */
    offset[0U] = uOrigin[0U] - yOrigin[0U];
    offset[1U] = uOrigin[1U] - yOrigin[1U];
    sStart[0U] = inSStart[0U] + offset[0U];
    sStart[1U] = inSStart[1U] + offset[1U];
    sEnd[0U] = inSEnd[0U] + offset[0U];
    sEnd[1U] = inSEnd[1U] + offset[1U];
    roiDims[0] = sEnd[0] - sStart[0] + 1;
    roiDims[1] = sEnd[1] - sStart[1] + 1;

    uValidOffset = hCenter[0] + hCenter[1] * uDims[0];
    yValidOffset = sStart[0]  + sStart[1]  *yDims[0];
    uStrideInBytes = uDims[0] * sizeof(real32_T);
    yStrideInBytes = yDims[0] * sizeof(real32_T);

    dstRoiSize.width  = roiDims[0];
    dstRoiSize.height = roiDims[1];
    kernelSize.width  = hDims[0];
    kernelSize.height = hDims[1];
    anchor.x = hDims[0] - hCenter[0] - 1;
    anchor.y = hDims[1] - hCenter[1] - 1;

    /* Run IPP routine */
    ippiFilter_32f_C1R(u+uValidOffset, uStrideInBytes, y+yValidOffset, yStrideInBytes, dstRoiSize, h, kernelSize, anchor);
}

/*
* Function: mw_ipp_conv2d_double
*
* Abstract: 2D Convolution for double data type
*/
void mw_ipp_conv2d_double(const real_T u[], const real_T h[], real_T y[],
                          const int32_T hDims[], const int32_T hCenter[],
                          const int32_T uDims[], const int32_T uOrigin[],
                          const int32_T yDims[], const int32_T yOrigin[],
                          int32_T inSStart[], int32_T inSEnd[])
{
    /* Process Inner sector */
    int32_T sStart[2];
    int32_T sEnd[2];
    int32_T offset[2];
    int32_T roiDims[2];
    int32_T uValidOffset;
    int32_T yValidOffset;
    int32_T uStrideInBytes;
    int32_T yStrideInBytes;
    int32_T bufferSize;
    unsigned char *pBuffer;
    IppiSize dstRoiSize;
    IppiSize kernelSize;
    IppiPoint anchor;

    /* setup indices for the loops */
    offset[0U] = uOrigin[0U] - yOrigin[0U];
    offset[1U] = uOrigin[1U] - yOrigin[1U];
    sStart[0U] = inSStart[0U] + offset[0U];
    sStart[1U] = inSStart[1U] + offset[1U];
    sEnd[0U] = inSEnd[0U] + offset[0U];
    sEnd[1U] = inSEnd[1U] + offset[1U];
    roiDims[0] = sEnd[0] - sStart[0] + 1;
    roiDims[1] = sEnd[1] - sStart[1] + 1;

    uValidOffset = hCenter[0] + hCenter[1] * uDims[0];
    yValidOffset = sStart[0]  + sStart[1]  *yDims[0];
    uStrideInBytes = uDims[0] * sizeof(real_T);
    yStrideInBytes = yDims[0] * sizeof(real_T);

    dstRoiSize.width  = roiDims[0];
    dstRoiSize.height = roiDims[1];
    kernelSize.width  = hDims[0];
    kernelSize.height = hDims[1];
    anchor.x = hDims[0] - hCenter[0] - 1;
    anchor.y = hDims[1] - hCenter[1] - 1;

    /* Calculate buffer size */
    ippiFilterGetBufSize_64f_C1R(kernelSize, dstRoiSize.width, &bufferSize);

    /* Allocate buffer */
    pBuffer = NULL;
    if (bufferSize != 0) {
        pBuffer = (unsigned char *)malloc(bufferSize * sizeof(unsigned char));
    }

    /* Run IPP routine */          
    ippiFilter_64f_C1R(u+uValidOffset, uStrideInBytes, y+yValidOffset, yStrideInBytes, dstRoiSize, h, kernelSize, anchor, pBuffer);

    /* Free buffer. */
    if (bufferSize != 0) {
        free(pBuffer);
    }
}

/*
* Function: mw_ipp_corr2d_single
*
* Abstract: 2D Correlation for single data type
*/
void mw_ipp_corr2d_single(const real32_T u[], const real32_T h[], real32_T y[],
                          const int32_T hDims[], const int32_T hCenter[],
                          const int32_T uDims[], const int32_T uOrigin[],
                          const int32_T yDims[], const int32_T yOrigin[],
                          int32_T inSStart[], int32_T inSEnd[])
{
    /* Process Inner sector */
    int32_T sStart[2];
    int32_T sEnd[2];
    int32_T offset[2];
    int32_T roiDims[2];
    int32_T uValidOffset;
    int32_T yValidOffset;
    int32_T uStrideInBytes;
    int32_T yStrideInBytes;
    int32_T i;
    int32_T hLength;
    real32_T* hFlipped = NULL;
    IppiSize dstRoiSize;
    IppiSize kernelSize;
    IppiPoint anchor;

    /* setup indices for the loops */
    offset[0U] = uOrigin[0U] - yOrigin[0U];
    offset[1U] = uOrigin[1U] - yOrigin[1U];
    sStart[0U] = inSStart[0U] + offset[0U];
    sStart[1U] = inSStart[1U] + offset[1U];
    sEnd[0U] = inSEnd[0U] + offset[0U];
    sEnd[1U] = inSEnd[1U] + offset[1U];
    roiDims[0] = sEnd[0] - sStart[0] + 1;
    roiDims[1] = sEnd[1] - sStart[1] + 1;

    uValidOffset = hCenter[0] + hCenter[1] * uDims[0];
    yValidOffset = sStart[0]  + sStart[1]  *yDims[0];
    uStrideInBytes = uDims[0] * sizeof(real32_T);
    yStrideInBytes = yDims[0] * sizeof(real32_T);

    dstRoiSize.width  = roiDims[0];
    dstRoiSize.height = roiDims[1];
    kernelSize.width  = hDims[0];
    kernelSize.height = hDims[1];
    anchor.x = hDims[0] - hCenter[0] - 1;
    anchor.y = hDims[1] - hCenter[1] - 1;

    hLength = hDims[0] * hDims[1];
    hFlipped = (real32_T *)malloc(hLength * sizeof(real32_T));

    if (hFlipped) {
        /* Flip the filter */
        for (i=0, hLength--; i<=hLength; i++) {
            hFlipped[i] = h[hLength-i];
        }

        /* Run IPP routine */
        ippiFilter_32f_C1R(u+uValidOffset, uStrideInBytes, y+yValidOffset, yStrideInBytes, dstRoiSize, hFlipped, kernelSize, anchor);

        free(hFlipped);
    }
}

/*
* Function: mw_ipp_corr2d_double
*
* Abstract: 2D Correlation for double data type
*/
void mw_ipp_corr2d_double(const real_T u[], const real_T h[], real_T y[],
                          const int32_T hDims[], const int32_T hCenter[],
                          const int32_T uDims[], const int32_T uOrigin[],
                          const int32_T yDims[], const int32_T yOrigin[],
                          int32_T inSStart[], int32_T inSEnd[])
{
    /* Process Inner sector */
    int32_T sStart[2];
    int32_T sEnd[2];
    int32_T offset[2];
    int32_T roiDims[2];
    int32_T uValidOffset;
    int32_T yValidOffset;
    int32_T uStrideInBytes;
    int32_T yStrideInBytes;
    int32_T bufferSize;
    unsigned char *pBuffer = NULL;
    int32_T i;
    int32_T hLength;
    real_T* hFlipped = NULL;
    IppiSize dstRoiSize;
    IppiSize kernelSize;
    IppiPoint anchor;

    /* setup indices for the loops */
    offset[0U] = uOrigin[0U] - yOrigin[0U];
    offset[1U] = uOrigin[1U] - yOrigin[1U];
    sStart[0U] = inSStart[0U] + offset[0U];
    sStart[1U] = inSStart[1U] + offset[1U];
    sEnd[0U] = inSEnd[0U] + offset[0U];
    sEnd[1U] = inSEnd[1U] + offset[1U];
    roiDims[0] = sEnd[0] - sStart[0] + 1;
    roiDims[1] = sEnd[1] - sStart[1] + 1;

    uValidOffset = hCenter[0] + hCenter[1] * uDims[0];
    yValidOffset = sStart[0]  + sStart[1]  *yDims[0];
    uStrideInBytes = uDims[0] * sizeof(real_T);
    yStrideInBytes = yDims[0] * sizeof(real_T);

    dstRoiSize.width  = roiDims[0];
    dstRoiSize.height = roiDims[1];
    kernelSize.width  = hDims[0];
    kernelSize.height = hDims[1];
    anchor.x = hDims[0] - hCenter[0] - 1;
    anchor.y = hDims[1] - hCenter[1] - 1;

    /* Calculate buffer size */
    ippiFilterGetBufSize_64f_C1R(kernelSize, dstRoiSize.width, &bufferSize);

    /* Allocate buffer */
    pBuffer = NULL;
    if (bufferSize != 0) {
        pBuffer = (unsigned char *)malloc(bufferSize * sizeof(unsigned char));
    }

    hLength = hDims[0] * hDims[1];
    hFlipped = (real_T *)malloc(hLength * sizeof(real_T));

    if(hFlipped) {
        /* Flip the filter */ 
        for (i=0, hLength--; i<=hLength; i++) {
            hFlipped[i] = h[hLength-i];
        }

        /* Run IPP routine */
        ippiFilter_64f_C1R(u+uValidOffset, uStrideInBytes, y+yValidOffset, yStrideInBytes, dstRoiSize, hFlipped, kernelSize, anchor, pBuffer);
        free(hFlipped);
    }

    if (bufferSize != 0) {
        free(pBuffer);
    }
}
