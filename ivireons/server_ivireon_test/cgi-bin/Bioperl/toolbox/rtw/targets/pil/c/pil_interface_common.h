/* Copyright 2006-2010 The MathWorks, Inc. */

/*
 * File: pil_interface_common.h
 *
 * Processor-in-the-Loop (PIL) common definitions
 */

#ifndef __PIL_INTERFACE_COMMON_H__
#define __PIL_INTERFACE_COMMON_H__

#include "rtwtypes.h"
#include "pil_interface_data.h"

/* define some error codes */
typedef enum {PIL_INTERFACE_SUCCESS=0, 
              PIL_INTERFACE_UNKNOWN_TID,
              PIL_INTERFACE_UNKNOWN_FCNID} PIL_INTERFACE_ERROR_CODE;

typedef enum {PIL_INIT_COMMAND = 0, 
              PIL_INITIALIZE_COMMAND,
              PIL_INITIALIZE_CONDITIONS_COMMAND,
              PIL_STEP_COMMAND, 
              PIL_TERMINATE_COMMAND, 
              PIL_ENABLE_COMMAND,
              PIL_DISABLE_COMMAND, 
              PIL_CONST_OUTPUT_COMMAND, 
              PIL_PROCESS_PARAMS_COMMAND} PIL_COMMAND_TYPE_ENUM;
                            
/* Code symbol is defined as a start address
 * and length in MemUnits */
typedef struct symbol {
   uint32_T memUnitLength;
   MemUnit_T * address;
} Symbol;

/*
 * UNUSED_PARAMETER(x)
 *   Used to specify that a function parameter (argument) is required but not
 *   accessed by the function body.
 */
#ifndef UNUSED_PARAMETER
# if defined(__LCC__)
#   define UNUSED_PARAMETER(x)                                   /* do nothing */
# else

/*
 * This is the semi-ANSI standard way of indicating that an
 * unused function parameter is required.
 */
#   define UNUSED_PARAMETER(x)         (void) (x)
# endif
#endif

#endif
