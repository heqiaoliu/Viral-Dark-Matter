/*
 * File : sfun_runtime4.c
 * Abstract:
 *      Run-time parameter S-function example.
 *
 *      This S-function accepts 1 input, a linear force.
 *      The output is the acceleration of an object whose
 *      volume and density are entered as S-function parameters
 *
 *      The first parameter is the object's volume
 *      The second parameter is the object's density
 *
 *      Copyright 1990-2009 The MathWorks, Inc.
 */


/*
 * You must specify the S_FUNCTION_NAME as the name of your S-function.
 */

#define S_FUNCTION_NAME  sfun_runtime4
#define S_FUNCTION_LEVEL 2

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include <string.h>
#include "tmwtypes.h"
#include "simstruc.h"

/* Define the run-time parameter data type */
#define RUN_TIME_DATA_TYPE SS_DOUBLE
#if RUN_TIME_DATA_TYPE == SS_DOUBLE
typedef real_T RunTimeDataType;
#endif

#define VOL_IDX  0
#define VOL_PARAM(S) ssGetSFcnParam(S,VOL_IDX)

#define DEN_IDX   1
#define DEN_PARAM(S) ssGetSFcnParam(S,DEN_IDX)

#define NPARAMS   2

#if !defined(MATLAB_MEX_FILE)
/*
 * This file cannot be used directly with the Real-Time Workshop. However,
 * this S-function can work with the Real-Time Workshop via
 * the Target Language Compiler technology. For examples, see
 * matlabroot/toolbox/simulink/blocks/tlc_c/sfun_multiport.tlc
 * for the C version
 * matlabroot/toolbox/simulink/blocks/tlc_ada/sfun_multiport.tlc
 * for the Ada version
 */
# error This_file_can_be_used_only_during_simulation_inside_Simulink
#endif

/* Function: calcMass =========================================================
 * Abstract:
 *      Local function to calculate the mass as a function of volume
 *      and density.
 */
static void calcMass(RunTimeDataType *mass, real_T vol, real_T den)
{
  *mass = vol * den;
}

/*====================*
 * S-function methods *
 *====================*/

#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
  /* Function: mdlCheckParameters =============================================
   * Abstract:
   *    Validate S-function dialog parameter values.
   */
static void mdlCheckParameters(SimStruct *S)
{
    RunTimeDataType   *mass;

    /* Restrict the volume and density values to be scalar doubles */
    
    if (!mxIsDouble(VOL_PARAM(S)) ||
    (mxGetNumberOfElements(VOL_PARAM(S)) != 1)) {
        ssSetErrorStatus(S,"Volume must be entered as a scalar double.");
        return;
    }
    
    if (!mxIsDouble(DEN_PARAM(S)) ||
    (mxGetNumberOfElements(DEN_PARAM(S)) != 1)) {
        ssSetErrorStatus(S,"Density must be entered as a scalar double.");
        return;
    }
}
#endif /* MDL_CHECK_PARAMETERS */
    
/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    Call mdlCheckParameters to verify that the parameters are OK,
 *    then setup sizes of the various vectors.
 */
