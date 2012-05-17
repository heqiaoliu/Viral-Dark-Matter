/* Copyright 2005-2007 The MathWorks, Inc. */

/* $Revision: 1.1.6.2 $ */

#ifndef _FAULT_H_
#define _FAULT_H_

#if defined(MATLAB_MEX_FILE)
#include "mex.h"
#define MY_PRINT mexPrintf
#else
#define MY_PRINT printf
#endif

extern void initFaultCounter(unsigned int *counter);
extern void openLogFile(void **fid);
extern void incAndLogFaultCounter(void *fid, unsigned int *counter, double time);
extern void closeLogFile(void **fid);

#endif
