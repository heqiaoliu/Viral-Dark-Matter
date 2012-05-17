/* 
 * File: rtwdemo_capi_datalog.c
 * $Revision: 1.1.6.1 $
 * Copyright 2009 The MathWorks, Inc.
 *
 * Abstract:
 *      Signal and State logging routines using buffers of fixed size.
 *
 *      The routines are provided to demonstrate the use of C API for
 *      signal and state logging. In particular, the routines show how to
 *      access a signal's and/or state's address and its attributes.
 *
 *      The logging buffers are initialized at start of the simulation (in 
 *      model_Start or model_Initialize), filled in at each major time
 *      step in (model_step) and finally written to a text-file at the end 
 *      of the simulation. Please make sure that you select the "Terminate 
 *      function required" option for Embedded coder target.
 *      
 *      Note - This application uses data type definitions defined in 
 *      rtwtypes.h. Please refer to this file for the exact typedefs 
 *      of various data types.
 */

#include "rtwdemo_capi_datalog.h"

/* static sbInfo for storing all signal and state values 
 * - Memory for buffers allocated in function capi_StartLogging
 * - Memory for buffers freed in function capi_TerminateLogging
 * - State/Signal values added to the buffer in function capi_UpdateLogging
 */
static LogBufferInfo *sbInfo;

/* Forward declaration of file scope functions */
static void loc_SetupSignalBuffer(rtwCAPI_ModelMappingInfo *mmi, 
                                  boolean_T		    isCrossingModel, 
                                  int_T			    maxSize);
static void loc_SetupStateBuffer(rtwCAPI_ModelMappingInfo *mmi, 
                                 boolean_T		   isCrossingModel, 
                                 int_T			   maxSize);
static void loc_UpdateLogBuffer(LogBuffer *logBuf,
                                uint_T     numDataPoints);
static void loc_writeBuffer(FILE *fptr, LogBuffer *logBuf, uint_T nPoint);


/*
 * Function: capi_StartLogging
 * Abstract:
 *   Initiate logging signals and states. Could be called during model 
 *   initialization.
 *   Does the following
 *     - Allocates memory for signal and state buffers. The number of signal/
 *       state buffers that get allocated memory depends on the number of 
 *       signals/states in the model (up to a maximum of 10 buffers). If there 
 *       are no signals/states, no memory is allocated.
 *     - Allocates memory for logging time values.
 *     - Calls local function, loc_SetupSignalBuffer. The function gets signals 
 *       description from the C API. Determines if the signal can be added to 
 *       the buffer. Only scalar named signals can be added to the buffer.
 *     - Calls local function, loc_SetupStateBuffer. The function gets states 
 *       description from the C API. Determines if the state can be added to 
 *       the buffer. Only scalar named states can be added to the buffer.
 * 
 *  Example usage
 *   In model initialization function
     {                                                                                            
       rtwCAPI_ModelMappingInfo *MMI = &(rtmGetDataMapInfo(rtwdemo_capi_M).mmi);              
       printf("** Started state/signal logging via C API **\n");                                         
       capi_StartLogging(MMI, MAX_DATA_POINTS);                                              
     }
 */
void capi_StartLogging(rtwCAPI_ModelMappingInfo*  mmi, 
                       int_T                      maxSize)
{    
    
    int_T numSignals = rtwCAPI_GetNumSigLogRecords(mmi);
    int_T numStates  = rtwCAPI_GetNumStateRecords(mmi);
    
    /* Assign memory to the global variable sbInfo */
    sbInfo = (LogBufferInfo *) malloc(sizeof(LogBufferInfo));
    
    /* Allocate memory for logging time */
    sbInfo->time = (time_T *) calloc(maxSize, sizeof(time_T));
    
    /* Set number of points logged to zero */
    sbInfo->numDataPoints = 0;   
    
    /* Initialize the number of signal buffers to 0 */
    sbInfo->numSigBufs = 0;
    
    /* Initialize signal logging buffer */
    if (numSignals > 0) {		
        /* Assign memory for signals (maximum 10 signals) */
        int_T numBuffers = (numSignals < (MAX_NUM_BUFFERS)) ? 
            (numSignals) : (MAX_NUM_BUFFERS);
        sbInfo->sigBufs  = (LogBuffer *) calloc(numBuffers, sizeof(LogBuffer));
        
        /* Populate Signal Logging Buffers */
        loc_SetupSignalBuffer(mmi, 0, maxSize);
        
    }
    
    /* Initialize the number of state buffers to 0 */
    sbInfo->numStateBufs = 0;
    
    /* Initialize state logging buffer */
    if (numStates > 0) {              
        /* Assign memory for states (maximum 10 states) */
        int_T numBuffers  = (numStates< (MAX_NUM_BUFFERS)) ? 
            (numStates) : (MAX_NUM_BUFFERS);
        sbInfo->stateBufs = (LogBuffer *) calloc(numBuffers, sizeof(LogBuffer));
        
        /* Populate State Logging Buffers */
        loc_SetupStateBuffer(mmi,  0, maxSize);
    }
    
    if ((sbInfo->numSigBufs>0) || (sbInfo->numStateBufs>0)) {
        printf("** Logging %d signal(s) and %d state(s). ", 
               sbInfo->numSigBufs, sbInfo->numStateBufs);
        printf("In this demo, only scalar named signals/states are logged **\n");
    }
}

