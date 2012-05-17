/*
 * File: rtwdemo_capi_datalog.h
 * $Revision: 1.1.6.1 $
 * Copyright 2009 The MathWorks, Inc.
 *
 * Abstract:
 *   Header file for example signal and state logging routines using buffers 
 *   of fixed size. See rtwdemo_capi_datalog.c for function definitions
 *
 */

#ifndef _CAPI_LOG_H_
#define _CAPI_LOG_H_

#include <stdio.h>
#include <string.h>
#include <math.h>
#include "rtw_modelmap.h"

#define MAX_DATA_POINTS 5000
#define MAX_NUM_BUFFERS 10

/* LogBuffer structure - Structure to log a state or a signal             */
/* Will be used to store the value of a state/signal as the code executes */
typedef struct LogBuffer_tag {
    char_T     logName[80];     /* State or a Signal name                     */
    void      *dataAddress;     /* Address of data                            */
    void      *re;              /* Real Part - Buffers up the real part       */
    void      *im;              /* Imaginary Part - Buffers up imaginary part */
    real_T     slope;           /* slope if stored as an integer              */
    real_T     bias;            /* bias if stored as integer                  */
    uint8_T    slDataType;      /* Data Type              (Enumerated value)  */
    boolean_T  isCrossingModel;	/* Located in referenced model or top model   */
    boolean_T  isComplex;       /* Complexity of data                         */
}LogBuffer;

/* LogBufferInfo - Structure to log time, state and signal buffers     */
/* Will be used to store a number of states, signals and book-keeping  */
typedef struct LogBufferInfo_tag {
    LogBuffer    *sigBufs;       /* Pointer to logged State Buffers           */
    LogBuffer    *stateBufs;     /* Pointer to logged State Buffers           */
    uint_T        numStateBufs;  /* Number of State Buffers                   */
    uint_T        numSigBufs;    /* Number of Signal Buffers                  */
    time_T       *time;          /* Time buffer                               */    
    uint_T        numDataPoints; /* Number of data points logged per buffer   */
}LogBufferInfo;

/* Logging Functions for Signals and States*/
extern void capi_StartLogging(rtwCAPI_ModelMappingInfo *mmi, 
                              int_T                     maxSize);
extern int capi_UpdateLogging(rtwCAPI_ModelMappingInfo *mmi, 
                              time_T                   *tPtr);
extern void capi_TerminateLogging(const char_T *file);

#endif /* _CAPI_LOG_H_ */

/* EOF rtwdemo_capi_datalog.h */
