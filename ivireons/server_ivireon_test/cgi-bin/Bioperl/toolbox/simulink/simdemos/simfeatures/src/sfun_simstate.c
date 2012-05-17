/*
 * File    : sfun_simstate.c
 * Abstract:
 *
 *   This file represents an S-function example which demonstrates the
 *   S-function API for saving and restoring the simulation state. This
 *   S-function computes the "running" minimum, maximum, average and variance of
 *   the input signal and outputs them on the four output ports.
 *
 *   The S-function uses a one-element pointer work (PWork) vector to store a
 *   pointer to the data structure (RunTimeData_T) used in the block's
 *   implementation.
 *
 *   The data structure, RunTimeData_T, is allocated and initialized in
 *   the mdlStart method, de-allocated in the mdlTerminate method, and updated in
 *   the mdlOutputs method.
 *
 *   This S-function illustrates the use of the S-function option:
 *
 *        ssSetSimStateCompliance(S, setting)
 *
 *   to specify the S-function's behavior when saving and restoring the
 *   simulation state of a model containing this S-function. The setting can be
 *   one of the following:
 *
 *     SIM_STATE_COMPLIANCE_UNKNOWN
 *
 *     This is the default setting for all S-functions. For S-functions that do
 *     not use PWorks, Simulink saves and restores the default (see next
 *     option) simulation state. Simulink issues a warning to inform the user of
 *     this assumption. On the other hand, if, while saving or restoring the
 *     simulation state, Simulink encounters an S-function that uses PWorks,
 *     then Simulink errors out.
 *
 *     USE_DEFAULT_SIM_STATE
 *
 *     This setting informs Simulink to treat the S-function like a built-in
 *     block when Simulink is saving and restoring the simulation state.
 *
 *     HAS_NO_SIM_STATE
 *
 *     This setting informs Simulink that this S-function does not have any
 *     simulation state. With this setting, Simulink does not save any
 *     state information for this block. This setting is primarily useful for
 *     "sink" blocks (i.e., blocks with no output ports) that use PWorks or
 *     DWorks to store handles in files or figure windows.
 *
 *     DISALLOW_SIM_STATE
 *
 *     This setting informs Simulink that the S-function does not allow
 *     the saving and restoring of its simulation state. Simulink reports
 *     an error while saving or restoring the simulation state for a model
 *     containing this S-function.
 *
 *     USE_CUSTOM_SIM_STATE
 *
 *     This setting informs Simulink that the S-function uses custom methods
 *     (mdlSetSimState and mdlGetSimState) to save and restore its
 *     simulation state. Note that defining MDL_SIM_STATE macro and
 *     providing the mdlS[G]etSimState methods automatically sets the
 *     SimStateCompliance setting to this value.
 *
 *   In the mdlGetSimState method, the S-function is expected to return its
 *   simulation state as a valid MATLAB data structure (such as a matrix, a
 *   structure, or a cell array). In the mdlSetSimState method, the S-function
 *   is expected to initialize its internal data using the MATLAB data structure
 *   passed in.
 *
 *   The mdl[SG]etSimState methods are called after mdlStart, and before
 *   mdlTerminate). Consequently, all of the S-function's data structures (e.g.,
 *   states, DWork vectors, outputs) are available.
 *
 *   There is also an S-function option:
 *
 *      ssSetSimStateVisibility(S, visibility);
 *
 *   to specify whether the S-function's simulation state should be made
 *   visible in the model's simulation state. The default is false (i.e., the
 *   state is hidden). If you make this data visible, then you can modify
 *   it in MATLAB and the modified values can be restored.
 *
 * Copyright 2008-2009 The MathWorks, Inc.
 * $Revision: 1.1.6.3 $
 *
 */

#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME  sfun_simstate

#include "simstruc.h"
#include <math.h> /* sqrt */

/* Function: GetSimSnapParameterSetting ========================================
 * Abstract:
 *
 *   Check and get the S-function's simulation state compliance for its
 *   string parameter.
 *
 */