/*
 * Function: capi_UpdateLogging
 * Abstract:
 *   Update/log state/signal values into state/signal buffer. This function 
 *   could be called during model outputs/step phase.
 *   Does the following
 *     - Updates the time value
 *     - Calls local function, loc_UpdateLogBuffer for each signal and state 
 *       buffer. The function:
 *       -- Gets the value of the state/signal from the state/signal address.
 *       -- Assigns/Updates the value to the corresponding buffer
 *  Example usage
 *   In model output function:
     {                                                                                            
       rtwCAPI_ModelMappingInfo *MMI = &(rtmGetDataMapInfo(rtwdemo_capi_M).mmi); 
       capi_UpdateLogging(MMI, rtmGetTPtr(rtwdemo_capi_M)); 
     } 
 */
int capi_UpdateLogging(rtwCAPI_ModelMappingInfo* mmi, time_T *tPtr)
{
    /* Local variable */
    uint_T idx;
    
    /* Return if Maximum data points limit is reached */
    if (sbInfo->numDataPoints >= MAX_DATA_POINTS){
        return 0;
    }
    
    /* Update time */
    sbInfo->time[sbInfo->numDataPoints] = *tPtr;
    
    /* Update Signal buffers */
    for (idx = 0; idx < sbInfo->numSigBufs; idx++) {
        loc_UpdateLogBuffer(&sbInfo->sigBufs[idx],
                            sbInfo->numDataPoints);			
    }
    
    /* Update State buffers */
    for (idx = 0; idx < sbInfo->numStateBufs; idx++) {
        loc_UpdateLogBuffer(&sbInfo->stateBufs[idx],
                            sbInfo->numDataPoints);			
    }
    
    /* Increment number of points logged */
    sbInfo->numDataPoints = sbInfo->numDataPoints + 1;
    
    return 1;
}

