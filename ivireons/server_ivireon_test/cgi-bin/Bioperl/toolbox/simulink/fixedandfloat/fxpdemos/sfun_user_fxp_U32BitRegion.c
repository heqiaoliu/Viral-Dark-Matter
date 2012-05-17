/*
 * File: sfuntmpl_doc.c
 * Abstract:
 *       A 'C' template for a level 2 S-function. 
 *
 *       See matlabroot/simulink/src/sfuntmpl_basic.c
 *       for a basic C-MEX template file that uses the 
 *       most common methods.
 *
 * Copyright 1990-2007 The MathWorks, Inc.
 * $Revision: 1.1.6.2 $
 */


/*
 * You must specify the S_FUNCTION_NAME as the name of your S-function.
 */

#define S_FUNCTION_NAME  sfun_user_fxp_U32BitRegion
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"
#include "fixedpoint.h"


#ifndef TRUE
#define TRUE 1
#endif 

#ifndef FALSE
#define FALSE 1
#endif 


/*=====================================*
 * Configuration and execution methods *
 *=====================================*/

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */
static void mdlInitializeSizes(SimStruct *S)
{
    int_T nInputPorts  = 1;  /* number of input ports  */
    int_T nOutputPorts = 1;  /* number of output ports */
    int_T needsInput   = 1;  /* direct feed through    */

    int_T inputPortIdx  = 0;
    int_T outputPortIdx = 0;

    ssSetNumSFcnParams(S, 0);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        return;
    }

    if (ssGetErrorStatus(S) != NULL) return;

    /* Register the number and type of states the S-Function uses */

    ssSetNumContStates(    S, 0);   /* number of continuous states           */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states             */


    /*
     * Configure the input ports. First set the number of input ports. 
     */
    if (!ssSetNumInputPorts(S, nInputPorts)) return;   
    if(!ssSetInputPortDimensionInfo(S, inputPortIdx, DYNAMIC_DIMENSION)) return; 

    ssSetInputPortWidth(S, inputPortIdx, DYNAMICALLY_SIZED);
    ssSetInputPortRequiredContiguous(S, inputPortIdx, TRUE); /*direct input signal access*/ 

    ssSetInputPortDataType(S, inputPortIdx,DYNAMICALLY_TYPED);
    ssSetInputPortDirectFeedThrough(S, inputPortIdx,TRUE);
    ssSetInputPortOverWritable(S, inputPortIdx, FALSE);
    ssSetInputPortReusable(S, inputPortIdx,TRUE);
    ssSetInputPortComplexSignal( S, inputPortIdx, COMPLEX_INHERITED);

    /*
     * Configure the output ports. First set the number of output ports.
     */
    if (!ssSetNumOutputPorts(S, nOutputPorts)) return;
    if(!ssSetOutputPortDimensionInfo(S,outputPortIdx,DYNAMIC_DIMENSION)) return;

    ssSetOutputPortWidth(S, outputPortIdx, DYNAMICALLY_SIZED);

    /* register data type
     */ 

    ssSetOutputPortDataType( S, outputPortIdx, DYNAMICALLY_TYPED );
    ssSetOutputPortReusable(            S, outputPortIdx, TRUE);
    ssSetOutputPortComplexSignal(S, outputPortIdx, COMPLEX_INHERITED );

    ssSetNumSampleTimes(   S, 1);   /* number of sample times                */

    /*
     * Set size of the work vectors.
     */
    ssSetNumRWork(         S, 0);   /* number of real work vector elements   */
    ssSetNumIWork(         S, 0);   /* number of integer work vector elements*/
    ssSetNumPWork(         S, 0);   /* number of pointer work vector elements*/
    ssSetNumModes(         S, 0);   /* number of mode work vector elements   */
    ssSetNumNonsampledZCs( S, 0);   /* number of nonsampled zero crossings   */

    ssSetOptions(          S, 0);   /* general options (SS_OPTION_xx)        */
    ssFxpSetU32BitRegionCompliant(S, 1);

} /* end mdlInitializeSizes */


#define MDL_SET_INPUT_PORT_DIMENSION_INFO /* Change to #define to add function */
#if defined(MDL_SET_INPUT_PORT_DIMENSION_INFO) && defined(MATLAB_MEX_FILE)
  /* Function: mdlSetInputPortDimensionInfo ====================================
   */
static void mdlSetInputPortDimensionInfo(SimStruct        *S,         
                                         int_T            portIndex,
                                         const DimsInfo_T *dimsInfo)
{
    int outPortWidth = 0;
    if(!ssSetInputPortDimensionInfo(S, portIndex, dimsInfo)) return;

    outPortWidth = ssGetOutputPortWidth( S, 0 );
    
    if ( outPortWidth == DYNAMICALLY_SIZED )
    {
        if(!ssSetOutputPortDimensionInfo(S, 0, dimsInfo)) return;
    }
    else if ( outPortWidth != dimsInfo->width )
    {
        ssSetErrorStatus(S,"Input port width not compatible with output port width.");
    }
} /* mdlSetInputPortDimensionInfo */
#endif /* MDL_SET_INPUT_PORT_DIMENSION_INFO */


