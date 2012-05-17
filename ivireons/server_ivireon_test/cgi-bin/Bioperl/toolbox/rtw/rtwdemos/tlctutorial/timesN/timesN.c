/*
 * File : timesN.c
 * Abstract:
 *       An example C-file S-function for multiplying an input by N,
 *                         y  = N*u
 *       N is passed into the S-function as a parameter called myGain.
 *
 * Real-Time Workshop note:
 *   This file can NOT be used as noninlined S-function with the 
 *   Real-Time Workshop since it uses mdlRTW(). It must be used together
 *   with a tlc file with the same name. See timesN.tlc for the C TLC 
 *   code to inline this S-function.
 *
 * See simulink/src/sfuntmpl_doc.c 
 *
 * Copyright 2006-2007 The MathWorks, Inc.
 * $Revision: 1.1.10.1 $
 */


#define S_FUNCTION_NAME  timesN
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

/*================*
 * Build checking *
 *================*/


/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *   Setup sizes of the various vectors.
 */
static void mdlInitializeSizes(SimStruct *S)
{
	ssSetNumSFcnParams(S, 1);
	ssSetSFcnParamTunable(S, 0, 0);
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
	SS_OPTION_WORKS_WITH_CODE_REUSE |
	SS_OPTION_EXCEPTION_FREE_CODE |
	SS_OPTION_USE_TLC_WITH_ACCELERATOR);
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
 *    y = N*u
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
	int_T             i;
	real_T            *Npr;
	InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S,0);
	real_T            *y    = ssGetOutputPortRealSignal(S,0);
	int_T             width = ssGetOutputPortWidth(S,0);
	
	Npr = mxGetPr(ssGetSFcnParam(S,0));
	if(Npr == NULL)	{
		ssSetErrorStatus(S, "S-function parameter cannot be evaluated");
	}
	else {
		for (i=0; i<width; i++) {
		/*
		 * This example does not implement complex signal handling.
		 * To find out see an example about how to handle complex signal in
		 * S-function, see sdotproduct.c for details.
		 */
			*y++ = (*Npr) *(*uPtrs[i]);
		}
	}
}

/* Function: mdlTerminate =====================================================
 * Abstract:
 *    No termination needed, but we are required to have this routine.
 */
static void mdlTerminate(SimStruct *S)
{
}

#if defined(MATLAB_MEX_FILE)
#define MDL_RTW
/* Function: mdlRTW =========================================================
 * Abstract:
 *    Writes S-function parameter setting in <model>.rtw
 */
static void mdlRTW(SimStruct *S)
{
	real_T myGainVal = mxGetPr(ssGetSFcnParam(S,0))[0];
	if (!ssWriteRTWParamSettings(S, 1, 
								SSWRITE_VALUE_NUM, "myGain", myGainVal)) {
		return;
	}
}

#endif /* mdlRTW */

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