static ssSimStateCompliance GetSimSnapParameterSetting(
    SimStruct* S,
    boolean_T* visibility)
{
    typedef struct SimSnapComplianceEnumStrs_Tag {
        const char* str;
        ssSimStateCompliance val;
    } SimSnapComplianceEnumStrs_T;

    static const SimSnapComplianceEnumStrs_T simSnapComplianceSettings[] =
        {
            {"Unknown", SIM_STATE_COMPLIANCE_UNKNOWN},
            {"Default", USE_DEFAULT_SIM_STATE},
            {"HasNoSimState", HAS_NO_SIM_STATE},
            {"Custom",  USE_CUSTOM_SIM_STATE},
            {"Disallow", DISALLOW_SIM_STATE}
        };
    static const int nSimSnapComplianceSettings =
        sizeof(simSnapComplianceSettings)/sizeof(SimSnapComplianceEnumStrs_T);

    int i;
    char strBuf[64];
    const mxArray* mxa = ssGetSFcnParam(S, 0);
    if (!mxIsChar(mxa) || mxGetString(mxa, strBuf, 63) != 0) {
        ssSetErrorStatus(S, "First parameter must be a string");
        goto EXIT_POINT;
    }

    if (!mxIsLogicalScalar(ssGetSFcnParam(S, 1))) {
        ssSetErrorStatus(S, "Second parameter must be logical scalar");
        goto EXIT_POINT;
    }
    *visibility = mxIsLogicalScalarTrue(ssGetSFcnParam(S, 1));

    for (i = 0; i < nSimSnapComplianceSettings; ++i) {
        if (strcmp(strBuf, simSnapComplianceSettings[i].str) == 0) {
            return simSnapComplianceSettings[i].val;
        }
    }
    ssSetErrorStatus(S, "Invalid parameter value");

  EXIT_POINT:
    return SIM_STATE_COMPLIANCE_UNKNOWN;
}

/* Function: mdlInitializeSizes ================================================
 * Abstract:
 *
 *   Register an S-function with one input port, four output ports, and one
 *   PWork vector.  Specify its simulation state compliance based on the first
 *   string parameter value. The second (boolean) parameter specifies if the
 *   simulation state should be visible in the model's simulation state.
 *
 */
static void mdlInitializeSizes(SimStruct* S)
{
    ssSetNumSFcnParams(S, 2); /* two parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    ssSetSFcnParamTunable(S, 0, false);
    ssSetSFcnParamTunable(S, 1, false);

    {
        boolean_T visibility = 0U;
        ssSimStateCompliance setting =
            GetSimSnapParameterSetting(S, &visibility);
        if (ssGetErrorStatus(S)) return;

        ssSetSimStateCompliance(S, setting);
        ssSetSimStateVisibility(S, visibility);
    }

    /* register one input port and its attributes */
    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortRequiredContiguous(S, 0, 1);
    ssSetInputPortWidth(S, 0, DYNAMICALLY_SIZED);
    ssSetInputPortDataType(S, 0, DYNAMICALLY_TYPED);
    ssSetInputPortOverWritable(S, 0, 1);
    ssSetInputPortOptimOpts(S, 0, SS_REUSABLE_AND_LOCAL);

    /* register four output ports and their attributes */
    if (!ssSetNumOutputPorts(S, 4)) return;
    {
        int op = 0;
        for (op = 0; op < 4; ++op) {
            ssSetOutputPortWidth(S, op, DYNAMICALLY_SIZED);
            ssSetOutputPortDataType(S, op, SS_DOUBLE);
            ssSetOutputPortOptimOpts(S, op, SS_REUSABLE_AND_LOCAL);
        }
    }

    ssSetNumPWork(S, 1);

    ssSetNumSampleTimes(S, 1);

    ssSetOptions(S,
                 SS_OPTION_EXCEPTION_FREE_CODE |
                 SS_OPTION_WORKS_WITH_CODE_REUSE |
                 SS_OPTION_ALLOW_INPUT_SCALAR_EXPANSION);

}

/* Function: mdlInitializeSampleTimes ==========================================
 * Abstract:
 *   This block does not run in minor time steps, i.e., it can inherit any
 *   sample time other than continuous.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}

/* RunTimeData_T ===============================================================
 *
 */
typedef struct RunTimeData_Tag {

    uint64_T cnt; /* number of major steps */
    double*  min; /* running minimum */
    double*  max; /* running minimum */
    double*  avg; /* running average */
    double*  var; /* running variance */

} RunTimeData_T;

/* NULL_CHECK ==================================================================
 *
 */
#define NULL_CHECK(x) \
    if ((x) == NULL) { \
        ssSetErrorStatus(S, "Memory allocation error"); \
        return; \
    }

#define MDL_START /* to indicate that the S-function has mdlStart method */

/* Function: mdlStart ==========================================================
 * Abstract:
 *   Allocate and initialize run-time data and cache the pointer in the PWork.
 */