/*
 * Function: capi_TerminateLogging
 * Abstract:
 *   Stop logging states/signals and write to file. Could be called during model 
 *   termination.
 *   Does the following
 *     - Opens file and writes the values from buffers into the file as text 
 *       (with helper function, loc_writeBuffer).
 *     - Frees memory for state/signal buffers and time buffer.
 *  Example usage
 *   In model terminate function:
     {                                                                                            
       capi_TerminateLogging("rtwdemo_capi_ModelLog.txt");  
       printf("** Finished state/signal logging. Created rtwdemo_capi_ModelLog.txt **\n");   
     }
*/
void capi_TerminateLogging(const char_T *file)
{
    FILE *fptr;
    uint_T nBuffers;
    
    /* Create a text file */
    if((fptr = fopen(file, "wb")) == NULL) {
        (void) fprintf(stderr, "***Error opening %s", file);
    }
    
    /* Write the Signal Buffers in the sbInfo structure into 
       the text file */	
    if (sbInfo->numSigBufs > 0) {
        uint_T nData, nPoint;
        
        fprintf(fptr,"******** Signal Log File ******** \n\n");
        fprintf(fptr,"Number of Signals Logged: %d\n", sbInfo->numSigBufs);
        fprintf(fptr,"Number of points (time steps) logged: %d\n\n", 
                sbInfo->numDataPoints);
        
        fprintf(fptr,"%-15.4s","Time");
        for(nData = 0; nData < sbInfo->numSigBufs; nData ++) {
            
            if (!sbInfo->sigBufs[nData].isCrossingModel) {
                fprintf(fptr, "%-40.30s",sbInfo->sigBufs[nData].logName);	
            } else {
                char *str1 = sbInfo->sigBufs[nData].logName;
                char str2[50];
                sprintf(str2, " (Referenced Model)");
                fprintf(fptr, "%-40.30s",strcat(str1,str2));
            }
        }
        fprintf(fptr, "\n");
        
        for(nPoint = 0; nPoint < sbInfo->numDataPoints; nPoint++) {
            fprintf(fptr,"%-15.4G", sbInfo->time[nPoint]);
            for(nData = 0; nData < sbInfo->numSigBufs; nData ++) {
                loc_writeBuffer(fptr, &sbInfo->sigBufs[nData], nPoint);
            }
            fprintf(fptr, "\n");
        }
        
        fprintf(fptr, "\n");
        fprintf(fptr, "\n");
        
        /* free up memory */
        for(nBuffers = 0; nBuffers < sbInfo->numSigBufs; nBuffers++) {
            free(sbInfo->sigBufs[nBuffers].re);
            free(sbInfo->sigBufs[nBuffers].im);
        }
        free(sbInfo->sigBufs);		
    }
    
    /* Write the State Buffers in the sbInfo structure into 
       the text file */	
    if (sbInfo->numStateBufs > 0) {
        uint_T nData, nPoint;
        
        fprintf(fptr,"******** State Log File ******** \n\n");
        fprintf(fptr,"Number of States Logged: %d\n", sbInfo->numStateBufs);
        fprintf(fptr,"Number of points (time steps) logged: %d\n\n", 
                sbInfo->numDataPoints);
        
        fprintf(fptr,"%-15.4s","Time");
        for(nData = 0; nData < sbInfo->numStateBufs; nData ++) {
            
            if (!sbInfo->stateBufs[nData].isCrossingModel) {
                fprintf(fptr, "%-40.30s",sbInfo->stateBufs[nData].logName);					
            } else {
                char *str1 = sbInfo->stateBufs[nData].logName;
                char str2[50];
                sprintf(str2, " (Referenced Model)");
                fprintf(fptr, "%-40.30s",strcat(str1,str2));
            }
        }
        fprintf(fptr, "\n");
        
        for(nPoint = 0; nPoint < sbInfo->numDataPoints; nPoint++) {
            fprintf(fptr,"%-15.4G", sbInfo->time[nPoint]);
            for(nData = 0; nData < sbInfo->numStateBufs; nData ++) {
                loc_writeBuffer(fptr, &sbInfo->stateBufs[nData], nPoint);
            }
            fprintf(fptr, "\n");
        }
        
        /* free up memory */
        for(nBuffers = 0; nBuffers < sbInfo->numStateBufs; nBuffers++) {
            free(sbInfo->stateBufs[nBuffers].re);
            free(sbInfo->stateBufs[nBuffers].im);
        }		
        free(sbInfo->stateBufs); 
    }
        
    free(sbInfo->time);
    free(sbInfo);    
    
    /* Close the file */
    fclose(fptr);
}


/* ******************** Helper Functions ****************************** */

/*
 * Function: loc_SetupStateBuffer
 * Abstract:
 *   Helper function. Populate state buffer with states information from C API.
 */
