/* Copyright 2007-2009 The MathWorks, Inc. */

/* 
 * File: pil_can_data_stream.c
 *
 * Processor-in-the-Loop (PIL) data stream over CAN
 */

#include "pil_data_stream.h"
#include "pil_interface_lib.h"
#include "can_io_driver.h"

/* support for byte addressable machines only */

#define MAX_PAYLOAD 7

static uint8_T in_msg[8];
static size_t dataInAvail = 0;
static uint8_T * dataInPtr;

static uint8_T out_msg[8];
static size_t dataOutAvail = 0;
static uint8_T * dataOutPtr;

PIL_DATA_STREAM_ERROR_CODE pilReadData(MemUnit_T * dst, uint32_T size) {
   PIL_DATA_STREAM_ERROR_CODE errorCode = PIL_DATA_STREAM_SUCCESS;
   size_t transferAmount;
   /* block until all data is read */
   while (size > 0) {
      if (dataInAvail == 0) {
         /* poll for a message */
         for (;;) {
             if (rxMessage(in_msg)) {
               /* payload is in pos 0 */
               dataInAvail = in_msg[0];
               dataInPtr = &in_msg[1];
               break;
            }
         }
      }
      transferAmount = MIN(dataInAvail, size);
      memcpy(dst, dataInPtr, transferAmount);

      size -= transferAmount;
      dataInAvail -= transferAmount;
      dst += transferAmount;
      dataInPtr += transferAmount;
      if (dataInAvail == 0) {
         /* send ack to allow more data to be sent from host
            host blocks until this ack is received */
         uint8_T msg[8];
         /* first byte is ACK code
          * payload code 0..7, ACK code 8 */
         msg[0] = 8;
         do {} while (!txMessage(msg));       
      }
   }
   return errorCode;
}

PIL_DATA_STREAM_ERROR_CODE pilWriteData(const MemUnit_T * src, uint32_T size) {
   PIL_DATA_STREAM_ERROR_CODE errorCode = PIL_DATA_STREAM_SUCCESS;   
   size_t transferAmount;
   /* block until all data is written */
   while (size > 0) {      
      /* send if we have a full message worth of data */   
      if (dataOutAvail == MAX_PAYLOAD) {
         pilDataFlush();
      }
      transferAmount = MIN(MAX_PAYLOAD - dataOutAvail, size);
      /* copy data into output buffer */
      memcpy(dataOutPtr, src, transferAmount);
      size -= transferAmount;
      dataOutAvail += transferAmount;
      src += transferAmount;
      dataOutPtr += transferAmount;
   }
   return errorCode;
}

PIL_DATA_STREAM_ERROR_CODE pilDataFlush(void) {
   PIL_DATA_STREAM_ERROR_CODE errorCode = PIL_DATA_STREAM_SUCCESS;   
   /* send the data if there is some */
   if (dataOutAvail != 0) {
      /* set the payload */
      out_msg[0] = dataOutAvail;
      do {} while (!txMessage(out_msg));
      /* reset buffer state */
      dataOutAvail = 0;
      dataOutPtr = &out_msg[1];
   }
   return errorCode;
}

PIL_INTERFACE_LIB_ERROR_CODE pilInit(const int argc, 
                                     void *argv[]) {
    PIL_INTERFACE_LIB_ERROR_CODE errorCode = PIL_INTERFACE_LIB_SUCCESS;
    UNUSED_PARAMETER(argc);
    UNUSED_PARAMETER(argv);
    initIO();
    /* These are included to solve a compiler problem on MPC55xx. */
    /* These are also initialised statically above */
    dataInAvail = 0;
    dataOutAvail = 0;
    return errorCode;
}
