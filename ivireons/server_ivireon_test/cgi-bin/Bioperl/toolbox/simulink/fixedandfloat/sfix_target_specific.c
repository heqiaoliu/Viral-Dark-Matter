/* Copyright 1994-2009 The MathWorks, Inc.
 * $Revision: 1.18.2.8 $  
 * $Date: 2009/02/18 02:26:09 $
 *
 * File      : sfix_target_specific.c
 *
 * Abstract:
 *      S-function for determining hardware characteristics
 */


/*=====================================*
 * Required setup for C MEX S-Function *
 *=====================================*/
#define S_FUNCTION_NAME sfix_target_specific
#define S_FUNCTION_LEVEL 2

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include "simstruc.h"
 
#include "hostcpuinfo.h"

/*========================*
 * General Defines/macros *
 *========================*/

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *   Initialize the sizes array
 */
static void mdlInitializeSizes(SimStruct *S)
{
    /*
     * Set and Check parameter count
     */
    ssSetNumSFcnParams(S, 0);

    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;

    /*
     * set sizes
     */
    if ( !ssSetNumOutputPorts( S, 4) ) return;
    if ( !ssSetNumInputPorts(  S, 0) ) return;

    {
        /*
         * outputs
         */
        ssSetOutputPortWidth( S, 0, 1 );
        ssSetOutputPortOptimOpts(S,0,SS_REUSABLE_AND_LOCAL);

        ssSetOutputPortWidth( S, 1, 1 );
        ssSetOutputPortOptimOpts(S,1,SS_REUSABLE_AND_LOCAL);

        ssSetOutputPortWidth( S, 2, 1 );
        ssSetOutputPortOptimOpts(S,2,SS_REUSABLE_AND_LOCAL);

        ssSetOutputPortWidth( S, 3, 4 );
        ssSetOutputPortOptimOpts(S,3,SS_REUSABLE_AND_LOCAL);

        /*
         * sample times
         */
        ssSetNumSampleTimes(   S, 1 );

        /*
         * options
         */
        ssSetOptions( S, 
                     (
                         SS_OPTION_RUNTIME_EXCEPTION_FREE_CODE | \
                         SS_OPTION_USE_TLC_WITH_ACCELERATOR |    \
                         SS_OPTION_WORKS_WITH_CODE_REUSE |       \
                         SS_OPTION_NONVOLATILE |                 \
                         SS_OPTION_CALL_TERMINATE_ON_EXIT |      \
                         SS_OPTION_CAN_BE_CALLED_CONDITIONALLY
                     )
                    );
    }
} /* end mdlInitializeSizes */



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Initialize the sample times array.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
  /*
   * set sample time
   */
  ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);

} /* end mdlInitializeSampleTimes */



/* Function: mdlOutputs =======================================================
 * Abstract:
 *   Compute the outputs of the S-function.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
  real_T  *y;
  double cpu_info[7]; 
  (void) S;
  (void) tid;

  /* hostcpuinfo_helper returns an array of doubles containing information about the
   * host cpu.  This information is dynamically calculated, so should be
   * host independent.  The array contains the following information:
   *
   * element #   Value/descrtiption
   *    0        Shift right behavior
   *               0 == logical
   *               1 == arithmetic
   *    1        Signed Integer division rounding
   *               1 == round toward floor
   *               2 == round toward 0
   *               3 == undefined rounding behavior
   *    2        Byte ordering
   *               0 == Little Endian
   *               1 == Big Endian
   *    3        Number of bits per char
   *    4        Number of bits per short
   *    5        Number of bits per int
   *    6        Number of bits per long
   */
  hostcpuinfo(cpu_info); 

  /* shifts right on signed integers */
  y = (real_T *)ssGetOutputPortSignal(S,0);
  y[0] = cpu_info[0];

  /* negative operand integer division rounding  */
  y = (real_T *)ssGetOutputPortSignal(S,1);
  y[0] = cpu_info[1];
  
  /* Byte ordering */
  y = (real_T *)ssGetOutputPortSignal(S,2);
  y[0] = cpu_info[2];

  /* bits per char, short, int, long */
  y = (real_T *)ssGetOutputPortSignal(S,3);
  y[0] = cpu_info[3];
  y[1] = cpu_info[4];
  y[2] = cpu_info[5];
  y[3] = cpu_info[6];

} /* end mdlOutputs */



/* Function: mdlTerminate =====================================================
 * Abstract:
 *    Called when the simulation is terminated.
 */
static void mdlTerminate(SimStruct *S)
{
    (void) S;
} /* end mdlTerminate */



/* Function: mdlRTW ===========================================================
 * Abstract:
 *   RTW function.  Write parameters and parameter settings:
 */
#define MDL_RTW
static void mdlRTW(SimStruct *S)
{
    (void) S;
} /* end mdlRTW */



/*=======================================*
 * Required closing for C MEX S-Function *
 *=======================================*/

#ifdef    MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
# include "simulink.c"     /* MEX-file interface mechanism               */
#else
# include "cg_sfun.h"      /* Code generation registration function      */
#endif


/* [EOF] sfix_target_specific.c */



