/* Copyright 2007 The MathWorks, Inc. */
/*
 *   SimpTableWrap.c Simple C-MEX S-function for function call.
 *
 *   ABSTRACT:
 *     The purpose of this sfunction is to call a simple legacy 
 *     function during simulation:
 *
 *        double y1 = SimpleTable(double u1,double p1[], double p2[], int16 p3)
 *
 * Simulink version           : 6.5 (R2006b+) 11-Sep-2006
 *   C source code generated on : 13-Nov-2006 09:30:23
 */

/*
   %%%-MATLAB_Construction_Commands_Start
   def = legacy_code_initialize;
   def.SFunctionName = 'SimpTableWrap';
   def.OutputFcnSpec = 'double y1 = SimpleTable(double u1,double p1[], double p2[], int16 p3)';
   def.HeaderFiles = {'SimpleTable.h'};
   def.IncPaths = {'.\PCG_Eval'};
   def.SrcPaths = {'.\PCG_Eval'};
   legacy_code_sfcn_cmex_generate(def);
   legacy_code_compile(def);
   %%%-MATLAB_Construction_Commands_End
 */

/*
 * Must specify the S_FUNCTION_NAME as the name of the S-function.
 */
#define S_FUNCTION_NAME                 SimpTableWrap
#define S_FUNCTION_LEVEL                2

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include "simstruc.h"

/*
 * Specific header file(s) required by the legacy code function.
 */
#include "SimpleTable.h"
#define EDIT_OK(S, P_IDX) \
  (!((ssGetSimMode(S)==SS_SIMMODE_SIZES_CALL_ONLY) && mxIsEmpty(ssGetSFcnParam(S, P_IDX))))

#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
/* Function: mdlCheckParameters ===========================================
 * Abstract:
 *    mdlCheckParameters verifies new parameter settings whenever parameter
 *    change or are re-evaluated during a simulation. When a simulation is
 *    running, changes to S-function parameters can occur at any time during
 *    the simulation loop.
 */

static void mdlCheckParameters(SimStruct *S)
{
  /*
   * Check the parameter 1
   */
  if EDIT_OK(S, 0) {
    int_T *dimsArray = (int_T *) mxGetDimensions(ssGetSFcnParam(S, 0));

    /* Parameter 1 must be a vector */
    if ((dimsArray[0] > 1) && (dimsArray[1] > 1)) {
      ssSetErrorStatus(S,"Parameter 1 must be a vector");
      return;
    }

    /* Check the parameter attributes */
    ssCheckSFcnParamValueAttribs(S, 0, "P1", DYNAMICALLY_TYPED, 2, dimsArray, 0);
  }

  /*
   * Check the parameter 2
   */
  if EDIT_OK(S, 1) {
    int_T *dimsArray = (int_T *) mxGetDimensions(ssGetSFcnParam(S, 1));

    /* Parameter 2 must be a vector */
    if ((dimsArray[0] > 1) && (dimsArray[1] > 1)) {
      ssSetErrorStatus(S,"Parameter 2 must be a vector");
      return;
    }

    /* Check the parameter attributes */
    ssCheckSFcnParamValueAttribs(S, 1, "P2", DYNAMICALLY_TYPED, 2, dimsArray, 0);
  }

  /*
   * Check the parameter 3
   */
  if EDIT_OK(S, 2) {
    int_T dimsArray[2] = {1, 1};

    /* Check the parameter attributes */
    ssCheckSFcnParamValueAttribs(S, 2, "P3", DYNAMICALLY_TYPED, 2, dimsArray, 0);
  }
}
#endif

/* Function: mdlInitializeSizes ===========================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */
static void mdlInitializeSizes(SimStruct *S)
{
  /* Number of expected parameters */
  ssSetNumSFcnParams(S, 3);

#if defined(MATLAB_MEX_FILE)
  if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
    /*
     * If the the number of expected input parameters is not equal
     * to the number of parameters entered in the dialog box return.
     * Simulink will generate an error indicating that there is a
     * parameter mismatch.
     */
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) {
      return;
    }
  } else {
    /* Return if number of expected != number of actual parameters */
    return;
  }
