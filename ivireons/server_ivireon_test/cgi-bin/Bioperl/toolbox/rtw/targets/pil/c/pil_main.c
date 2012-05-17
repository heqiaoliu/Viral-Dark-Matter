/* Copyright 2006-2009 The MathWorks, Inc. */

/* 
 * File: pil_main.c
 *
 * Processor-in-the-Loop (PIL) main
 *
 */ 

#include "pil_interface_lib.h"

int main(void);

/* PIL Main */
int main(void) {
   PIL_INTERFACE_LIB_ERROR_CODE errorCode = PIL_INTERFACE_LIB_SUCCESS;
   /* avoid warnings about infinite loops */
   volatile int loop = 1;
   /* PIL initialization */   
   const int argc = 0;
   void * argv = (void *) 0;
   errorCode = pilInit(argc, argv);
   if (errorCode != PIL_INTERFACE_LIB_SUCCESS) {
      /* trap error with infinite loop */
      while (loop) {
      }
   }
   /* main PIL loop */
   while(loop) {
      errorCode = pilRun();
      if ( (errorCode != PIL_INTERFACE_LIB_SUCCESS) && 
           (errorCode != PIL_INTERFACE_LIB_TERMINATE) ) {
          /* trap error with infinite loop */
          while (loop) {
          }
      }
   } 
   return errorCode;
}
