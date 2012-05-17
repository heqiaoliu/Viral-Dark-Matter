/* Copyright 2006-2010 The MathWorks, Inc. */

/* 
 * File: pil_interface_lib.c
 *
 * Processor-in-the-Loop (PIL) support library
 *
 */

#include "pil_interface_lib.h"
#include "pil_interface_lib_private.h"
#include "pil_data_stream.h"
#include "pil_interface.h"

/* Internal state variable holding information about the
 * Symbol currently being processed. 
 *
 * Note: this variable is shared by UDATA processing code
 * and YDATA processing code and used for all IO.
 *
 */
static Symbol * symbolPtr;

/* static functions */
static void getNextSymbol(void) {
   /* increment symbol ptr if we have not reached the end */
   if (symbolPtr->memUnitLength!=0) {
      symbolPtr++;
   }
}

static PIL_PROCESSDATA_ERROR_CODE processData(PIL_IO_TYPE io_type, 
      uint32_T fcnid, 
      PIL_COMMAND_TYPE_ENUM command,
      uint32_T commandIdx)  {
   PIL_PROCESSDATA_ERROR_CODE processDataErrorCode = PIL_PROCESSDATA_SUCCESS;
   int moreSymbols = 1;
   /* initialise before beginning to process data */
   switch(io_type) {
      case UDATA_IO:
         if (pilGetUDataSymbol(fcnid, command, commandIdx, &symbolPtr)) {
            /* no udata processing to be done - we're complete */
            processDataErrorCode = PIL_PROCESSDATA_SUCCESS;
            return processDataErrorCode;
         }
         break;
      case YDATA_IO:
         if (pilGetYDataSymbol(fcnid, command, commandIdx, &symbolPtr)) {
            /* no ydata processing to be done - we're complete */
            processDataErrorCode = PIL_PROCESSDATA_SUCCESS;
            return processDataErrorCode;
         }
         break;
      default:
         /* programming error */
         processDataErrorCode = PIL_PROCESSDATA_IO_TYPE_ERROR;
         return processDataErrorCode;
   }        
   while(moreSymbols) {
      switch(io_type) {
         case UDATA_IO:
            if (pilReadData(symbolPtr->address, symbolPtr->memUnitLength) != PIL_DATA_STREAM_SUCCESS) {
               processDataErrorCode = PIL_PROCESSDATA_DATA_STREAM_ERROR;
               return processDataErrorCode;
            }
            break;
         case YDATA_IO:
            if (pilWriteData(symbolPtr->address, symbolPtr->memUnitLength) != PIL_DATA_STREAM_SUCCESS) {
               processDataErrorCode = PIL_PROCESSDATA_DATA_STREAM_ERROR;
               return processDataErrorCode;       
            }
            break;
         default:
            /* programming error */
            processDataErrorCode = PIL_PROCESSDATA_IO_TYPE_ERROR;
            return processDataErrorCode;
      }        
      /* get next symbol */
      getNextSymbol();         
      if (symbolPtr->memUnitLength == 0) {
         moreSymbols = 0;
      }
   }
   return processDataErrorCode;
}

#define PIL_COMMAND_TYPE_SIZE sizeof(MemUnit_T)
#define PIL_COMMAND_FCNID_SIZE sizeof(uint32_T)
#define PIL_COMMAND_PILTID_SIZE sizeof(uint32_T)
#define PIL_COMMAND_ERROR_STATUS_SIZE sizeof(MemUnit_T)

#define PIL_RUN_EXIT_ERROR interfaceErrorCode = PIL_INTERFACE_LIB_ERROR; \
                                          return interfaceErrorCode

