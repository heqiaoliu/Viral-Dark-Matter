/*
 *  File: cpm_rt.h
 *  Functions for CPM demodulation.
 *
 *  Copyright 1996-2006 The MathWorks, Inc.
 *  $Revision: 1.1.6.3 $ $Date: 2009/03/09 19:25:35 $
 */

#ifndef __CPM_RT_H__
#define __CPM_RT_H__

#include <string.h>
#include "tmwtypes.h"
#include "spc_decl.h"

#ifdef __cplusplus
extern "C" {
#endif

/*---------------------------------------------------------------------------
 * Function: writeBuffer
 * Purpose:  Write count items of dataSize bytes to the buffer. count <= buffLen
 * Pass in:  buffer, input, count, topIdx, DataAvail, buffLen, dataSize
 *---------------------------------------------------------------------------*/
SPC_DECL void writeBuffer(void *buff, const void* input, int32_T count, 
            int32_T *buffTopIdx, int32_T *buffDataAvail, int32_T buffLen,
            int32_T dataSize);


/*---------------------------------------------------------------------------
 * Function: readBuffer
 * Purpose:  Read count items of dataSize bytes from the buffer into output. 
 *           count <= buffLen
 * Pass in:  buffer, output, count, botIdx, DataAvail, buffLen, dataSize 
 *---------------------------------------------------------------------------*/
SPC_DECL void readBuffer(void *buff, void* output, int32_T count, int32_T* buffBotIdx,
                int32_T *buffDataAvail, int32_T buffLen, int32_T dataSize);


#ifdef __cplusplus
} // end of extern "C" scope
#endif

#endif /* [EOF] */