static void mdlStart(SimStruct *S)
{
    int i;
    int n = ssGetInputPortWidth(S,0);

    RunTimeData_T* rtd = (RunTimeData_T*)calloc(1, sizeof(RunTimeData_T));
    NULL_CHECK(rtd);
    ssSetPWorkValue(S, 0, rtd);

    rtd->min = (double*)malloc(n*sizeof(double));
    NULL_CHECK(rtd->min);

    rtd->max = (double*)malloc(n*sizeof(double));
    NULL_CHECK(rtd->max);

    rtd->avg = (double*)malloc(n*sizeof(double));
    NULL_CHECK(rtd->avg);

    rtd->var = (double*)malloc(n*sizeof(double));
    NULL_CHECK(rtd->var);

    for (i = 0; i < n; ++i) {
        rtd->min[i] = mxGetNaN();
        rtd->max[i] = mxGetNaN();
        rtd->avg[i] = mxGetNaN();
        rtd->var[i] = 0.0;
    }
    rtd->cnt = 0;
}

#define SQR(x)  ((x)*(x))

/* Function: mdlOutputs ========================================================
 * Abstract:
 *  Update the running statistics in the run-time data structure and post
 *  outputs.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    int i;
    int n = ssGetInputPortWidth(S,0);
    const double* u = ssGetInputPortRealSignal(S, 0);
    RunTimeData_T* rtd = (RunTimeData_T*)ssGetPWorkValue(S, 0);

    if (rtd->cnt == 0) {
        for (i = 0; i < n; ++i) {
            rtd->min[i] = u[i];
            rtd->max[i] = u[i];
            rtd->avg[i] = u[i];
            rtd->var[i] = 0.0;
        }
    } else {
        double itp1 = rtd->cnt + 1;
        double itditp1 = (rtd->cnt / itp1);

        for (i = 0; i < n; ++i) {
            /* need previous avg for updating variance */
            double pavg = rtd->avg[i];
            /* compute the average */
            rtd->avg[i] = u[i]/itp1 + pavg*itditp1;

            /* compute the variance */
            {
                double term1 = SQR(u[i] - rtd->avg[i]);
                double term2 = SQR(pavg - rtd->avg[i]);
                rtd->var[i] = term1/itp1 + (rtd->var[i] + term2)*itditp1;
            }

            /* compute the minimum */
            if (u[i] < rtd->min[i]) rtd->min[i] = u[i];

            /* compute the minimum */
            if (u[i] > rtd->max[i]) rtd->max[i] = u[i];
        }
    }
    ++(rtd->cnt);

    /* post the outputs */
    {
        double* ym = ssGetOutputPortRealSignal(S,0);
        double* yM = ssGetOutputPortRealSignal(S,1);
        double* yA = ssGetOutputPortRealSignal(S,2);
        double* yS = ssGetOutputPortRealSignal(S,3);
        for (i = 0; i < n; ++i) {
            ym[i] = rtd->min[i];
            yM[i] = rtd->max[i];
            yA[i] = rtd->avg[i];
            yS[i] = sqrt(rtd->var[i]);
        }
    }
}

/*
 *
 */
static const char* fieldNames[] = {
    "Count",
    "Minimum",
    "Maximum",
    "Average",
    "Variance"
};
static const int nFields = sizeof(fieldNames) / sizeof(const char*);

/* Define to indicate that this S-function has the mdlG[S]etSimState method */
#define MDL_SIM_STATE

/* Function: mdlGetSimState ====================================================
 * Abstract:
 *   Package the RunTimeData structure as a MATLAB structure and return it.
 */
static mxArray* mdlGetSimState(SimStruct* S)
{
    int n = ssGetInputPortWidth(S, 0);
    RunTimeData_T* rtd = (RunTimeData_T*)ssGetPWorkValue(S, 0);

    /* Create a MATLAB structure to hold the run-time data */
    mxArray* simSnap = mxCreateStructMatrix(1, 1, nFields, fieldNames);

    /* Set the count field */
    {
        mxArray* cnt = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
        ((uint64_T*)(mxGetData(cnt)))[0] = rtd->cnt;
        mxSetFieldByNumber(simSnap, 0, 0, cnt);
    }

    /* minimum */
    {
        mxArray* min = mxCreateDoubleMatrix(n,1,mxREAL);
        memcpy(mxGetPr(min), rtd->min, n*sizeof(double));
        mxSetFieldByNumber(simSnap, 0, 1, min);
    }
    /* maximum */
    {
        mxArray* max = mxCreateDoubleMatrix(n,1,mxREAL);
        memcpy(mxGetPr(max), rtd->max, n*sizeof(double));
        mxSetFieldByNumber(simSnap, 0, 2, max);
    }
    /* average */
    {
        mxArray* avg = mxCreateDoubleMatrix(n,1,mxREAL);
        memcpy(mxGetPr(avg), rtd->avg, n*sizeof(double));
        mxSetFieldByNumber(simSnap, 0, 3, avg);
    }
    /* variance */
    {
        mxArray* var = mxCreateDoubleMatrix(n,1,mxREAL);
        memcpy(mxGetPr(var), rtd->var, n*sizeof(double));
        mxSetFieldByNumber(simSnap, 0, 4, var);
    }
    return simSnap;
}

