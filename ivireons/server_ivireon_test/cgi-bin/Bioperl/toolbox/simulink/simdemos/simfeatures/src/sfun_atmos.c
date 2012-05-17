/*
 *     File: sfun_atmos.c
 *
 * Abstract:
 *
 *   Example of a Level 2 CMEX S-function gateway to 
 *   a Fortran subroutine.  This technique allows you 
 *   to combine the features of level 2 S-functions with 
 *   Fortran code, either new or existing.
 *
 *   This example was prepared to be platform neutral.
 *   However, There are portability issues with Fortran
 *   compiler symbol decoration and capitalization (see
 *   prototype section, below).
 *
 *   On Windows, one can compile this example using:
 *
 *   >> mex -c sfun_atmos_sub.F -f f90opts.bat
 *   >> f90opts.bat & mex -v sfun_atmos.c sfun_atmos_sub.obj
 * 
 *   On UNIX one can compile this example using 
 *
 *   >> mex sfun_atmos.c sfun_atmos_sub.F
 * 
 *   GNU Fortran (g77) can be obtained for free from many 
 *   download sites, including http://www.redhat.com in 
 *   the download area.  Keyword on search engines is 'g77'.
 *
 *   R. Aberg, 01 JUL 2000
 *   Copyright 1990-2009 The MathWorks, Inc.
 *
 *   $Revision: 1.1.6.1 $
 */

#define S_FUNCTION_NAME  sfun_atmos
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

/* 
 * Below is the function prototype of Fortran 
 * subroutine 'Atmos' in file sfun_atmos_sub.f. 
 *
 * Note that datatype REAL is 32 bits in Fortran,
 * so the prototype arguments must be float.
 *
 * Your Fortran compiler may decorate and/or change
 * the capitalization of 'SUBROUTINE Atmosphere'
 * differently than the prototype below.  Check 
 * your Fortran compiler's manual for options to 
 * learn about and possibly control external symbol
 * decoration.
 *
 * Additionally, you may want to use CFortran,
 * a tool for automating interface generation 
 * between C and Fortran ... in either direction. 
 * Search the web for 'cfortran'.
 */

/* 
 * Windows uses upper case for Fortran external symbols 
 */
#ifdef _WIN32
#define atmos_ ATMOS
#endif

extern void atmos_(float *alt, 
                  float *sigma, 
                  float *delta, 
                  float *theta);


/* Parameters for this block */

typedef enum {T0_IDX=0, P0_IDX, R0_IDX, NUM_SPARAMS } paramIndices;

#define T0(S) (ssGetSFcnParam(S, T0_IDX))
#define P0(S) (ssGetSFcnParam(S, P0_IDX))
#define R0(S) (ssGetSFcnParam(S, R0_IDX))


/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *   Set up sizes of the S-function's inputs and outputs.
 */

static void mdlInitializeSizes(SimStruct *S)
{
  ssSetNumSFcnParams(S,NUM_SPARAMS);   /* expected number */
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) goto EXIT_POINT;
#endif

    {
        int iParam = 0;
        int nParam = ssGetNumSFcnParams(S);

        for ( iParam = 0; iParam < nParam; iParam++ )
        {
            ssSetSFcnParamTunable( S, iParam, SS_PRM_SIM_ONLY_TUNABLE );
        }
    }

  ssSetNumContStates( S, 0 );
  ssSetNumDiscStates( S, 0 );

  ssSetNumInputPorts(S, 1);
  ssSetInputPortWidth(S, 0, DYNAMICALLY_SIZED);
  ssSetInputPortDirectFeedThrough(S, 0, 1);
  ssSetInputPortRequiredContiguous(S, 0, 1);

  ssSetNumOutputPorts(S, 3);
  ssSetOutputPortWidth(S, 0, DYNAMICALLY_SIZED); /* temperature */
  ssSetOutputPortWidth(S, 1, DYNAMICALLY_SIZED); /* pressure    */
  ssSetOutputPortWidth(S, 2, DYNAMICALLY_SIZED); /* density     */

  /* specify the sim state compliance to be same as a built-in block */
  ssSetSimStateCompliance(S, USE_DEFAULT_SIM_STATE);

EXIT_POINT:
    return;
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
 *    Calculate atmospheric conditions using Fortran subroutine.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
  double *alt = (double *) ssGetInputPortSignal(S,0);
  double *T   = (double *) ssGetOutputPortRealSignal(S,0);
  double *P   = (double *) ssGetOutputPortRealSignal(S,1);
  double *rho = (double *) ssGetOutputPortRealSignal(S,2);
  int     w   = ssGetInputPortWidth(S,0);
  int     k;
  float   falt, fsigma, fdelta, ftheta;

  for (k=0; k<w; k++) {

    /* set the input value */
    falt   = (float) alt[k];

    /* call the Fortran routine using pass-by-reference */
    atmos_(&falt, &fsigma, &fdelta, &ftheta);

    /* format the outputs using the reference parameters */
    T[k]   = mxGetScalar(T0(S)) * (double) ftheta;
    P[k]   = mxGetScalar(P0(S)) * (double) fdelta;
    rho[k] = mxGetScalar(R0(S)) * (double) fsigma;
  }
}


/* Function: mdlTerminate =====================================================
 * Abstract:
 *    This method is required for Level 2 S-functions.
 */
static void mdlTerminate(SimStruct *S)
{ 
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif


