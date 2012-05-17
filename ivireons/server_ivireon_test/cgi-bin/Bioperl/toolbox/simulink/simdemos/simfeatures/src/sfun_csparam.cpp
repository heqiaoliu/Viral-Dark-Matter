/*
 * File : sfun_csparam.cpp
 * Abstract:
 *   Example of context-sensitive parameters.
 *
 *   This S-Function accepts a single real input signal (which can be scalar
 *   or vector or matrix).  It multiplies the inputs by the value of the
 *   gain parameter (which must be a scalar real number).
 *
 *   This S-function does not support signals with boolean or fixed-point
 *   data types.
 *
 *   If the data type of the gain parameter is:
 *   double     ==> the block treats the parameter as "context-sensitive"
 *                  (it uses the signal data type for the parameter).
 *   non-double ==> the block does not change the parameter data type
 *                  but it may add a data type cast in the generated code.
 *
 * NOTE:
 *   If the parameter is treated as "context-sensitive" and the signal uses
 *   a user-defined / alias data type, the parameter is registered with the
 *   user-defined data type.
 *
 *  See simulink/src/sfuntmpl.doc
 */

/*   Copyright 1990-2009 The MathWorks, Inc.
 *   $Revision: 1.1.6.1 $ */

/*
 * You must specify the S_FUNCTION_NAME as the name of your S-function.
 */

#define S_FUNCTION_NAME  sfun_csparam
#define S_FUNCTION_LEVEL 2

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include <stdio.h>
#include <string.h>
#include "tmwtypes.h"
#include "simstruc.h"

/* S-Function parameter indices */
typedef enum {
    GAIN_IDX = 0,
    NPARAMS
} ParamIdx;

#define GAIN_PARAM(S) ssGetSFcnParam(S,GAIN_IDX)

/* ERROR MESSAGES */
const char *invalidSignalDataTypeMsg = 
"Boolean and fixed-point data types not supported.";

#if !defined(MATLAB_MEX_FILE)
/*
 * This file cannot be used directly with the Real-Time Workshop. However,
 * this S-function does work with the Real-Time Workshop via
 * the Target Language Compiler technology. See 
 * matlabroot/toolbox/simulink/blocks/tlc_c/sfun_multiport.tlc   
 * for the C version
 * matlabroot/toolbox/simulink/blocks/tlc_ada/sfun_multiport.tlc 
 * for the Ada version
 */
# error This_file_can_be_used_only_during_simulation_inside_Simulink
#endif


/*====================*
 * S-function methods *
 *====================*/

#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
  /* Function: mdlCheckParameters =============================================
   * Abstract:
   *    Validate our parameters to verify they are okay.
   */
  static void mdlCheckParameters(SimStruct *S)
  {
      /* Check gain parameter */
      {
          if ((mxIsComplex(GAIN_PARAM(S))) ||
              (mxGetNumberOfElements(GAIN_PARAM(S)) != 1)) {
              ssSetErrorStatus(S,"Gain parameter must be a scalar real number");
          }
      }
      return;
  }
#endif /* MDL_CHECK_PARAMETERS */


/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    Call mdlCheckParameters to verify that the parameters are okay,
 *    then setup sizes of the various vectors.
 */
static void mdlInitializeSizes(SimStruct *S)
{

    /* Set up parameters */
    ssSetNumSFcnParams(S, NPARAMS);  /* Number of expected parameters */
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) {
            return;
        }
    } else {
        return; /* Parameter mismatch will be reported by Simulink */
    }

