/* Copyright 2007-2009 The MathWorks, Inc. */

/* 
 * File: pil_rtio_data_stream.c
 *
 * Processor-in-the-Loop (PIL) data stream over the rtIOStream
 * NOTE: the pil_ide_data_stream.c implementation does not use this module
 *
 */					 

/* include PIL data stream interface to implement */
#include "pil_data_stream.h"
/* include PIL initialization interface to implement */
#include "pil_interface_lib.h"
/* include rtIOStream interface to use */
#include "rtiostream.h"

/* define SIZE_MAX if not already 
 * defined (e.g. by a C99 compiler) */
#ifndef SIZE_MAX
#define SIZE_MAX ((size_t)-1)
#endif

/* define a buffer to be used for concatenating small 
 * data writes into chunks of reasonable size for transmission */
#ifndef MAX_WRITE_BUFFER_SIZE 
#define MAX_WRITE_BUFFER_SIZE 300 
#endif
/* WRITE_BUFFER_SIZE must be representable in size_t */
#define WRITE_BUFFER_SIZE (MIN(MAX_COMMAND_MEM_UNITS, MAX_WRITE_BUFFER_SIZE / MEM_UNIT_BYTES))

static MemUnit_T writeBuffer[WRITE_BUFFER_SIZE];
static MemUnit_T * writeDataPtr;
static size_t writeDataAvail;

/* store stream handle returned by rtio data stream */
static int streamID;

/* call rtIOStreamSend taking care of SIZE_MAX */
static PIL_DATA_STREAM_ERROR_CODE pilRtIOStreamSend(const MemUnit_T * src, uint32_T size) {
   PIL_DATA_STREAM_ERROR_CODE errorCode = PIL_DATA_STREAM_SUCCESS;
   size_t transferAmount;
   size_t sizeSent;
   int errorStatus;
   while (size > 0) {
      /* support full uint32 size */
      transferAmount = (size_t) MIN(SIZE_MAX, size);
      errorStatus = rtIOStreamSend(streamID, 
            (const void *) src, 
            transferAmount, 
            &sizeSent);
      if (errorStatus == RTIOSTREAM_ERROR) {
         errorCode = PIL_WRITE_DATA_ERROR;
         return errorCode;
      }
      else {
         size -= (uint32_T) sizeSent;
         src += sizeSent;
      }
   }
   return errorCode;
}

/* reset the write buffer */
static void resetWriteBuffer(void) {
   writeDataAvail = 0;
   writeDataPtr = &writeBuffer[0];
}

/* flush pending writes */
static PIL_DATA_STREAM_ERROR_CODE flushWriteBuffer(void) {
   PIL_DATA_STREAM_ERROR_CODE errorCode = PIL_DATA_STREAM_SUCCESS;
   if (writeDataAvail > 0) {
      /* flush */
      if (pilRtIOStreamSend(&writeBuffer[0], writeDataAvail) != PIL_DATA_STREAM_SUCCESS) { 
         /* throw flush error */
         errorCode = PIL_DATA_FLUSH_ERROR;
         return errorCode;
      }
      /* reset */
      resetWriteBuffer();
   }
   return errorCode;
}

PIL_INTERFACE_LIB_ERROR_CODE pilInit(const int argc, 
                                     void *argv[]) {   
   PIL_INTERFACE_LIB_ERROR_CODE errorCode = PIL_INTERFACE_LIB_SUCCESS;
   resetWriteBuffer();
   streamID = rtIOStreamOpen(argc, argv);
   if (streamID == RTIOSTREAM_ERROR) {
      errorCode = PIL_INTERFACE_LIB_ERROR;
   }
   return errorCode;
}

/* This function must be called prior to terminating the application in order to
 * ensure an orderly shutdown of communications, e.g. all data must be
 * flushed */
PIL_INTERFACE_LIB_ERROR_CODE pilTerminateComms(void) {
   int errorStatus;
   PIL_INTERFACE_LIB_ERROR_CODE errorCode = PIL_INTERFACE_LIB_SUCCESS;
   /* flush pending data */
   if (flushWriteBuffer() != PIL_DATA_STREAM_SUCCESS) {
      errorCode = PIL_INTERFACE_LIB_ERROR;
      return errorCode;
   }
   errorStatus = rtIOStreamClose(streamID);
   if (errorStatus == RTIOSTREAM_ERROR) {
      errorCode = PIL_INTERFACE_LIB_ERROR;
   }
   return errorCode;
}


PIL_DATA_STREAM_ERROR_CODE pilWriteData(const MemUnit_T * src, uint32_T size) {
   PIL_DATA_STREAM_ERROR_CODE errorCode = PIL_DATA_STREAM_SUCCESS;
   size_t transferAmount;
   size_t bufferAvail;

   if (size > WRITE_BUFFER_SIZE) {
      /* large chunk of data to write
       *
       * flush pending data */
      errorCode = flushWriteBuffer();
      if (errorCode != PIL_DATA_STREAM_SUCCESS) {
         return errorCode;
      }
      /* direct write */
      errorCode = pilRtIOStreamSend(src, size);
      if (errorCode != PIL_DATA_STREAM_SUCCESS) {
         return errorCode;
      }    
   }
   else {
      /* block until all data is processed */
      while (size > 0) {      
         /* flush if we have a full message worth of data */   
         if (writeDataAvail == WRITE_BUFFER_SIZE) {
            errorCode = flushWriteBuffer();
            if (errorCode != PIL_DATA_STREAM_SUCCESS) {
               return errorCode;
            }
         }
         bufferAvail = WRITE_BUFFER_SIZE - writeDataAvail;
         transferAmount = (size_t) MIN(bufferAvail, size);
         /* copy data into write buffer */
         memcpy((void *) writeDataPtr, src, transferAmount);
         size -= transferAmount;
         writeDataAvail += transferAmount;
         src += transferAmount;
         writeDataPtr += transferAmount;
      }
   }
   return errorCode;
}

PIL_DATA_STREAM_ERROR_CODE pilReadData(MemUnit_T * dst, uint32_T size) {
   PIL_DATA_STREAM_ERROR_CODE errorCode = PIL_DATA_STREAM_SUCCESS;
   size_t transferAmount;
   size_t sizeRecvd;
   int errorStatus;
   while (size > 0) {
      /* support full uint32 size */
      transferAmount = (size_t) MIN(SIZE_MAX, size);
      errorStatus = rtIOStreamRecv(streamID, 
            (void *) dst, 
            transferAmount, 
            &sizeRecvd);
      if (errorStatus == RTIOSTREAM_ERROR) {
         errorCode = PIL_READ_DATA_ERROR;
         return errorCode;
      }
      else {
         size -= (uint32_T) sizeRecvd;
         dst += sizeRecvd;
      }
   }
   return errorCode;
}

PIL_DATA_STREAM_ERROR_CODE pilDataFlush(void) {
   PIL_DATA_STREAM_ERROR_CODE errorCode = PIL_DATA_STREAM_SUCCESS;
   /* flush the write buffer */
   errorCode = flushWriteBuffer();
   return errorCode;
}