#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO /* Change to #define to add function*/
#if defined(MDL_SET_OUTPUT_PORT_DIMENSION_INFO) && defined(MATLAB_MEX_FILE)
  /* Function: mdlSetOutputPortDimensionInfo ===================================
   */
  static void mdlSetOutputPortDimensionInfo(SimStruct        *S,        
                                            int_T            portIndex,
                                            const DimsInfo_T *dimsInfo)
  {
    int inPortWidth = 0;
    if(!ssSetOutputPortDimensionInfo(S, portIndex, dimsInfo)) return;

    inPortWidth = ssGetInputPortWidth( S, 0 );
    
    if ( inPortWidth == DYNAMICALLY_SIZED )
    {
        if(!ssSetInputPortDimensionInfo(S, 0, dimsInfo)) return;
    }
    else if ( inPortWidth != dimsInfo->width )
    {
        ssSetErrorStatus(S,"Output port width not compatible with input port width.");
    }

  } /* mdlSetOutputPortDimensionInfo */
#endif /* MDL_SET_OUTPUT_PORT_DIMENSION_INFO */


/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    /* Register one pair for each sample time */
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);

} /* end mdlInitializeSampleTimes */


#define MDL_SET_INPUT_PORT_DATA_TYPE   /* Change to #undef to remove function */
#if defined(MDL_SET_INPUT_PORT_DATA_TYPE) && defined(MATLAB_MEX_FILE)
  /* Function: mdlSetInputPortDataType =========================================
   * Abstract:
   */
  static void mdlSetInputPortDataType(SimStruct *S, int portIdx,DTypeId dType)
  {
    if ( ssGetDataTypeIsFxpFltApiCompat( S, dType ) == 0) 
    {
        ssSetErrorStatus(S,"Unrecognized data type.");
    }
    else
    {
        ssSetInputPortDataType( S, portIdx, dType );
        ssSetOutputPortDataType( S, 0, dType );
    }
  } /* mdlSetInputPortDataType */
#endif /* MDL_SET_INPUT_PORT_DATA_TYPE */


#define MDL_SET_OUTPUT_PORT_DATA_TYPE  /* Change to #undef to remove function */
#if defined(MDL_SET_OUTPUT_PORT_DATA_TYPE) && defined(MATLAB_MEX_FILE)
  /* Function: mdlSetOutputPortDataType ========================================
   */
  static void mdlSetOutputPortDataType(SimStruct *S,int portIndex,DTypeId dType)
  {
    if ( ssGetDataTypeIsFxpFltApiCompat( S, dType ) == 0) 
    {
        ssSetErrorStatus(S,"Unrecognized data type.");
    }
    else
    {
        ssSetOutputPortDataType( S, 0, dType );
    }
  } /* mdlSetOutputPortDataType */
#endif /* MDL_SET_OUTPUT_PORT_DATA_TYPE */

/* Function: propPortComplexity ===========================================
 */
void propPortComplexity(SimStruct *S)
{
    CSignal_T cY  = ssGetOutputPortComplexSignal( S, 0);

    CSignal_T cU = ssGetInputPortComplexSignal( S, 0);

    /* if input is complex, then output must be complex
     */
    if ( cU == COMPLEX_YES )
    {
        /* if output complexity is not known then set it
         */
        if ( cY == COMPLEX_INHERITED )
        {
            ssSetOutputPortComplexSignal(S, 0, COMPLEX_YES);
        }
        /* if the output is real, then an error has occurred
         */
        else if ( cY == COMPLEX_NO )
        {
            ssSetErrorStatus(S,"Output is REAL, but input is COMPLEX.");
            return;
        }
    }
    /* if input is real then output must be real
     */
    else if( cU == COMPLEX_NO )
    {
        /* if output complexity is not known then set it
         */
        if ( cY == COMPLEX_INHERITED )
        {
            ssSetOutputPortComplexSignal(S, 0, COMPLEX_NO);
        }
        /* if the output is complex, then an error has occurred
         */
        else if ( cY == COMPLEX_YES )
        {
            ssSetErrorStatus(S,"Output is COMPLEX, but input is REAL.");
            return;
        }
    }
    else /* Input is COMPLEX_INHERITED) */
    {
        if ( cY == COMPLEX_NO )
        {
            ssSetInputPortComplexSignal(S, 0, COMPLEX_NO );
        }
        else if ( cY == COMPLEX_YES )
        {
            ssSetInputPortComplexSignal(S, 0, COMPLEX_YES );
        }
    }
}