static void mdlInitializeSizes(SimStruct *S)
{
    /* See sfuntmpl.doc for more details on the macros below */
    
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
    
    ssSetSFcnParamTunable(S,VOL_IDX,true);
    ssSetSFcnParamTunable(S,DEN_IDX,true);
    
    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);
    
    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortOverWritable(S, 0, 1);
    ssSetInputPortOptimOpts(S, 0, SS_REUSABLE_AND_LOCAL);
    
    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortWidth(S, 0, 1);
    ssSetOutputPortOptimOpts(S, 0, SS_REUSABLE_AND_LOCAL);
    
    
    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);
    
    /* specify the sim state compliance to be same as a built-in block */
    ssSetSimStateCompliance(S, USE_DEFAULT_SIM_STATE);

    /* Take care when specifying exception free code - see sfuntmpl.doc */
    ssSetOptions(S,
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
/* Function: mdlSetWorkWidths =============================================
 * Abstract:
 *      Set up run-time parameter for mass as a function of volume and
 *      dnesity.
 */
static void mdlSetWorkWidths(SimStruct *S)
{
    ssParamRec p; /* Initialize an ssParamRec structure */
    int        dlg[2];
    real_T vol = *mxGetPr(VOL_PARAM(S));
    real_T den = *mxGetPr(DEN_PARAM(S));
    RunTimeDataType   *mass;
    
    /* Initialize dimensions for the run-time paramete as a
     * local variable. Simulink makes a copy of this information
     * to store in the run-time parameter */
    int_T  massDims[2] = {1,1};
    
    /* Allocate memory for the run-time parameter data. The S-function
     * owns this memory location. Simulink does not copy the data. */
    if ((mass=(RunTimeDataType*)malloc(sizeof(RunTimeDataType))) == NULL) {
        ssSetErrorStatus(S,"Memory allocation error");
        return;
    }

    /* Store the pointer to the memory location in the S-function 
     * userdata. Since the S-function owns this data, it needs to
     * free the memory during mdlTerminate */
    ssSetUserData(S, (void*)mass);
    
    /* Call local function to initialize the run-time 
     * parameter data. Simulink checks that the data is not empty
     * so the initial value must be stored. */
    calcMass(mass, vol, den);

    /* Specify mass is a function of both S-function dialog parameters */
    dlg[0] = VOL_IDX;
    dlg[1] = DEN_IDX;
    
    /* Configure run-time parameter information */
    p.name             = "Mass";
    p.nDimensions      = 2;
    p.dimensions       = massDims;
    p.dataTypeId       = RUN_TIME_DATA_TYPE;
    p.complexSignal    = COMPLEX_NO;
    p.data             = mass;
    p.dataAttributes   = NULL;
    p.nDlgParamIndices = 2;
    p.dlgParamIndices  = dlg;
    p.transformed      = RTPARAM_TRANSFORMED;
    p.outputAsMatrix   = false;
    
    /* Set number of run-time parameters  */
    if (!ssSetNumRunTimeParams(S, 1)) return;
    /* Set run-time parameter information */
    if (!ssSetRunTimeParamInfo(S,0,&p)) return;
            
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
    /* Update Run-Time parameters */
    real_T            vol = *mxGetPr(VOL_PARAM(S));
    real_T            den = *mxGetPr(DEN_PARAM(S));
    RunTimeDataType *mass = (RunTimeDataType *)((ssGetRunTimeParamInfo(S,0))->data);
    calcMass(mass, vol, den);

    ssUpdateRunTimeParamData(S, 0, mass);
}
#endif /* MDL_PROCESS_PARAMETERS */


/* Function: mdlOutputs =======================================================
 * Abstract:
 *
 *   Output acceleration calculated as input force divided by mass.   
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    real_T *y1              = ssGetOutputPortRealSignal(S,0);
    InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S,0);
    RunTimeDataType *mass   = (RunTimeDataType *)((ssGetRunTimeParamInfo(S,0))->data);
  
     /*
     * Output acceleration = force / mass
     */
    
    y1[0] = (*uPtrs[0]) / *mass;
    
}

/* Function: mdlTerminate =====================================================
 * Abstract:
 *      Free the user data.
 */
static void mdlTerminate(SimStruct *S)
{
    /* Free memory used to store the run-time parameter data*/      
   RunTimeDataType *mass = ssGetUserData(S);
    if (mass != NULL) {
        free(mass);
    } 
}

#if defined(MATLAB_MEX_FILE)
#define MDL_RTW
/* Function: mdlRTW ===========================================================
 * Abstract:
 *      Since Mass is registered as a run-time parameter,
 *      it does not need to be writte to the .rtw file.
 */
static void mdlRTW(SimStruct *S)
{
  
}
#endif /* MDL_RTW */


/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