static void loc_SetupStateBuffer(rtwCAPI_ModelMappingInfo *mmi, 
                                 boolean_T		   isCrossingModel, 
                                 int_T			   maxSize) {
    
    int_T		        i;
    int_T			nCMMI;
    int_T			nStates;
    const rtwCAPI_States       *states;
    const rtwCAPI_DimensionMap *dimMap;
    const uint_T*		dimArray;
    const rtwCAPI_DataTypeMap  *dataTypeMap;
    void**			dataAddrMap;
    rtwCAPI_FixPtMap     const *fxpMap   = rtwCAPI_GetFixPtMap(mmi);   
    
    /* Loop through every referenced model and populate state buffer */
    nCMMI = rtwCAPI_GetChildMMIArrayLen(mmi);
    for (i = 0; i < nCMMI; ++i) {
        rtwCAPI_ModelMappingInfo* cMMI = rtwCAPI_GetChildMMI(mmi,i);
                                 /* isCrossingModel == true */
        loc_SetupStateBuffer(cMMI, 1                        , maxSize);
    }
    
    nStates	= rtwCAPI_GetNumStates(mmi);
    states      = rtwCAPI_GetStates(mmi);
    dimMap      = rtwCAPI_GetDimensionMap(mmi);
    dimArray    = rtwCAPI_GetDimensionArray(mmi);
    dataTypeMap = rtwCAPI_GetDataTypeMap(mmi);
    dataAddrMap = rtwCAPI_GetDataAddressMap(mmi);
    
    /* Populate state buffers (up to  MAX_NUM_BUFFERS buffers) */
    for (i = 0; (i < nStates) && (sbInfo->numStateBufs < (MAX_NUM_BUFFERS)); ++i) {
        uint_T              addrIdx;        
         
        /* Get the actual dimensions of the state from the Dimension Map */
        uint_T		   *dims;
        uint16_T	    dimIdx    = rtwCAPI_GetStateDimensionIdx(states,i);
        uint8_T             nDims     = rtwCAPI_GetNumDims(dimMap, dimIdx);
        rtwCAPI_Orientation orient    = rtwCAPI_GetOrientation(dimMap,dimIdx);
        uint_T              dIndex    = rtwCAPI_GetDimArrayIndex(dimMap, dimIdx);
        
        /* State's Data Type information */
        uint16_T            dTypeIdx  =  rtwCAPI_GetStateDataTypeIdx(states,i);
        uint16_T            dataSize  = rtwCAPI_GetDataTypeSize(dataTypeMap,
                                                                dTypeIdx);
        
        /* Get State name from the State structure */
        char_T const       *stateName =  rtwCAPI_GetStateName(states, i);
        
        /* Extract a state buffer */
        LogBuffer          *stateBuf  = &sbInfo->stateBufs[sbInfo->numStateBufs];
	
        /* State's Fixed Point information */
        uint16_T           fxpIdx     =  rtwCAPI_GetStateFixPtIndex(states,i); 
        real_T             fSlope     = 1.0;
        real_T             fBias      = 0.0;
        int8_T             fExp	      = 0;
        if(rtwCAPI_GetFxpFracSlopePtr(fxpMap,fxpIdx) != NULL) {
            fSlope		      = rtwCAPI_GetFxpFracSlope(fxpMap,fxpIdx);       
            fBias		      = rtwCAPI_GetFxpBias(fxpMap,fxpIdx); 
            fExp		      = rtwCAPI_GetFxpExponent(fxpMap,fxpIdx); 
        }
        
        dims			     = (uint_T *) calloc(nDims, sizeof(uint_T));
        for(dimIdx=0; dimIdx<nDims; dimIdx++) {
            dims[dimIdx]= dimArray[dIndex + dimIdx];
        } 
	
        /* Record only named scalar states */
        if(!(orient == rtwCAPI_SCALAR && (strcmp(stateName,"NULL") && 
                                          strcmp(stateName,"")))) {
            continue;
        }
        
        /* Set State Name */
        stateBuf->logName[80]	='\0';
        strncpy(stateBuf->logName,rtwCAPI_GetStateName(states, i),80);
        
        /* Set State Data Type */
        stateBuf->slDataType = rtwCAPI_GetDataTypeSLId(dataTypeMap, dTypeIdx);
        
        /* Set State Data Complexity */
        stateBuf->isComplex  = rtwCAPI_GetDataIsComplex(dataTypeMap,dTypeIdx);
        
        /* Allocate memory for the real part */
        stateBuf->re	   = (void *) calloc(dims[0]*dims[1]*maxSize, dataSize);

        /* Allocate memory for imaginary part */
        if(stateBuf->isComplex) {
            stateBuf->im   = (void *) calloc(dims[0]*dims[1]*maxSize, dataSize);
        }
        
        /* States slope and Bias */
        stateBuf->slope	   = (fSlope * pow(2, fExp));
        stateBuf->bias	   = fBias;
	
        /* Is the State in a referenced model? */
        stateBuf->isCrossingModel = isCrossingModel;		
	
        /* Set State Address */
        addrIdx			= rtwCAPI_GetStateAddrIdx(states,i);
        stateBuf->dataAddress	= dataAddrMap[addrIdx];
        
        /* Increment buffer number */
        sbInfo->numStateBufs    = sbInfo->numStateBufs + 1;

        /* Free dims memory */
        free(dims);
    }
}

/*
 * Function: loc_SetupSignalBuffer
 * Abstract:
 *   Helper function. Populate signal buffer with signals information from C API.
 */
