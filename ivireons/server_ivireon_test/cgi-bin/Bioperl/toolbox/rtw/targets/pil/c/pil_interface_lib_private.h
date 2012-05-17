/* Copyright 2006-2010 The MathWorks, Inc. */

/* 
 * File: pil_interface_lib.h
 *
 * Processor-in-the-Loop (PIL) support library
 */

#ifndef __PIL_INTERFACE_LIB_PRIVATE_H__
#define __PIL_INTERFACE_LIB_PRIVATE_H__

#include "pil_interface_common.h"

/* Enumeration to denote UDATA or YDATA processing */
typedef enum {UDATA_IO = 0, YDATA_IO} PIL_IO_TYPE;

/* define some error codes */
typedef enum {PIL_PROCESSDATA_SUCCESS=0, 
              PIL_PROCESSDATA_DATA_STREAM_ERROR, 
              PIL_PROCESSDATA_IO_TYPE_ERROR} PIL_PROCESSDATA_ERROR_CODE;

/* static functions */
static void getNextSymbol(void);
static PIL_PROCESSDATA_ERROR_CODE processData(PIL_IO_TYPE, uint32_T, PIL_COMMAND_TYPE_ENUM, uint32_T);

#endif
