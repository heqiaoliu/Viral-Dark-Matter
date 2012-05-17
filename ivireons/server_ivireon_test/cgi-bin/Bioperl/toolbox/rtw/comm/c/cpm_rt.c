/*
 *  File: cpm_rt.c
 *  Functions for RTW use.
 *
 *  Copyright 1996-2006 The MathWorks, Inc.
 *  $Revision: 1.1.6.3 $ $Date: 2009/03/09 19:25:14 $
 */

#include "cpm_rt.h"

/*---------------------------------------------------------------------------
 * Function: writeBuffer
 * Purpose:  Write count items of dataSize bytes to the buffer. count <= buffLen
 * Pass in:  buffer, input, count, topIdx, DataAvail, buffLen, dataSize
 *---------------------------------------------------------------------------*/
SPC_DECL void writeBuffer(void *buff, const void* input, int32_T count,
            int32_T *buffTopIdx, int32_T *buffDataAvail, int32_T buffLen,
            int32_T dataSize)
{
    int32_T countIdx;
	for(countIdx = 0; countIdx < count; countIdx++) {
        int32_T srcIdx, dstIdx;

        srcIdx = dataSize * countIdx;
        dstIdx = dataSize * ((buffTopIdx[0] + countIdx) % buffLen);

        memcpy((unsigned char *)buff+dstIdx, (const unsigned char *)input+srcIdx, dataSize);
	}

	/* --- Update index values */
	buffTopIdx[0] = (buffTopIdx[0] + count) % buffLen;
	buffDataAvail[0] += count;
}


/*---------------------------------------------------------------------------
 * Function: readBuffer
 * Purpose:  Read count items of dataSize bytes from the buffer into output. 
 *           count <= buffLen
 * Pass in:  buffer, output, count, botIdx, DataAvail, buffLen, dataSize 
 *---------------------------------------------------------------------------*/
SPC_DECL void readBuffer(void *buff, void* output, int32_T count, int32_T* buffBotIdx,
                int32_T *buffDataAvail, int32_T buffLen, int32_T dataSize)
{
    int32_T countIdx;

	for(countIdx = 0; countIdx < count; countIdx++) {
        int32_T srcIdx, dstIdx;

        srcIdx = dataSize * ((buffBotIdx[0] + countIdx) % buffLen);
        dstIdx = dataSize * countIdx;

        memcpy((unsigned char *)output+dstIdx, (unsigned char *)buff+srcIdx, dataSize);
    }

	/* --- Update index values */
	buffBotIdx[0]  = (buffBotIdx[0]+count) % buffLen;
	buffDataAvail[0] -= count;
}

/* [EOF] */
