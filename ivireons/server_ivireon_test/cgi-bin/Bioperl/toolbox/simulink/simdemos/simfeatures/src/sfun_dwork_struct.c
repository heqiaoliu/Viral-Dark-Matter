/*  File    : sfun_dwork_struct.c
 *  Abstract:
 *
 *      Example of an S-function that creates a DWork element that is a
 *      structure:
 *
 *               +--------+
 *      input -->|  sfcn  |--------> input from last time step (delay)
 *               |        |--------> number of times we've seen nonzero inputs
 *               +--------+
 *
 *      For more details about S-functions, see src/simulink/sfuntmpl_doc.c
 *
 *
 * Copyright 1990-2010 The MathWorks, Inc.
 * $Revision: 1.1.6.1 $
 */


#define S_FUNCTION_NAME  sfun_dwork_struct
#define S_FUNCTION_LEVEL 2

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include "simstruc.h"

#ifndef MATLAB_MEX_FILE
/*
 * For the Real-Time Workshop and the Simulink Accelerator, the 
 * matlabroot/toolbox/simulink/blocks/tlc_c/sfun_dwork_struct.tlc 
 * must be used.
 */
# error This_file_can_be_used_only_during_simulation_inside_Simulink
#endif


typedef struct {
    int_T  counter;  /* number of times state has been non-zero */
    real_T state;
} CounterStateStruct;




/*====================*
 * S-function methods *
 *====================*/

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 0);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        /* Return if number of expected != number of actual parameters */
        return;
    }

    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(S, 0, 1);
    ssSetInputPortRequiredContiguous(S, 0, true); /*direct input signal access*/
    ssSetInputPortDirectFeedThrough(S, 0, 0);

    if (!ssSetNumOutputPorts(S, 2)) return;
    ssSetOutputPortWidth(S, 0, 1);
    ssSetOutputPortWidth(S, 1, 1);

    ssSetNumSampleTimes(S, 1);

    /* 
     * Create a DWork data structure.
     */
    {
        int dtId;

        /*
         * Use caution to avoid name conflicts when registering the
         * data type name. The suggested naming convention is to use
         * a common prefix based on your Blockset's name for each data type 
         * registered by S-functions in your blocks set. If the S-function
         * is not part of a blockset, then use your company's name as a prefix.
         * The data type name is limited to 31 characters.
         */
       
        dtId = ssRegisterDataType(S, "ExampleCounterStateStruct");
        if (dtId == INVALID_DTYPE_ID ) return;

        /* Register the size of the udt */
        if (!ssSetDataTypeSize(S, dtId, sizeof(CounterStateStruct))) return;

        ssSetNumDWork(S,1);
        ssSetDWorkDataType(S, 0, dtId);
        ssSetDWorkWidth(S, 0, 1);
        ssSetDWorkName(S, 0, "CSStruct"); /*optional name, less than 16 chars*/
    }

    /* specify the sim state compliance to be same as a built-in block */
    ssSetSimStateCompliance(S, USE_DEFAULT_SIM_STATE);

    ssSetOptions(S,
                 SS_OPTION_WORKS_WITH_CODE_REUSE |
                 SS_OPTION_RUNTIME_EXCEPTION_FREE_CODE |
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    This function is used to specify the sample time(s) for your
 *    S-function. You must register the same number of sample times as
 *    specified in ssSetNumSampleTimes.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}





#define MDL_START   /* Change to #undef to remove function */
#if defined(MDL_START)
  /* Function: mdlStart ========================================================
   * Abstract:
   *    Initialize the counter state structure at model startup. If desired,
   *    we could also have an mdlInitializeConditions() method to reset the
   *    state and/or counter to zero for enabled subsystem restarts. For the
   *    sake of simplicity, we have not added this method.
   */
  static void mdlStart(SimStruct *S)
  {
      CounterStateStruct *p = (CounterStateStruct*)ssGetDWork(S,0);

      p->counter = 0;
      p->state   = 0.0;
  }
#endif /* MDL_START */



/* Function: mdlOutputs =======================================================
 * Abstract:
 *    Produce outputs for:
 *               +--------+
 *      input -->|  sfcn  |--------> input from last time step (delay)
 *               |        |--------> number of times we've seen nonzero inputs
 *               +--------+
 *    
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    CounterStateStruct *p = (CounterStateStruct*)ssGetDWork(S,0);
    real_T             *y = ssGetOutputPortSignal(S,0);
    y[0] = p->state;
    y[1] = p->counter;
}



#define MDL_UPDATE  /* Change to #undef to remove function */
#if defined(MDL_UPDATE)
  /* Function: mdlUpdate ======================================================
   * Abstract:
   *    Update dwork for:
   *               +--------+
   *      input -->|  sfcn  |--------> input from last time step (delay)
   *               |        |--------> number of times we've seen nonzero inputs
   *               +--------+
   */
  static void mdlUpdate(SimStruct *S, int_T tid)
  {
      const real_T *u       = (const real_T*) ssGetInputPortSignal(S,0);
      CounterStateStruct *p = (CounterStateStruct*)ssGetDWork(S,0);
      p->state   = u[0];
      p->counter += (u[0] != 0.0);
  }
#endif /* MDL_UPDATE */



/* Function: mdlTerminate =====================================================
 * Abstract:
 *    In this function, you should perform any actions that are necessary
 *    at the termination of a simulation.  For example, if memory was
 *    allocated in mdlStart, this is the place to free it.
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
