/* Copyright 2007 The MathWorks, Inc. */

/* 
 * File: pil_data_stream.h
 *
 * Processor-in-the-Loop (PIL) data stream
 */

#ifndef __PIL_DATA_STREAM_H__
#define __PIL_DATA_STREAM_H__

/* include definition of size_t */
#include <string.h>
/* include rtwtypes.h */
#include "pil_interface_common.h"
/* include definition of MemUnit_T */
#include "pil_interface_data.h"

/* MIN is typically used in data stream implementations */
#ifndef MIN
#define MIN(a,b) ((a) < (b) ? (a) : (b))
#endif

/* define some error codes */
typedef enum {PIL_DATA_STREAM_SUCCESS=0,              
              PIL_READ_DATA_ERROR, 
              PIL_WRITE_DATA_ERROR, 
              PIL_DATA_FLUSH_ERROR} PIL_DATA_STREAM_ERROR_CODE;

/* copy specified amount of data from the input stream to the address specified */
PIL_DATA_STREAM_ERROR_CODE pilReadData(MemUnit_T *, uint32_T); 
/* copy specified amount of data from the address specified to the output stream */
PIL_DATA_STREAM_ERROR_CODE pilWriteData(const MemUnit_T *, uint32_T);

#ifdef LINK_DATA_STREAM
   /* function for Link implementations to set a breakpoint at */
   void pilDataBreakpoint(void);
#else
   /* flush any buffered writes */
   PIL_DATA_STREAM_ERROR_CODE pilDataFlush(void);
#endif

#endif