#endif

  /*
   * Set the number of input ports. 
   */
  if (!ssSetNumInputPorts(S, 1)) return;

  /*
   * Configure the input port 1
   */
  ssSetInputPortDataType(S, 0, SS_DOUBLE);
  ssSetInputPortWidth(S, 0, 1);
  ssSetInputPortComplexSignal(S, 0, COMPLEX_NO);
  ssSetInputPortDirectFeedThrough(S, 0, 1);
  ssSetInputPortAcceptExprInRTW(S, 0, 1);
  ssSetInputPortOverWritable(S, 0, 1);
  ssSetInputPortOptimOpts(S, 0, SS_REUSABLE_AND_LOCAL);
  ssSetInputPortRequiredContiguous(S, 0, 1);

  /*
   * Set the number of output ports.
   */
  if (!ssSetNumOutputPorts(S, 1)) return;

  /*
   * Configure the output port 1
   */
  ssSetOutputPortDataType(S, 0, SS_DOUBLE);
  ssSetOutputPortWidth(S, 0, 1);
  ssSetOutputPortComplexSignal(S, 0, COMPLEX_NO);
  ssSetOutputPortOptimOpts(S, 0, SS_REUSABLE_AND_LOCAL);
  ssSetOutputPortOutputExprInRTW(S, 0, 1);

  /*
   * Set the number of sample time. 
   */
  ssSetNumSampleTimes(S, 1);
#if defined(ssSetModelReferenceSampleTimeDefaultInheritance)
  ssSetModelReferenceSampleTimeDefaultInheritance(S);
#endif

  /*
   * All options have the form SS_OPTION_<name> and are documented in
   * matlabroot/simulink/include/simstruc.h. The options should be
   * bitwise or'd together as in
   *   ssSetOptions(S, (SS_OPTION_name1 | SS_OPTION_name2))
   */
  ssSetOptions(S,
   SS_OPTION_USE_TLC_WITH_ACCELERATOR |
   SS_OPTION_CAN_BE_CALLED_CONDITIONALLY |
   SS_OPTION_EXCEPTION_FREE_CODE |
   SS_OPTION_WORKS_WITH_CODE_REUSE |
   SS_OPTION_SFUNCTION_INLINED_FOR_RTW |
   SS_OPTION_DISALLOW_CONSTANT_SAMPLE_TIME);
}

/* Function: mdlInitializeSampleTimes =====================================
 * Abstract:
 *    This function is used to specify the sample time(s) for your
 *    S-function. You must register the same number of sample times as
 *    specified in ssSetNumSampleTimes.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
  ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
  ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
}

#define MDL_SET_WORK_WIDTHS
#if defined(MDL_SET_WORK_WIDTHS) && defined(MATLAB_MEX_FILE)
/* Function: mdlSetWorkWidths =============================================
 * Abstract:
 *      The optional method, mdlSetWorkWidths is called after input port
 *      width, output port width, and sample times of the S-function have
 *      been determined to set any state and work vector sizes which are
 *      a function of the input, output, and/or sample times. 
 *
 *      Run-time parameters are registered in this method using methods 
 *      ssSetNumRunTimeParams, ssSetRunTimeParamInfo, and related methods.
 */
static void mdlSetWorkWidths(SimStruct *S)
{
  /* Set number of run-time parameters */
  if (!ssSetNumRunTimeParams(S, 3)) return;

  /*
   * Register the run-time parameter 1
   */
  ssRegDlgParamAsRunTimeParam(S, 0, 0, "p1", ssGetDataTypeId(S, "double"));

  /*
   * Register the run-time parameter 2
   */
  ssRegDlgParamAsRunTimeParam(S, 1, 1, "p2", ssGetDataTypeId(S, "double"));

  /*
   * Register the run-time parameter 3
   */
  ssRegDlgParamAsRunTimeParam(S, 2, 2, "p3", ssGetDataTypeId(S, "int16"));
}
#endif

/* Function: mdlOutputs ===================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block. Generally outputs are placed in the output vector(s),
 *    ssGetOutputPortSignal.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
  /*
   * Get access to Parameter/Input/Output information
   */
  real_T *p1 = (real_T *) ssGetRunTimeParamInfo(S, 0)->data;
  real_T *p2 = (real_T *) ssGetRunTimeParamInfo(S, 1)->data;
  int16_T *p3 = (int16_T *) ssGetRunTimeParamInfo(S, 2)->data;
  real_T *u1 = (real_T *) ssGetInputPortSignal(S, 0);
  real_T *y1 = (real_T *) ssGetOutputPortSignal(S, 0);

  /*
   * Call the legacy code function
   */
  *y1 = SimpleTable( *u1, p1, p2, *p3);
}

/* Function: mdlTerminate =================================================
 * Abstract:
 *    In this function, you should perform any actions that are necessary
 *    at the termination of a simulation.
 */
static void mdlTerminate(SimStruct *S)
{
}

/*
 * Required S-function trailer
 */
#ifdef MATLAB_MEX_FILE
# include "simulink.c"
#else
# include "cg_sfun.h"
#endif