#define ERROR_IF_NULL(S, x, msg)   \
    if (x == NULL) {               \
        ssSetErrorStatus(S, msg);  \
        return;                    \
    }

/* Function: mdlSetSimState ====================================================
 * Abstract:
 *   Unpack the MATLAB structure passed and restore it into the RunTimeData
 *   structure
 */
static void mdlSetSimState(SimStruct* S, const mxArray* simSnap)
{
    unsigned n = (unsigned)(ssGetInputPortWidth(S, 0));
    RunTimeData_T* rtd = (RunTimeData_T*)ssGetPWorkValue(S, 0);

    /* Check and Load the count value */
    {
        const mxArray* cnt = mxGetField(simSnap, 0, fieldNames[0]);
        ERROR_IF_NULL(S,cnt,"Count field not found in simulation state");
        if ( mxIsComplex(cnt) ||
             !mxIsUint64(cnt) ||
             mxGetNumberOfElements(cnt) != 1 ) {
            ssSetErrorStatus(S, "Count field is invalid");
            return;
        }
        rtd->cnt = ((uint64_T*)(mxGetData(cnt)))[0];
    }

    /* Check and load the minimum value */
    {
        const mxArray* min = mxGetField(simSnap, 0, fieldNames[1]);
        ERROR_IF_NULL(S,min,"Minimum field not found in simulation state");
        if ( mxIsComplex(min) ||
             !mxIsDouble(min) ||
             mxGetNumberOfElements(min) != n ) {
            ssSetErrorStatus(S, "Minimum field is invalid");
            return;
        }
        memcpy(rtd->min, mxGetData(min), n*sizeof(double));
    }

    /* Check and load the maximum value */
    {
        const mxArray* max = mxGetField(simSnap, 0, fieldNames[2]);
        ERROR_IF_NULL(S, max, "Maximum field not found in simulation state");
        if ( mxIsComplex(max) ||
             !mxIsDouble(max) ||
             mxGetNumberOfElements(max) != n ) {
            ssSetErrorStatus(S, "Maximum field is invalid");
            return;
        }
        memcpy(rtd->max, mxGetData(max), n*sizeof(double));
    }

    /* Check and load the average value */
    {
        const mxArray* avg = mxGetField(simSnap, 0, fieldNames[3]);
        ERROR_IF_NULL(S, avg, "Average field not found in simulation state");
        if ( mxIsComplex(avg) ||
             !mxIsDouble(avg) ||
             mxGetNumberOfElements(avg) != n ) {
            ssSetErrorStatus(S, "Average field is invalid");
            return;
        }
        memcpy(rtd->avg, mxGetData(avg), n*sizeof(double));
    }

    /* Check and load the variance value */
    {
        const mxArray* var = mxGetField(simSnap, 0, fieldNames[4]);
        ERROR_IF_NULL(S, var, "Variance field not found in simulation state");
        if ( mxIsComplex(var) ||
             !mxIsDouble(var) ||
             mxGetNumberOfElements(var) != n ) {
            ssSetErrorStatus(S, "Variance field is invalid");
            return;
        }
        memcpy(rtd->var, mxGetData(var), n*sizeof(double));
    }
}

/* Function: mdlTerminate ======================================================
 * Abstract:
 *   Free the run-time data pointer in the PWork.
 */
static void mdlTerminate(SimStruct* S)
{
    RunTimeData_T* rtd = (RunTimeData_T*)ssGetPWorkValue(S,0);
    free(rtd->min);
    free(rtd->max);
    free(rtd->avg);
    free(rtd->var);
    free(rtd);

    ssSetPWorkValue(S, 0, NULL);
}

/* Required S-Function trailer */

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as an MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