#define MDL_SET_INPUT_PORT_COMPLEX_SIGNAL   /* Change to #undef to remove */
#if defined(MDL_SET_INPUT_PORT_COMPLEX_SIGNAL) && defined(MATLAB_MEX_FILE)
  /* Function: mdlSetInputPortComplexSignal ====================================
   */
static void mdlSetInputPortComplexSignal(SimStruct *S, 
                                         int       portIndex, 
                                         CSignal_T cSignalSetting)
{
    ssSetInputPortComplexSignal( S, portIndex, cSignalSetting);
    
    propPortComplexity(S);
} /* mdlSetInputPortComplexSignal */
#endif /* MDL_SET_INPUT_PORT_COMPLEX_SIGNAL */


#define MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL  /* Change to #undef to remove */
#if defined(MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL) && defined(MATLAB_MEX_FILE)
  /* Function: mdlSetOutputPortComplexSignal ===================================
   */
static void mdlSetOutputPortComplexSignal(SimStruct *S, 
                                          int       portIndex, 
                                          CSignal_T cSignalSetting)
{
    /* always accept the proposed output complexity
     */
    ssSetOutputPortComplexSignal( S, portIndex, cSignalSetting);
    
    propPortComplexity(S);
    
} /* mdlSetOutputPortComplexSignal */
#endif /* MDL_SET_OUTPUT_PORT_COMPLEX_SIGNAL */


#define MDL_GET_TIME_OF_NEXT_VAR_HIT  /* Change to #undef to remove function */
#if defined(MDL_GET_TIME_OF_NEXT_VAR_HIT) && (defined(MATLAB_MEX_FILE) || \
                                              defined(NRT))
  /* Function: mdlGetTimeOfNextVarHit =========================================
   */

  static void mdlGetTimeOfNextVarHit(SimStruct *S)
  {
      time_T timeOfNextHit = ssGetT(S) /* + offset */ ;
      ssSetTNext(S, timeOfNextHit);
  }
#endif /* MDL_GET_TIME_OF_NEXT_VAR_HIT */


/* Function: mdlOutputs =======================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block. Generally outputs are placed in the output vector(s),
 *    ssGetOutputPortSignal.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
      const void *pVoidIn = (const void *) ssGetInputPortSignal(S, 0);
      void *pVoidOut = ssGetOutputPortSignal(S,0);
      int regionIdx = 0;
      
      boolean_T inIsComplex = (ssGetInputPortComplexSignal(S,0) == COMPLEX_YES);
      int dataSize = ssGetDataTypeSize( S, ssGetInputPortDataType( S, 0 ) );

      int dataWidth = ssGetInputPortWidth(S,0);

      unsigned int idx = 0;
      
      char * pCharInBase = NULL;
      char * pCharOutBase = NULL;
      
      char * pCharIn = NULL;
      char * pCharOut =NULL;
      
      uint32_T regionValue = 0;
      fxpStorageContainerCategory inStorageContainerCategory;
      fxpStorageContainerCategory outStorageContainerCategory;

      DTypeId dTypeId;

      if ( inIsComplex )
      {
          dataWidth = 2 * dataWidth;
      }

      dTypeId = ssGetInputPortDataType(S,0);

      inStorageContainerCategory = ssGetDataTypeStorageContainCat(S,dTypeId);

      dTypeId = ssGetOutputPortDataType(S,0);

      outStorageContainerCategory = ssGetDataTypeStorageContainCat(S,dTypeId);

      if(inStorageContainerCategory != outStorageContainerCategory)
      {
          ssSetErrorStatus(S, "Input and output have different container categories");
          return;
      }
      if(inStorageContainerCategory == FXP_STORAGE_DOUBLE ||
         inStorageContainerCategory == FXP_STORAGE_SINGLE ||
         inStorageContainerCategory == FXP_STORAGE_SCALEDDOUBLE)
      {
          memcpy( pVoidOut, pVoidIn,  dataWidth * dataSize );
      }
      else  /*are fixed point*/
      {
          pCharInBase = (char *) pVoidIn;
          pCharOutBase = (char *) pVoidOut;

          for(idx = 0; idx < dataWidth; idx ++) 
          {
              pCharIn = &pCharInBase[ idx * dataSize ];
              pCharOut = &pCharOutBase[ idx * dataSize ];

              for (regionIdx = 0; regionIdx < FXP_NUM_CHUNKS; regionIdx++)
              {
                  regionValue = ssFxpGetU32BitRegion(S, 
                                                     pCharIn, 
                                                     dTypeId, 
                                                     regionIdx);
                  
                  ssFxpSetU32BitRegion(S,
                                       pCharOut, 
                                       dTypeId,
                                       regionValue,
                                       regionIdx);
              }
          } 
      }
      return;
} /* end mdlOutputs */


/* Function: mdlTerminate =====================================================
 */
static void mdlTerminate(SimStruct *S)
{
}


/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
