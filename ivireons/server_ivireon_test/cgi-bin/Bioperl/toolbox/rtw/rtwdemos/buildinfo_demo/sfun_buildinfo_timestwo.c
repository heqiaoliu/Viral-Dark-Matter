/*
 *  File : sfun_buildinfo_timestwo.c
 * 
 *  Abstract:
 *  S-Function source file for demo rtwdemo_buildinfo. 
 *
 *  Copyright 1994-2007 The MathWorks, Inc.
 *  $Revision: 1.1.8.2 $
 */


#define S_FUNCTION_NAME  sfun_buildinfo_timestwo
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

/* Source file from custom code page */
extern int buildinfo_custom_src(int i);

/* S-Function src in S modules list */
extern int sfun_buildinfo_src_module_func(int i);

/* Source files in rtwmakecfg */
extern int sfun_rtwmakecfg_module_01(int i);
extern int sfun_rtwmakecfg_module_02(int i);
extern int sfun_rtwmakecfg_module_03(int i);

/*================*
 * Build checking *
 *================*/


/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *   Setup sizes of the various vectors.
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 0);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        return; /* Parameter mismatch will be reported by Simulink */
    }

    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(S, 0, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, 0, 1);

    if (!ssSetNumOutputPorts(S,1)) return;
    ssSetOutputPortWidth(S, 0, DYNAMICALLY_SIZED);

    ssSetNumSampleTimes(S, 1);

    /* Take care when specifying exception free code - see sfuntmpl_doc.c */
    ssSetOptions(S, 
                 SS_OPTION_EXCEPTION_FREE_CODE);
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

/* Function: mdlOutputs =======================================================
 * Abstract:
 *    y = 2*u
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    int_T             i;
    InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S,0);
    real_T            *y    = ssGetOutputPortRealSignal(S,0);
    int_T             width = ssGetOutputPortWidth(S,0);

    /* internal tracking variable */
    static int x=0;

    for (i=0; i<width; i++) {

        /* update the internal tracking data. This code is for
         * demonstrating the build info feature, and has no functional
         * value
         */
        x = buildinfo_custom_src(i);
        x += sfun_buildinfo_src_module_func(i);
        x += sfun_rtwmakecfg_module_01(i);
        x += sfun_rtwmakecfg_module_02(i);
        x += sfun_rtwmakecfg_module_03(i);
        /*
         * This example does not implement complex signal handling.
         * To find out see an example about how to handle complex signal in 
         * S-function, see sdotproduct.c for details.
         */
        *y++ = 2.0 *(*uPtrs[i]); 
    }
}


/* Function: mdlTerminate =====================================================
 * Abstract:
 *    No termination needed, but we are required to have this routine.
 */
static void mdlTerminate(SimStruct *S)
{
}



#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