extern PIL_INTERFACE_LIB_ERROR_CODE pilRun(void) {
   PIL_INTERFACE_LIB_ERROR_CODE interfaceErrorCode = PIL_INTERFACE_LIB_SUCCESS;
   PIL_COMMAND_TYPE_ENUM command;
   MemUnit_T type;  
   MemUnit_T commandError = 0;
   uint32_T fcnid;
   uint32_T pilTID;
   uint32_T commandIdx = 0;
#ifdef LINK_DATA_STREAM
   /* raise the main PIL data breakpoint 
    * to wait for the host to begin the command loop */
   pilDataBreakpoint();
#else
   /* flush the output stream 
    * before beginning next command */
   if (pilDataFlush() != PIL_DATA_STREAM_SUCCESS) {
      PIL_RUN_EXIT_ERROR;      
   }
#endif

   /* read the command code */
   if (pilReadData(&type, PIL_COMMAND_TYPE_SIZE) != PIL_DATA_STREAM_SUCCESS) {
      PIL_RUN_EXIT_ERROR;      
   }

   /* cast from the MemUnit type to the enumeration type */
   command = (PIL_COMMAND_TYPE_ENUM) type;

   /* read fcnid */
   if (pilReadData((MemUnit_T *) &fcnid, PIL_COMMAND_FCNID_SIZE) != PIL_DATA_STREAM_SUCCESS) {
      PIL_RUN_EXIT_ERROR; 
   }

   /* update commandIdx */
   switch(command) {
      case PIL_INIT_COMMAND:
      case PIL_INITIALIZE_COMMAND:
      case PIL_INITIALIZE_CONDITIONS_COMMAND:
      case PIL_CONST_OUTPUT_COMMAND:
      case PIL_TERMINATE_COMMAND:
      case PIL_PROCESS_PARAMS_COMMAND:
         /* no commandIdx */
         break;      
      case PIL_STEP_COMMAND:
      case PIL_ENABLE_COMMAND:
      case PIL_DISABLE_COMMAND:
         /* read pilTID */
         if (pilReadData((MemUnit_T *) &pilTID, PIL_COMMAND_PILTID_SIZE) != PIL_DATA_STREAM_SUCCESS) {
            PIL_RUN_EXIT_ERROR; 
         }
         commandIdx = pilTID;
         break;
      default:
         PIL_RUN_EXIT_ERROR;
   }

   /* process inputs if required by command */
   switch(command) {
      case PIL_INIT_COMMAND:
      case PIL_CONST_OUTPUT_COMMAND:
         /* no inputs */
         break;
      case PIL_INITIALIZE_COMMAND:
      case PIL_INITIALIZE_CONDITIONS_COMMAND:
      case PIL_STEP_COMMAND:
      case PIL_ENABLE_COMMAND:
      case PIL_DISABLE_COMMAND:
      case PIL_TERMINATE_COMMAND:
      case PIL_PROCESS_PARAMS_COMMAND:
         {
            PIL_PROCESSDATA_ERROR_CODE processDataError;
            /* process UData symbols */ 
            processDataError = processData(UDATA_IO, fcnid, command, commandIdx);
            if (processDataError == PIL_PROCESSDATA_DATA_STREAM_ERROR) {
               PIL_RUN_EXIT_ERROR; 
            } else if (processDataError != PIL_PROCESSDATA_SUCCESS) {
               commandError = 1;
            } else {
               commandError = 0;
            }
         }
         break;
      default:
         PIL_RUN_EXIT_ERROR;
   }

   /* call pilInterface function */
   switch(command) {
      case PIL_INIT_COMMAND:
      case PIL_CONST_OUTPUT_COMMAND:
         /* no function */
         break;
      case PIL_PROCESS_PARAMS_COMMAND:         
         if (pilProcessParams(fcnid) != PIL_INTERFACE_SUCCESS) {
            commandError = 1;
         }
         break;
      case PIL_INITIALIZE_COMMAND: 
         if (pilInitialize(fcnid) != PIL_INTERFACE_SUCCESS) {
            commandError = 1;
         }
         break;
      case PIL_INITIALIZE_CONDITIONS_COMMAND:
         if (pilInitializeConditions(fcnid) != PIL_INTERFACE_SUCCESS) {
            commandError = 1;
         }
         break;
      case PIL_STEP_COMMAND: 
         /* call output */
         if (pilOutput(fcnid, pilTID) != PIL_INTERFACE_SUCCESS) {
            commandError = 1;
         }                                         
         break;
      case PIL_TERMINATE_COMMAND:
         if (pilTerminate(fcnid) != PIL_INTERFACE_SUCCESS) {
            commandError = 1;
         }
         break;
      case PIL_ENABLE_COMMAND: 
         if (pilEnable(fcnid, pilTID) != PIL_INTERFACE_SUCCESS) {
            commandError = 1;
         }
         break;
      case PIL_DISABLE_COMMAND: 
         if (pilDisable(fcnid, pilTID) != PIL_INTERFACE_SUCCESS) {
            commandError = 1;
         }
         break;
      default: 
         PIL_RUN_EXIT_ERROR;
   }

   /* process outputs if required by command */
   switch(command) {
      case PIL_INIT_COMMAND:
      case PIL_PROCESS_PARAMS_COMMAND:
         /* no I/O */
         break;
      case PIL_INITIALIZE_COMMAND:
      case PIL_INITIALIZE_CONDITIONS_COMMAND:
      case PIL_CONST_OUTPUT_COMMAND:
      case PIL_STEP_COMMAND:
      case PIL_ENABLE_COMMAND:
      case PIL_DISABLE_COMMAND:
      case PIL_TERMINATE_COMMAND:
         {
            PIL_PROCESSDATA_ERROR_CODE processDataError;
            /* process YData symbols */
            processDataError = processData(YDATA_IO, fcnid, command, commandIdx);
            if (processDataError == PIL_PROCESSDATA_DATA_STREAM_ERROR) {
               PIL_RUN_EXIT_ERROR; 
            } else if (processDataError != PIL_PROCESSDATA_SUCCESS) {
               commandError = 1;
            } else {
               commandError = 0;
            }
         }
         break;      
      default:
         PIL_RUN_EXIT_ERROR;
   }

   if (command == PIL_STEP_COMMAND) {
      /* call update */
      if (pilUpdate(fcnid, pilTID) != PIL_INTERFACE_SUCCESS) {
         commandError = 1;
      }
   }

   /* write command error */
   if (pilWriteData(&commandError, 1) != PIL_DATA_STREAM_SUCCESS) {
      PIL_RUN_EXIT_ERROR;      
   }

   /* Terminate this process when PIL simulation is complete */
   if (command == PIL_TERMINATE_COMMAND) {
       interfaceErrorCode = PIL_INTERFACE_LIB_TERMINATE;
   }

   return interfaceErrorCode;
}
