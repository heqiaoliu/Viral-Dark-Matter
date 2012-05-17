/* Copyright 2006-2009 The MathWorks, Inc. */

/* 
 * File: pil_host_main.c
 *
 * Processor-in-the-Loop (PIL) main
 *
 */ 
#include "pil_interface_lib.h"

int main(const int argc, void * argv[]);

/* PIL Main */
int main(const int argc, void * argv[]) {
   PIL_INTERFACE_LIB_ERROR_CODE errorCode = PIL_INTERFACE_LIB_SUCCESS;
   /* avoid warnings about infinite loops */
   volatile int loop = 1;

   /* PIL initialization */   
   errorCode = pilInit(argc, argv);
   if (errorCode != PIL_INTERFACE_LIB_SUCCESS) {
      /* terminate application */
      return errorCode;
   }
	/* main PIL loop */
   while(loop) {
      errorCode = pilRun();
      if (errorCode != PIL_INTERFACE_LIB_SUCCESS) {
          if (errorCode == PIL_INTERFACE_LIB_TERMINATE) {
              int exitCode; 
              /* orderly shutdown of rtiostream */
              exitCode = pilTerminateComms(); 
              if (exitCode == PIL_INTERFACE_LIB_SUCCESS) {
                  exitCode = 0;
              }
              /* terminate */
              return exitCode;
          } else {
              /* terminate with error code */
              return errorCode;
          }
      }
   } 
   return errorCode;
}
