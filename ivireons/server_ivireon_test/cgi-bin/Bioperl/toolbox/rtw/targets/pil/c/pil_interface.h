/* Copyright 2006-2010 The MathWorks, Inc. */

/* 
 * File: pil_interface.h
 *
 * Processor-in-the-Loop (PIL) interface functions
 */

#ifndef __PIL_INTERFACE_H__
#define __PIL_INTERFACE_H__

/* include rtwtypes.h & Symbol */
#include "pil_interface_common.h"

/* Process Parameters - called from mdlProcessParameters / mdlStart */
extern PIL_INTERFACE_ERROR_CODE pilProcessParams(uint32_T);

/* Initialize - called from mdlStart */
extern PIL_INTERFACE_ERROR_CODE pilInitialize(uint32_T);

/* Initialize Conditions - called from mdlInitializeConditions */
extern PIL_INTERFACE_ERROR_CODE pilInitializeConditions(uint32_T);

/* Initialize a udata Symbol pointer */
extern PIL_INTERFACE_ERROR_CODE pilGetUDataSymbol(uint32_T, PIL_COMMAND_TYPE_ENUM, uint32_T, Symbol **);

/* Output - called from mdlOutputs */
extern PIL_INTERFACE_ERROR_CODE pilOutput(uint32_T, uint32_T);

/* Update - called from mdlOutputs (not mdlUpdate) */
extern PIL_INTERFACE_ERROR_CODE pilUpdate(uint32_T, uint32_T);

/* Initialize a ydata Symbol pointer */
extern PIL_INTERFACE_ERROR_CODE pilGetYDataSymbol(uint32_T, PIL_COMMAND_TYPE_ENUM, uint32_T, Symbol **);

/* Terminate - called from mdlTerminate */
extern PIL_INTERFACE_ERROR_CODE pilTerminate(uint32_T);

/* Enable - called from mdlEnable */
extern PIL_INTERFACE_ERROR_CODE pilEnable(uint32_T, uint32_T);

/* Disable - called from mdlDisable */
extern PIL_INTERFACE_ERROR_CODE pilDisable(uint32_T, uint32_T);

#endif
