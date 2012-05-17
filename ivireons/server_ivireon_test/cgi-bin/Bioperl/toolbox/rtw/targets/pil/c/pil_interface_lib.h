/* Copyright 2006-2009 The MathWorks, Inc. */

/* 
 * File: pil_interface_lib.h
 *
 * Processor-in-the-Loop (PIL) support library
 */

#ifndef __PIL_INTERFACE_LIB_H__
#define __PIL_INTERFACE_LIB_H__

/* define some error codes */
typedef enum {PIL_INTERFACE_LIB_SUCCESS=0, 
              PIL_INTERFACE_LIB_ERROR,
              PIL_INTERFACE_LIB_TERMINATE} PIL_INTERFACE_LIB_ERROR_CODE;

/* pil interface functions to be called from main */
extern PIL_INTERFACE_LIB_ERROR_CODE pilInit(const int argc, 
                                            void *argv[]);
extern PIL_INTERFACE_LIB_ERROR_CODE pilRun(void);

/* terminate PIL communications */
extern PIL_INTERFACE_LIB_ERROR_CODE pilTerminateComms(void);

#endif
