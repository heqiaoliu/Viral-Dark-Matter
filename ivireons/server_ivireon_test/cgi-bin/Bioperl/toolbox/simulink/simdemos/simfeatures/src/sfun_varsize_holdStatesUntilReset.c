/* Copyright 2005-2009 The MathWorks, Inc.
 * This C-MEX S-function implements a delay block.
 * This S-function requires that its DWorks to be reset whenever the sizes
 * of the input signal changes.
 * $Revision: 1.1.6.1 $ $Date: 2009/05/14 17:51:58 $
 */

#define S_FUNCTION_NAME sfun_varsize_holdStatesUntilReset
#define S_FUNCTION_LEVEL 2
#include "simstruc.h"

#define DWORK_WIDTH 20
#define NUM_DWORKS 1


/* Function: mdlSetInputPortDimsMode ======================================
 * Abstract:
 *   Set the output port dimension mode based on the input dimension mode.
 */
static void mdlSetInputPortDimsMode(SimStruct *S, int pIdx, DimensionsMode_T dm)
{
    ssSetInputPortDimensionsMode(S, pIdx, dm);
    ssSetOutputPortDimensionsMode(S, 0, dm);
}

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *   Initialize block properties, such as sample time, number of ports, 
 *   port dimensions and DWorks.
  */
static void mdlInitializeSizes(SimStruct *S)
{
    /* Initialize the inputs */
    const int_T numInputPorts = 1;
    const int_T numOutputPorts = 1;
    const int_T numSFcnParams = 0;
    const int_T numSampleTimes = 1;
   
    /* The Block does not have any parameters */
    ssSetNumSFcnParams(S, numSFcnParams);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        return; /* Parameter mismatch will be reported by Simulink */
    }

    /* Initialize the input port(s) */
    if (!ssSetNumInputPorts(S, numInputPorts))
    {
        return;
    }
    if (!ssSetInputPortDimensionInfo(S, 0, DYNAMIC_DIMENSION))
    {
        return;
    }
    ssSetInputPortDirectFeedThrough(S, 0, 0);

    /* Initialize the output port(s) */
    if (!ssSetNumOutputPorts(S, numOutputPorts))
    {
        return;
    }
    if (!ssSetOutputPortDimensionInfo(S, 0, DYNAMIC_DIMENSION)) 
    {
        return;
    }

    ssSetNumSampleTimes(S, numSampleTimes);
    ssSetInputPortDimensionsMode(S, 0, INHERIT_DIMS_MODE);
    ssSetOutputPortDimensionsMode(S, 0, INHERIT_DIMS_MODE);
    ssRegMdlSetInputPortDimensionsModeFcn(S, mdlSetInputPortDimsMode);
    ssSetInputPortRequiredContiguous(S, 0, true);

    /* Set up the DWork vectors */
    if (!ssSetNumDWork(S, DYNAMICALLY_SIZED))
    {
        return;
    }

    /* Take care when specifying exception-free code */
    ssSetOptions(S,
                 SS_OPTION_WORKS_WITH_CODE_REUSE |
                 SS_OPTION_EXCEPTION_FREE_CODE |
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}

/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Sample time is inherited from the driving block.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S); 
}

/* Function: setOutputDims ======================================
 * Abstract:
 *   Set the output port run-time dimensions.
 */
static void setOutputDims(SimStruct *S, 
                          int_T outIdx, 
                          int_T *inputs, 
                          int_T numInputs)
{
    ssSetCurrentOutputPortDimensions(S, 0, 0, 
                                     ssGetCurrentInputPortDimensions(S, 0, 0));
    ssSetCurrentOutputPortDimensions(S, 0, 1, 
                                     ssGetCurrentInputPortDimensions(S, 0, 1));
    UNUSED_ARG(numInputs);
    UNUSED_ARG(inputs);
    UNUSED_ARG(outIdx);
}

#define MDL_SET_WORK_WIDTHS
#if defined(MDL_SET_WORK_WIDTHS) && defined(MATLAB_MEX_FILE)
static void mdlSetWorkWidths(SimStruct *S)
{
    /* Declare the DWorks vectors */
    int_T inputs[] = {0};
    DimsDependInfo_T dimsDepInfo;
    const DTypeId inputDataType = ssGetInputPortDataType(S, 0);

    ssSetNumDWork(S, NUM_DWORKS);
    ssSetDWorkWidth(S, 0, DWORK_WIDTH);
    ssSetDWorkDataType(S, 0, inputDataType);
    ssSetDWorkRequireResetForSignalSize(S,
                                        0,
                                        SS_VARIABLE_SIZE_REQUIRE_STATE_RESET);

    ssSetSignalSizesComputeType(S, SS_VARIABLE_SIZE_FROM_INPUT_SIZE);

    dimsDepInfo.inputs = inputs;
    dimsDepInfo.numInputs = 1;
    dimsDepInfo.setOutputDimsFcn = setOutputDims;
    ssAddOutputDimsDependencyRule(S, 0, &dimsDepInfo);
}
#endif /* MDL_SET_WORK_WIDTHS */

#define MDL_INITIALIZE_CONDITIONS
/* Function: mdlInitializeConditions ==========================================
 * Abstract:
 *    Initialize the DWork vectors to zero
 */
static void mdlInitializeConditions(SimStruct *S)
{    
    int_T idx = 0;

    /* get the DWork vectors */
    real_T *x = ssGetDWork(S, 0);

    /* get the width of the DWORK vector */
    const int_T DWorkWidth = ssGetDWorkWidth(S, 0);
    
    /* Initialize all the DWork vectors to zero */
    for (idx = 0; idx < DWorkWidth; idx++)
    {
        x[idx] = 0.0;        
    }
}

/* Function: mdlOutputs =======================================================
 * Abstract:
 *    Copy the DWorks to the output buffer
 *    y_n = x_n
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    int_T idx;
    int_T outputWidth = 1;
    const real_T *x = (real_T *) ssGetDWork(S, 0);
    real_T *y = ssGetOutputPortRealSignal(S, 0);
    int_T numOutputPortDims = ssGetOutputPortNumDimensions(S, 0);
    UNUSED_ARG(tid);

    /* Get the width of the output port */
    for (idx = 0; idx < numOutputPortDims; idx++)
    {
        outputWidth *= ssGetCurrentOutputPortDimensions(S, 0, idx);
    }
    
    for (idx = 0; idx < outputWidth; idx++) 
    {
        *y++ = x[idx];
    }
}

#define MDL_UPDATE
/* Function: mdlUpdate ========================================================
 * Abstract:
 *    Update the state with the input signal
 */
static void mdlUpdate(SimStruct *S, int_T tid)
{
    int_T idx;
    int_T inputWidth = 1;
    real_T *xstate = (real_T *) ssGetDWork(S, 0);
    const real_T *uPtrs = ssGetInputPortRealSignal(S, 0);
    
    /* Get the current number of input port dimensions */
    int_T numInputPortDims = ssGetInputPortNumDimensions(S, 0);

    UNUSED_ARG(tid);

    /* Get the width of the input port */
    for (idx = 0; idx < numInputPortDims; idx++)
    {
        inputWidth *= ssGetCurrentInputPortDimensions(S, 0, idx);
    }

    /* Set the state value equal to the input value */
    for (idx = 0; idx < inputWidth; idx++)
    {
        *xstate++ = uPtrs[idx];
    }
}

/* Function: mdlTerminate =====================================================
 * Abstract:
 *    No termination needed, but we are required to have this routine.
 */
static void mdlTerminate(SimStruct *S)
{
    UNUSED_ARG(S);
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as an MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