#endif

    ssSetSFcnParamTunable(S, GAIN_IDX, true);

    /* Set up states */
    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    /* Set up inputs */
    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(S, 0, DYNAMICALLY_SIZED);
    ssSetInputPortDataType(S, 0, DYNAMICALLY_TYPED);
    ssSetInputPortReusable(S, 0, true);
    ssSetInputPortOverWritable(S, 0, true);
    ssSetInputPortAcceptExprInRTW(S, 0, true);
    ssSetInputPortDirectFeedThrough(S, 0, true);

    /* Set up outputs */
    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortWidth(S, 0, DYNAMICALLY_SIZED);
    ssSetOutputPortDataType(S, 0, DYNAMICALLY_TYPED);
    ssSetOutputPortReusable(S, 0, true);
    ssSetOutputPortOutputExprInRTW(S, 0, true);

    /* Set up sample times */
    ssSetNumSampleTimes(S, 1);

    /* Set up work vectors */
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    /* specify the sim state compliance to be same as a built-in block */
    ssSetSimStateCompliance(S, USE_DEFAULT_SIM_STATE);

    /* Set S-Function options - NOTE ESPECIALLY:
     * - SS_OPTION_SUPPORTS_ALIAS_DATA_TYPES
     *   (supports user-defined / alias data types)
     * - SS_OPTION_SFUNCTION_INLINED_FOR_RTW
     *   (use TLC code to inline S-Function in generated code)
     */
    ssSetOptions(S,
                 SS_OPTION_SUPPORTS_ALIAS_DATA_TYPES |
                 SS_OPTION_SFUNCTION_INLINED_FOR_RTW |
                 SS_OPTION_WORKS_WITH_CODE_REUSE |
                 SS_OPTION_EXCEPTION_FREE_CODE |
                 SS_OPTION_ALLOW_INPUT_SCALAR_EXPANSION |
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR | 
                 SS_OPTION_CALL_TERMINATE_ON_EXIT);
}


/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Specifiy that we inherit our sample time from the driving block.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}


#define MDL_SET_WORK_WIDTHS   /* Change to #undef to remove function */
#if defined(MDL_SET_WORK_WIDTHS) && defined(MATLAB_MEX_FILE)
/* Function: mdlSetWorkWidths ===============================================
 * Abstract:
 *      Set up run-time parameters.
 */
static void mdlSetWorkWidths(SimStruct *S)
{
    /* Set number of run-time parameters */
    if (!ssSetNumRunTimeParams(S, 1)) return;

    /* Register run-time parameters */
    DTypeId actualType = ssGetOutputPortDataType(S,0);
    ssRegDlgParamAsRunTimeParam(S, GAIN_IDX, 0, "Gain", actualType);

    /* NOTE:
     * - We have turned on SS_OPTION_SUPPORTS_ALIAS_DATA_TYPES so
     *   ssGetOutputPortDataType will return the actual data type
     *   (which may be a user-defined / alias data type). */
}
#endif /* MDL_SET_WORK_WIDTHS */


#define MDL_PROCESS_PARAMETERS   /* Change to #undef to remove function */
#if defined(MDL_PROCESS_PARAMETERS) && defined(MATLAB_MEX_FILE)
/* Function: mdlProcessParameters ===========================================
 * Abstract:
 *      Update run-time parameters.
 */
static void mdlProcessParameters(SimStruct *S)
{
    /* Update Run-Time parameter values */
    ssUpdateDlgParamAsRunTimeParam(S, GAIN_IDX);
    
    /* NOTE: We could also have used
     * - ssUpdateAllTunableParamsAsRunTimeParams(S);
     */
}
#endif /* MDL_PROCESS_PARAMETERS */


/* Function: fcnOutputs ======================================================
 * Abstract:
 *   Generic function to implement mdlOutputs.  We have defined this as a
 *   template function so that it can be called for all data types.
 *
 *      y[i] = "gain" * u[i];
 */
template <typename NumericType>
void fcnOutputs(SimStruct *S, int_T tid)
{
    int_T idx;
    int_T width = ssGetInputPortWidth(S, 0);
    InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S,0);
    NumericType *y1  =  (NumericType *) (ssGetOutputPortRealSignal(S,0));
    NumericType gain = *(NumericType *) (ssGetRunTimeParamInfo(S,0)->data);

    for (idx=0; idx<width; idx++) {
        NumericType *u1 = (NumericType *) uPtrs[idx];
        y1[idx] = gain * (*u1);
    }
}


