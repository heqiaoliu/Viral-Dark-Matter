/* Copyright 2007 The MathWorks, Inc. */

/* 
 * File: pil_ide_data_stream.c
 *
 * Processor-in-the-Loop (PIL) data stream over an IDE debugger link
 */

#include "pil_data_stream.h"
#include "pil_interface_lib.h"

/* BUFFER_SIZE must be representable in size_t */
#define BUFFER_SIZE (MIN(MAX_COMMAND_MEM_UNITS, LINK_DATA_BUFFER_SIZE / MEM_UNIT_BYTES))

/* make global so ide's have visibility */
volatile MemUnit_T pil_ide_data_buffer[BUFFER_SIZE];

/* local state */
static size_t readDataAvail;
static size_t writeDataAvail;
static volatile MemUnit_T * readDataPtr;
static volatile MemUnit_T * writeDataPtr;

void pilDataBreakpoint(void) {
    /* reset ptrs
     *
     * assume host writes data in maximal chunks */
    readDataPtr = &pil_ide_data_buffer[0];
    /* host will not always write BUFFER_SIZE MemUnit's 
     * but that's ok because the target side will reset the 
     * pointers at the next breakpoint */
    readDataAvail = BUFFER_SIZE;
    /* assume host reads data in maximal chunks */
    writeDataPtr = &pil_ide_data_buffer[0];   
    writeDataAvail = 0;
}

PIL_DATA_STREAM_ERROR_CODE pilReadData(MemUnit_T * dst, uint32_T size) {
   PIL_DATA_STREAM_ERROR_CODE errorCode = PIL_DATA_STREAM_SUCCESS;
   size_t transferAmount;
   /* block until all data is read */
   while (size > 0) {
      if (readDataAvail == 0) {
         /* breakpoint for host to write data to buffer */
         pilDataBreakpoint();
      }
      transferAmount = (size_t) MIN(readDataAvail, size);
      memcpy(dst, (void *) readDataPtr, transferAmount);
      size -= transferAmount;
      readDataAvail -= transferAmount;
      dst += transferAmount;
      readDataPtr += transferAmount;
   }
   return errorCode;
}

PIL_DATA_STREAM_ERROR_CODE pilWriteData(const MemUnit_T * src, uint32_T size) {
   PIL_DATA_STREAM_ERROR_CODE errorCode = PIL_DATA_STREAM_SUCCESS;
   size_t transferAmount;
   size_t bufferAvail;
   /* block until all data is written */
   while (size > 0) {      
      /* send if we have a full message worth of data */   
      if (writeDataAvail == BUFFER_SIZE) {
         /* breakpoint for host to read data from buffer */
         pilDataBreakpoint();
      }
	  bufferAvail = BUFFER_SIZE - writeDataAvail;
      transferAmount = (size_t) MIN(bufferAvail, size);
      /* copy data into output buffer */
      memcpy((void *) writeDataPtr, src, transferAmount);
      size -= transferAmount;
      writeDataAvail += transferAmount;
      src += transferAmount;
      writeDataPtr += transferAmount;
   }
   return errorCode;
}

PIL_INTERFACE_LIB_ERROR_CODE pilInit(const int argc, 
                                     void *argv[]) {
   /* nothing required */
   UNUSED_PARAMETER(argc);
   UNUSED_PARAMETER(argv);
   return PIL_INTERFACE_LIB_SUCCESS;
}