static void loc_SetupSignalBuffer(rtwCAPI_ModelMappingInfo *mmi, 
                                  boolean_T		    isCrossingModel, 
                                  int_T			    maxSize) {
    
    int_T			i;
    int_T			nCMMI;
    int_T			nSignals;
    const rtwCAPI_Signals      *signals;
    const rtwCAPI_DimensionMap *dimMap;
    const uint_T*		dimArray;
    const rtwCAPI_DataTypeMap  *dataTypeMap;
    void**			dataAddrMap;
    const rtwCAPI_FixPtMap     *fxpMap   = rtwCAPI_GetFixPtMap(mmi);
    
    /* Loop through every referenced model and populate signal buffer */
    nCMMI = rtwCAPI_GetChildMMIArrayLen(mmi);
    for (i = 0; i < nCMMI; ++i) {
        rtwCAPI_ModelMappingInfo* cMMI = rtwCAPI_GetChildMMI(mmi,i);
                                  /* isCrossingModel == true */
        loc_SetupSignalBuffer(cMMI, 1                         , maxSize);
    }
    
    nSignals	= rtwCAPI_GetNumSignals(mmi);
    signals     = rtwCAPI_GetSignals(mmi);
    dimMap      = rtwCAPI_GetDimensionMap(mmi);
    dimArray    = rtwCAPI_GetDimensionArray(mmi);
    dataTypeMap = rtwCAPI_GetDataTypeMap(mmi);
    dataAddrMap = rtwCAPI_GetDataAddressMap(mmi);

    /* Populate signal buffers (up to  MAX_NUM_BUFFERS buffers) */
    for (i = 0; (i < nSignals) && (sbInfo->numSigBufs < (MAX_NUM_BUFFERS)); ++i) {
        uint_T      addrIdx; 
         	
        /* Signal's Dimension information */
        uint_T             *dims;
        uint16_T	    dimIdx   = rtwCAPI_GetSignalDimensionIdx(signals,i);
        uint8_T             nDims    = rtwCAPI_GetNumDims(dimMap, dimIdx);
        rtwCAPI_Orientation orient   = rtwCAPI_GetOrientation(dimMap,dimIdx);
        uint_T              dIndex   = rtwCAPI_GetDimArrayIndex(dimMap, dimIdx);
        
        /* Signal's Data Type information */
        uint16_T	    dTypeIdx =  rtwCAPI_GetSignalDataTypeIdx(signals,i);
        uint16_T	    dataSize = rtwCAPI_GetDataTypeSize(dataTypeMap,
                                                               dTypeIdx);

        /* Get Signal name from the Signal structure */
        char_T const *signalName     =  rtwCAPI_GetSignalName(signals,i);
        
        /* Extract a signal buffer */
        LogBuffer *signalBuf	     = &sbInfo->sigBufs[sbInfo->numSigBufs];
		
        /* Signal's Fixed Point information */
        real_T fSlope	= 1.0;
        real_T fBias	= 0.0;
        int8_T fExp	= 0;
        uint16_T fxpIdx	=  rtwCAPI_GetSignalFixPtIdx(signals,i);
        if(rtwCAPI_GetFxpFracSlopePtr(fxpMap,fxpIdx) != NULL) {
            fSlope	= rtwCAPI_GetFxpFracSlope(fxpMap,fxpIdx);       
            fBias	= rtwCAPI_GetFxpBias(fxpMap,fxpIdx); 
            fExp	= rtwCAPI_GetFxpExponent(fxpMap,fxpIdx); 
        }
        
        dims		= (uint_T *) calloc(nDims, sizeof(uint_T));
        for(dimIdx=0; dimIdx<nDims; dimIdx++) {
            dims[dimIdx]= dimArray[dIndex + dimIdx];
        } 
	
        /* Record only named scalar signals */
        if(!(orient == rtwCAPI_SCALAR && (strcmp(signalName,"NULL") && 
                                          strcmp(signalName,"")))) {
            continue;
        }
        
        /* Set Signal Name */
        signalBuf->logName[80]	='\0';
        strncpy(signalBuf->logName,signalName,80);
        
        /* Set Signal Data Type */
        signalBuf->slDataType	= rtwCAPI_GetDataTypeSLId(dataTypeMap, dTypeIdx);
        
        /* Set Signal Data Complexity */
        signalBuf->isComplex	= rtwCAPI_GetDataIsComplex(dataTypeMap,dTypeIdx);
        
        /* Allocate memory for the real part */
        signalBuf->re	  = (void *) calloc(dims[0]*dims[1]*maxSize, dataSize);
        
        /* Allocate memory for imaginary part */
        if(signalBuf->isComplex) {
            signalBuf->im = (void *) calloc(dims[0]*dims[1]*maxSize, dataSize);
        }
	
        /* Signals slope and Bias */
        signalBuf->slope = (fSlope * pow(2, fExp));
        signalBuf->bias	 = fBias;
	
        /* Is the Signal in a referenced model? */
        signalBuf->isCrossingModel = isCrossingModel;		
	
        /* Set Signal Address */
        addrIdx			= rtwCAPI_GetSignalAddrIdx(signals,i);
        signalBuf->dataAddress	= dataAddrMap[addrIdx];
        
        /* Increment buffer number */
        sbInfo->numSigBufs	= sbInfo->numSigBufs + 1;
        
        /* Free dims memory */
        free(dims);
    }
}