/* Function: mdlOutputs =======================================================
 * Abstract:
 *   Wrapper function to set up the call to the correct version of
 *   fcnOutputs (based on the data type of the input/output signal).
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    /* We need to get the base (aliased-through) data type */
    DTypeId baseType = dtaGetDataTypeIdAliasedThruTo(ssGetDataTypeAccess(S), 
                               ssGetPath(S), ssGetOutputPortDataType(S,0));

    /* For each possible data type, call the appropriate outputs function.
     *
     * OPTIMIZATION: Switch out the S-Function's mdlOutputs function
     * (so that it gets called instead of this function in future).
     */
    switch (baseType) {
      case SS_DOUBLE:
        fcnOutputs<real_T>(S,tid);
        ssSetmdlOutputs(S, &(fcnOutputs<real_T>));
        break;
      case SS_SINGLE:
        fcnOutputs<real32_T>(S,tid);
        ssSetmdlOutputs(S, &(fcnOutputs<real32_T>));
        break;
      case SS_INT32:
        fcnOutputs<int32_T>(S,tid);
        ssSetmdlOutputs(S, &(fcnOutputs<int32_T>));
        break;
      case SS_INT16:
        fcnOutputs<int16_T>(S,tid);
        ssSetmdlOutputs(S, &(fcnOutputs<int16_T>));
        break;
      case SS_INT8:
        fcnOutputs<int8_T>(S,tid);
        ssSetmdlOutputs(S, &(fcnOutputs<int8_T>));
        break;
      case SS_UINT32:
        fcnOutputs<uint32_T>(S,tid);
        ssSetmdlOutputs(S, &(fcnOutputs<uint32_T>));
        break;
      case SS_UINT16:
        fcnOutputs<uint16_T>(S,tid);
        ssSetmdlOutputs(S, &(fcnOutputs<uint16_T>));
        break;
      case SS_UINT8:
        fcnOutputs<uint8_T>(S,tid);
        ssSetmdlOutputs(S, &(fcnOutputs<uint8_T>));
        break;
      default:
        ssSetErrorStatus(S, "Unsupported data type");
    }
}



/* Function: mdlTerminate =====================================================
 * Abstract:
 *      Free the user data.
 */
static void mdlTerminate(SimStruct *S)
{
    /* No action required */
}


/* Function: isAcceptableDataType
 *    determine if the data type ID corresponds to an unsigned integer
 */
static boolean_T isAcceptableDataType(SimStruct *S, DTypeId dType)
{
    /* We need to get the base (aliased-through) data type */
    DTypeId baseType = dtaGetDataTypeIdAliasedThruTo(ssGetDataTypeAccess(S), 
                                                     ssGetPath(S), dType);

    boolean_T isAcceptable = false;

    switch (baseType) {
      case SS_DOUBLE:
      case SS_SINGLE:
      case SS_INT32:
      case SS_INT16:
      case SS_INT8:
      case SS_UINT32:
      case SS_UINT16:
      case SS_UINT8:
        isAcceptable = true;
        break;
    }

    return isAcceptable;
}


#ifdef MATLAB_MEX_FILE

#define MDL_SET_INPUT_PORT_DATA_TYPE
/* Function: mdlSetInputPortDataType ==========================================
 *    Validate the input/output data types.
 */
static void mdlSetInputPortDataType(SimStruct *S, 
                                    int       port, 
                                    DTypeId   dataType)
{
    if (isAcceptableDataType(S, dataType)) {
        ssSetInputPortDataType (S, 0, dataType);
        ssSetOutputPortDataType(S, 0, dataType);
    } else {
        /* Reject proposed data type */
        ssSetErrorStatus(S, invalidSignalDataTypeMsg);
        goto EXIT_POINT;
    }

EXIT_POINT:
    return;
} /* mdlSetInputPortDataType */


#define MDL_SET_OUTPUT_PORT_DATA_TYPE
/* Function: mdlSetOutputPortDataType =========================================
 *    Validate the input/output data types.
 */
static void mdlSetOutputPortDataType(SimStruct *S, 
                                     int       port, 
                                     DTypeId   dataType)
{
    if (isAcceptableDataType(S, dataType)) {
        ssSetInputPortDataType (S, 0, dataType);
        ssSetOutputPortDataType(S, 0, dataType);
    } else {
        /* Reject proposed data type */
        ssSetErrorStatus(S, invalidSignalDataTypeMsg);
        goto EXIT_POINT;
    }

EXIT_POINT:
    return;

} /* mdlSetOutputPortDataType */

#define MDL_SET_DEFAULT_PORT_DATA_TYPES
/* Function: mdlSetDefaultPortDataTypes ========================================
 *    Set default input/output data types.
 */
static void mdlSetDefaultPortDataTypes(SimStruct *S)
{
    /* Set input port data type to double */
    ssSetInputPortDataType (S, 0, SS_DOUBLE);
    ssSetOutputPortDataType(S, 0, SS_DOUBLE);

} /* mdlSetDefaultPortDataTypes */

#endif /* MATLAB_MEX_FILE */


/* Function: mdlRTW
 * Abstract:
 *   This function is not needed, because we set the option:
 *
 *          SS_OPTION_SFUNCTION_INLINED_FOR_RTW
 */

/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
