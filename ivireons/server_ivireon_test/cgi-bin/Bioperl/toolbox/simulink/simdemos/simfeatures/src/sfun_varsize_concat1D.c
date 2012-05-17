/* Copyright 2009 The MathWorks, Inc.
 * This C-MEX S-function implements the concatenation of two unoriented
 * vectors.
 * $Revision: 1.1.6.1 $ $Date: 2009/05/14 17:51:57 $
 */

#define S_FUNCTION_NAME sfun_varsize_concat1D
#define S_FUNCTION_LEVEL 2
#include "simstruc.h"


/* Function: mdlInitializeSizes ===========================================
 * Abstract:
 *   Initialize block properties, such as sample time, number of ports, 
 *   and port dimensions.
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 0);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) 
    {
        return; /* Parameter mismatch will be reported by Simulink */
    }

    /* Number of Input Ports */
    if (!ssSetNumInputPorts(S, 2)) 
    {
        return;
    }
    
    /* Input Port 0 */
    if (!ssSetInputPortDimensionInfo(S, 0, DYNAMIC_DIMENSION))
    {
        return;
    }
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    _ssSetInputPortNumDimensions(S, 0, 1);

    /* Input Port 1 */
    if (!ssSetInputPortDimensionInfo(S, 1, DYNAMIC_DIMENSION)) 
    {
        return;
    }
    ssSetInputPortDirectFeedThrough(S, 1, 1);
    _ssSetInputPortNumDimensions(S, 1, 1);

    /* Output Port */
    if (!ssSetNumOutputPorts(S, 1)) 
    {
        return;
    }

    if (!ssSetOutputPortDimensionInfo(S, 0, DYNAMIC_DIMENSION)) 
    {
        return;
    }
    _ssSetOutputPortNumDimensions(S, 0, 1);

    /* Sample Times */
    ssSetNumSampleTimes(S, 1);

    /* Dimension Modes of the Ports */
    ssSetInputPortDimensionsMode(S, 0, INHERIT_DIMS_MODE);
    ssSetInputPortDimensionsMode(S, 1, INHERIT_DIMS_MODE);
    ssSetOutputPortDimensionsMode(S, 0, INHERIT_DIMS_MODE);
    ssSetInputPortRequiredContiguous(S, 0, true);
    ssSetInputPortRequiredContiguous(S, 1, true);

    ssSetOptions(S,
                 SS_OPTION_WORKS_WITH_CODE_REUSE |
                 SS_OPTION_EXCEPTION_FREE_CODE |
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}

/* Function: mdlInitializeSampleTimes =====================================
 * Abstract:
 *    Specifiy the inheritance of sample time from the driving block.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S); 
}

/*Function: setOutputDims =================================================
 *Abstract:
 *  Set the compiled output dimensions based on the input dimensions.
 */
static void setOutputDims(SimStruct *S, int outIdx, int *inputs, int numInputs)
{
    /* Read the current input port dimensions */
    int ix;
    int oDims = 0;
    for (ix = 0; ix < numInputs; ix++) 
    {
        oDims = oDims + ssGetCurrentInputPortDimensions(S, inputs[ix], 0); 
    }
    ssSetCurrentOutputPortDimensions(S, outIdx, 0, oDims);
    UNUSED_ARG(numInputs);
}

#define MDL_SET_WORK_WIDTHS   /* Change to #undef to remove function */
#if defined(MDL_SET_WORK_WIDTHS) && defined(MATLAB_MEX_FILE)
static void mdlSetWorkWidths(SimStruct *S)
{
    int inputs[] = {0, 1};
    DimsDependInfo_T dimsDepInfo;
    ssSetSignalSizesComputeType(S, SS_VARIABLE_SIZE_FROM_INPUT_SIZE);
    dimsDepInfo.inputs = inputs;
    dimsDepInfo.numInputs = 2;
    dimsDepInfo.setOutputDimsFcn = setOutputDims;
    ssAddOutputDimsDependencyRule(S, 0, &dimsDepInfo);
}
#endif /* MDL_SET_WORK_WIDTHS */

/* Function: mdlOutputs ===================================================
 * Abstract:
 *    Set output values as the concatenation of the input values 
 *    y = [u1 u2]
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    int_T i;
    const real_T *uPtrs1 = ssGetInputPortRealSignal(S, 0);
    const real_T *uPtrs2 = ssGetInputPortRealSignal(S, 1);
    real_T *y = ssGetOutputPortRealSignal(S, 0);
    int uWidth1 = ssGetCurrentInputPortDimensions(S, 0, 0);
    int uWidth2 = ssGetCurrentInputPortDimensions(S, 1, 0);
    UNUSED_ARG(tid);

    for (i = 0; i < uWidth1; i++) 
    {
        *y++ = uPtrs1[i]; 
    }
    for (i = 0; i < uWidth2; i++) 
    {
         *y++ = uPtrs2[i]; 
    }
}

#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_WIDTH
/* Function: mdlSetInputPortWidth =========================================
 * Abstract:
 *    Set the output port width based on the width of the inputs.
 */
static void mdlSetInputPortWidth(SimStruct *S, 
                                 int_T port,
                                 int_T width)
{
    ssSetInputPortWidth(S, port, width);
    if (ssGetInputPortWidth(S, 0) != DYNAMICALLY_SIZED &&
        ssGetInputPortWidth(S, 1) != DYNAMICALLY_SIZED) 
    {
        ssSetOutputPortWidth(S, 0, ssGetInputPortWidth(S, 0) + 
                             ssGetInputPortWidth(S, 1));
    }
}

#define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, 
                                  int_T port,
                                  int_T width)
{
    UNUSED_ARG(S);
    UNUSED_ARG(port);
    UNUSED_ARG(width);
    return;
}
#endif

/* Function: mdlTerminate =================================================
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