/*
 * Function: loc_UpdateLogBuffer
 * Abstract:
 *   Helper function. Update state/signal buffers 
 */
static void loc_UpdateLogBuffer(LogBuffer *logBuf, 
                                uint_T     numDataPoints) {
    /* Local variables for calculating real world values from fixed point */
    real_T currRealVal = 0.0;
    real_T currImagVal = 0.0;
    
    /* If the data is non-complex, update just the real buffer, *
     * else update real and imaginary buffers                   */
    if(!logBuf->isComplex){
        /* The value of the data put in the buffer is decided by the      *
         * data-type of the state. Each data-type is handled differently */
        switch (logBuf->slDataType) {
          case SS_DOUBLE: {
              /* Pointer to the current position of the real part */
              real_T *currReal = ((real_T *) logBuf->re) + numDataPoints;
              /* Cast the data value to real_T */
              real_T *_cData   = (real_T *) logBuf->dataAddress;
              /* Assign the casted value to the current position */
              *currReal        = *_cData;
          }
            break;
          case SS_SINGLE: {
              /* Pointer to the current position of the real part */
              real32_T *currReal = ((real32_T *) logBuf->re) + numDataPoints;
              /* Cast the data value to real_T */
              real32_T *_cData   = (real32_T *) logBuf->dataAddress;
              /* Assign the casted value to the current position */
              *currReal          = *_cData;
          }
            break;
          case SS_UINT8: {
              /* Pointers to the current position of the real part */
              uint8_T *currReal = ((uint8_T *) logBuf->re) + numDataPoints;
              /* Cast the data value to real32_T */
              uint8_T *_cData   = ((uint8_T *)logBuf->dataAddress);
              /* Assign the real-world value to the current position */
              *(currReal)       = *_cData;
          }
            break;
          case SS_INT8: {
              /* Pointers to the current position of the real part */
              int8_T *currReal = ((int8_T *) logBuf->re) + numDataPoints;
              /* Cast the data value to int8_T */
              int8_T *_cData = ((int8_T *)logBuf->dataAddress);
              /* Assign the real-world value to the current position */
              *(currReal)       = *_cData; 
          }
            break;
          case SS_UINT16: {
              /* Pointers to the current position of the real part */
              uint16_T *currReal = ((uint16_T *) logBuf->re) + numDataPoints;
              /* Cast the data value to uint16_T */
              uint16_T *_cData = ((uint16_T *)logBuf->dataAddress);
              /* Assign the real-world value to the current position */
              *(currReal)       = *_cData;
          }
            break;
          case SS_INT16: {
              /* Pointers to the current position of the real part */
              int16_T *currReal = ((int16_T *) logBuf->re) + numDataPoints;
              /* Cast the data value to int16_T */
              int16_T *_cData = ((int16_T *)logBuf->dataAddress);
              /* Assign the real-world value to the current position */
              *(currReal)       = *_cData;
          }
            break;
          case SS_UINT32: {
              /* Pointers to the current position of the real part */
              uint32_T *currReal = ((uint32_T *) logBuf->re) + numDataPoints;
              /* Cast the data value to uint32_T */
              uint32_T *_cData = ((uint32_T *)logBuf->dataAddress);
              /* Assign the real-world value to the current position */
              *(currReal)       = *_cData;
          }
            break;
          case SS_INT32: {
              /* Pointers to the current position of the real part */
              int32_T *currReal = ((int32_T *) logBuf->re) + numDataPoints;
              /* Cast the data value to int32_T */
              int32_T *_cData = ((int32_T *)logBuf->dataAddress);
              /* Assign the real-world value to the current position */
              *(currReal)       = *_cData;
          }
            break;
        } /* end switch statement */
    } /* end if(!logBuf->isComplex) */
    else {
        /* State is complex */
        switch (logBuf->slDataType) {
          case SS_DOUBLE: {
              /* Pointers to the current position of the logged variable */
              real_T *currReal = ((real_T *) logBuf->re) + numDataPoints;
              real_T *currImag = ((real_T *) logBuf->im) + numDataPoints;
              /* Cast the data value to complex real_T */
              creal_T *_cData  = (( creal_T *)logBuf->dataAddress);
              /* Assign the casted value to the current position */
              *(currReal) = _cData->re;
              *(currImag) = _cData->im;
          }
            break;
          case SS_SINGLE: {
              /* Pointers to the current position of the logged variable */
              real32_T *currReal = ((real32_T *) logBuf->re) + numDataPoints;
              real32_T *currImag = ((real32_T *) logBuf->im) + numDataPoints;
              /* Cast the data value to complex real32_T */
              creal32_T *_cData = ((creal32_T *)logBuf->dataAddress);
              /* Assign the casted value to the current position */
              *(currReal) = _cData->re;
              *(currImag) = _cData->im;
          }
            break;
          case SS_UINT8: {
              /* Pointers to the current position of the logged variable */
              uint8_T *currReal = ((uint8_T *) logBuf->re) + numDataPoints;
              uint8_T *currImag = ((uint8_T *) logBuf->im) + numDataPoints;
              /* Cast the data value to complex uint8_T */
              cuint8_T *_cData = ((cuint8_T *)logBuf->dataAddress);
              /* Assign the casted value to the current position */
              *(currReal) = _cData->re;
              *(currImag) = _cData->im;
          }
            break;
          case SS_INT8: {
              /* Pointers to the current position of the logged variable */
              int8_T *currReal = ((int8_T *) logBuf->re) + numDataPoints;
              int8_T *currImag = ((int8_T *) logBuf->im) + numDataPoints;
              /* Cast the data value to complex int8_T */
              cint8_T *_cData = ((cint8_T *)logBuf->dataAddress);
              /* Assign the casted value to the current position */
              *(currReal) = _cData->re;
              *(currImag) = _cData->im;
          }
            break;
          case SS_UINT16: {
              /* Pointers to the current position of the logged variable */
              uint16_T *currReal = ((uint16_T *) logBuf->re) + numDataPoints;
              uint16_T *currImag = ((uint16_T *) logBuf->im) + numDataPoints;
              /* Cast the data value to complex uint16_T */
              const cuint16_T *_cData = ((const cuint16_T *)logBuf->dataAddress);
              /* Assign the casted value to the current position */
              *(currReal) = _cData->re;
              *(currImag) = _cData->im;
          }
            break;
          case SS_INT16: {
              /* Pointers to the current position of the logged variable */
              int16_T *currReal = ((int16_T *) logBuf->re) + numDataPoints;
              int16_T *currImag = ((int16_T *) logBuf->im) + numDataPoints;
              /* Cast the data value to complex int16_T */
              cint16_T *_cData = ((cint16_T *)logBuf->dataAddress);
              /* Assign the casted value to the current position */
              *(currReal) = _cData->re;
              *(currImag) = _cData->im;
          }
            break;
          case SS_UINT32: {
              /* Pointers to the current position of the logged variable */
              uint32_T *currReal = ((uint32_T *) logBuf->re) + numDataPoints;
              uint32_T *currImag = ((uint32_T *) logBuf->im) + numDataPoints;
              /* Cast the data value to complex uint32_T */
              cuint32_T *_cData = ((cuint32_T *)logBuf->dataAddress);
              /* Assign the casted value to the current position */
              *(currReal) = _cData->re;
              *(currImag) = _cData->im;
          }
            break;
          case SS_INT32: {
              /* Pointers to the current position of the logged variable */
              int32_T *currReal = ((int32_T *) logBuf->re) + numDataPoints;
              int32_T *currImag = ((int32_T *) logBuf->im) + numDataPoints;
              /* Cast the data value to complex uint32_T */
              cint32_T *_cData = ((cint32_T *)logBuf->dataAddress);
              /* Assign the casted value to the current position */
              *(currReal) = _cData->re;
              *(currImag) = _cData->im;
          }
            break;
        }
    }
}

/* Function: loc_writeBuffer
 * Abstract:
 *   Helper function. Write contents of buffer to file.
 */
static void loc_writeBuffer(FILE *fptr, LogBuffer *logBuf, uint_T nPoint) {
    switch (logBuf->slDataType) {
      case SS_DOUBLE  : {
          real_T *_rePart	= (real_T *) logBuf->re;
          if (logBuf->im != NULL){
              real_T *_imPart	= (real_T *) logBuf->im;
              fprintf(fptr, "%-5.3G + %-5.3Gi",
                      _rePart[nPoint], _imPart[nPoint]);
          }
          else
              fprintf(fptr, "%-40.4G",_rePart[nPoint]);
      }
        break;
      case SS_SINGLE : {
          real32_T *_rePart	= (real32_T *) logBuf->re;
          if (logBuf->im != NULL){
              real32_T *_imPart = (real32_T *) logBuf->im;
              fprintf(fptr, "%-5.3f + %-5.3fi",
                      _rePart[nPoint], _imPart[nPoint]);
          }
          else
              fprintf(fptr, "%-40.4f",_rePart[nPoint]);
      }
        break;
      case SS_INT8 : {
          int8_T *_rePart	= (int8_T *) logBuf->re;
          real_T  slope		= logBuf->slope;
          real_T  bias		= logBuf->bias;
          if (logBuf->im != NULL){
              int8_T *_imPart	= (int8_T *) logBuf->im;
              fprintf(fptr, "%-5.3G + -5.3Gi",
                      (_rePart[nPoint]*slope + bias), 
                      (_imPart[nPoint]*slope + bias));
          }
          else
              fprintf(fptr, "%-40.4G",(_rePart[nPoint]*slope + bias));
      }
        break;
      case SS_UINT8 : {
          uint8_T *_rePart	= (uint8_T *) logBuf->re;
          real_T  slope		= logBuf->slope;
          real_T  bias		= logBuf->bias;
          if (logBuf->im != NULL){
              uint8_T *_imPart	= (uint8_T *) logBuf->im;
              fprintf(fptr, "%-5.3G + -5.3Gi",
                      (_rePart[nPoint]*slope + bias), 
                      (_imPart[nPoint]*slope + bias));
          }
          else
              fprintf(fptr, "%-40.4G",(_rePart[nPoint]*slope + bias));
      }
        break;
      case SS_INT16 : { 
          int16_T *_rePart	= (int16_T *) logBuf->re;
          real_T  slope		= logBuf->slope;
          real_T  bias		= logBuf->bias;
          if (logBuf->im != NULL){
              int16_T *_imPart	= (int16_T *) logBuf->im;
              fprintf(fptr, "%-5.3G + -5.3Gi",
                      (_rePart[nPoint]*slope + bias), 
                      (_imPart[nPoint]*slope + bias));
          }
          else
              fprintf(fptr, "%-40.4G",(_rePart[nPoint]*slope + bias));
      }
        break;
      case SS_UINT16 : {
          uint16_T *_rePart	= (uint16_T *) logBuf->re;
          real_T  slope		= logBuf->slope;
          real_T  bias		= logBuf->bias;
          if (logBuf->im != NULL){
              uint16_T *_imPart	= (uint16_T *) logBuf->im;
              fprintf(fptr, "%-5.3G + -5.3Gi",
                      (_rePart[nPoint]*slope + bias), 
                      (_imPart[nPoint]*slope + bias));
          }
          else
              fprintf(fptr, "%-40.4G",(_rePart[nPoint]*slope + bias));
      }
        break;
      case SS_INT32 : {
          int32_T *_rePart	= (int32_T *) logBuf->re;
          real_T  slope		= logBuf->slope;
          real_T  bias		= logBuf->bias;
          if (logBuf->im != NULL){
              int32_T *_imPart	= (int32_T *) logBuf->im;
              fprintf(fptr, "%-5.3G + -5.3Gi",
                      (_rePart[nPoint]*slope + bias), 
                      (_imPart[nPoint]*slope + bias));
          }
          else
              fprintf(fptr, "%-40.4G",(_rePart[nPoint]*slope + bias));
              }
        break;
      case SS_UINT32 : {
          uint32_T *_rePart	= (uint32_T *) logBuf->re;
          real_T  slope		= logBuf->slope;
          real_T  bias		= logBuf->bias;
          if (logBuf->im != NULL){
              uint32_T *_imPart	= (uint32_T *) logBuf->im;
              fprintf(fptr, "%-5.3G + -5.3Gi",
                            (_rePart[nPoint]*slope + bias), 
                      (_imPart[nPoint]*slope + bias));
          }
          else
              fprintf(fptr, "%-40.4G",(_rePart[nPoint]*slope + bias));
      }
        break;
    } 
}

/* EOF rtwdemo_capi_datalog.c */
