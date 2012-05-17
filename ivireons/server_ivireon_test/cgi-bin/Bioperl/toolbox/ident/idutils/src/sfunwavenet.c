/*  File    : sfunwavenet.c
 *  Abstract:
 *  Evaluate wavenet nonlinearity.
 * 
 *  Written by: Rajiv Singh
 *  Copyright 2007 The MathWorks, Inc.
 *  $Revision: 1.1.8.3 $ $Date: 2008/12/04 22:34:28 $
 */

#define S_FUNCTION_NAME sfunwavenet
#define S_FUNCTION_LEVEL 2

#include "idsfuncommon.h"
#include "eval_wavenet.h"


/*====================*
 * S-function methods *
 *====================*/

/* ----------------------------------------------------------------------------
 * Purpose:  Make sure parameter values are valid for the current context.
 * ------------------------------------------------------------------------- */
#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
static void mdlCheckParameters(SimStruct *S)
{
   UNUSED_ARG(S); 
}
#endif /* MDL_CHECK_PARAMETERS */

/* ----------------------------------------------------------------------------
 * Purpose:  Store tunable parameters in a pre-digested state.
 * ------------------------------------------------------------------------- */
#define MDL_PROCESS_PARAMETERS
static void mdlProcessParameters(SimStruct *S)
{
	/* to do: verify parameters */
	UNUSED_ARG(S); 
}

/* ----------------------------------------------------------------------------
 * Purpose:  Allocate work data and initialize non-tunable items.
 * ------------------------------------------------------------------------- */
#define MDL_START
static void mdlStart(SimStruct *S)
{
    ParStruc    *Par    = malloc(sizeof *Par); /* Wavenet's parameters */
    #if defined(MATLAB_MEX_FILE)
    int_T       *Ir     = ssGetJacobianIr(S);
    int_T       *Jc     = ssGetJacobianJc(S);
    int_T       k;
    #endif
    
    uint_T      DimInp  = (uint_T) mxGetScalar(NUMREG(S));
    
   if (Par == NULL){
       free(Par);
       ssSetErrorStatus(S, "Could not allocate data cache memory.");
       return;
   }
    
	/* Populate Parameters */
    Par->NumberOfUnits      =   (uint_T) mxGetScalar(NUMUNITS(S));
    Par->RegressorMean      =   mxGetData(PAR_REGRESSORMEAN(S));
    Par->NonLinearSubspace  =   mxGetData(PAR_NONLINEARSUBSPACE(S));
    Par->LinearSubspace     =   mxGetData(PAR_LINEARSUBSPACE(S));
    Par->OutputOffset       =   mxGetScalar(PAR_OUTPUTOFFSET(S));
    Par->LinearCoef         =   mxGetData(PAR_LINEARCOEF(S));
    Par->ScalingCoef        =   mxGetData(PAR_SCALINGCOEF(S));
    Par->WaveletCoef        =   mxGetData(PAR_WAVELETCOEF(S));
    Par->ScalingDilation    =   mxGetData(PAR_SCALINGDILATION(S));
    Par->WaveletDilation    =   mxGetData(PAR_WAVELETDILATION(S));
    Par->ScalingTranslation =   mxGetData(PAR_SCALINGTRANSLATION(S));
    Par->WaveletTranslation =   mxGetData(PAR_WAVELETTRANSLATION(S));
    /* dimensions */
    Par->NumScale           =   (uint_T) mxGetM(PAR_SCALINGCOEF(S));
    Par->NumWavelet         =   (uint_T) mxGetM(PAR_WAVELETCOEF(S));
    Par->DimXlin            =   (uint_T) mxGetN(PAR_LINEARSUBSPACE(S));
    Par->DimXnl             =   (uint_T) mxGetN(PAR_NONLINEARSUBSPACE(S));
    
    Par->Xnl    = (real_T *) malloc(Par->DimXnl*sizeof(real_T)); /* NumRows = 1 */
    
    if (Par->Xnl == NULL) {
        free(Par);
        ssSetErrorStatus(S, "Could not allocate data cache memory.");
        return;
    } /* Error checking complete */
    
    /* Set the cached data into the user data area for 'this' block. */
    ssSetUserData(S, Par);
  
    /* Finish the initialization */
    mdlProcessParameters(S);
    
    #if defined(MATLAB_MEX_FILE)
    /* Jacobian (dy/dR, R:=regressors) set up */
    /* If linearization is disabled, we'll have no storage */
    if ((Ir == NULL) || (Jc == NULL)) return;
    for (k = 0; k < DimInp; k++) {
        Ir[k] = 0;
        Jc[k] = k;
    }
    #endif
}

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NUM_PARAMS);  /* Number of expected parameters */
	#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
		mdlCheckParameters(S);
		if (ssGetErrorStatus(S) != NULL) return;
	} else{
		return; /* Simulink will report a parameter mismatch error */
    }
    #endif

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0); 
    ssSetSimStateCompliance(S, USE_DEFAULT_SIM_STATE);
    
    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(S, 0, mxGetScalar(NUMREG(S))); 
    ssSetInputPortDirectFeedThrough(S, 0, 1); /* this is s static fcn: y = f(u) */
    ssSetInputPortRequiredContiguous(S, 0, 1);
    
    /* there is only one scalar output */
    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortWidth(S, 0, 1);

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);
    
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
    
    /* Preemptively clear user data pointer so we don't try to free it */
    ssSetUserData(S, NULL);
}

#define MDL_SET_WORK_WIDTHS
/* Function: mdlSetWorkWidths ================================================
 * Abstract: PostPropagation tasks
 */
static void mdlSetWorkWidths(SimStruct *S)
{
    /* Set the number of nonzero elements in the Jacobian */
    /* We have a static function whose linearization would result in a 
     * full D matrix of size 1-by-nu, where nu is number of inputs
     */     
    #if defined(MATLAB_MEX_FILE)
    ssSetJacobianNzMax(S, mxGetScalar(NUMREG(S)));
    #endif
}

/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Specify the sample time 
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    const double Ts = mxGetScalar(TS(S)); 
    ssSetSampleTime(S, 0, Ts);
    ssSetOffsetTime(S, 0, 0.0);

    /* todo: Is this required?
    ssSetModelReferenceSampleTimeDefaultInheritance(S);      
    */
}

#define MDL_INITIALIZE_CONDITIONS
/* Function: mdlInitializeConditions ========================================
 * Abstract:
 *    Initialize states
 */
static void mdlInitializeConditions(SimStruct *S)
{
    UNUSED_ARG(S);
}

/* Function: mdlOutputs =======================================================
 * Abstract:
 *      y = f(X,U), where f(.) is the static mapping defined in eval_treepartition
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
   real_T   *y          = ssGetOutputPortRealSignal(S,0);
   ParStruc *Par        = ssGetUserData(S);
   const real_T   *Reg;
   uint_T   DimInp      = (uint_T) mxGetScalar(NUMREG(S));
   
   UNUSED_ARG(tid); /* not used in single tasking mode */
   
   /* Execute the nonlinearity mapping function*/
   Reg = ssGetInputPortRealSignal(S,0); /* input signals are contiguous */    
   evaluate_wavenet(y, Reg, 1, DimInp, Par);
}

#define MDL_JACOBIAN
/* Function: mdlJacobian ======================================================
 * Abstract: populate the model's Jacobian data.
 * See the on-line documentation for mxCreateSparse for
 * information regarding the format of Ir, Jc, and Pr data.
 *
 *        [ A | B ]    
 *  J =   [ --+-- ]  (= D here)
 *        [ C | D ]  
 *                 
 */
static void mdlJacobian(SimStruct *S)
{
    #if defined(MATLAB_MEX_FILE)
    real_T      *Pr     = ssGetJacobianPr(S);
	real_T		*out;
	real_T		*temp;
    uint_T      nr      = (uint_T) mxGetScalar(NUMREG(S));
    ParStruc    *Par    = ssGetUserData(S);
    const real_T *Reg   = ssGetInputPortRealSignal(S,0); /* input signals are contiguous */
    int_T		k;
    mxArray *plhs;
    mxArray *prhs[3];
    mxArray *ParStruct;
    mxArray *TypeStr;
    const char **fnamesPar;
    
    /* plhs            = mxCreateDoubleMatrix(1,nr,mxREAL); */
    TypeStr         = mxCreateString("wavenet");
    fnamesPar       = mxCalloc(12, sizeof(*fnamesPar));
       
     /* memory error check */
    if ( (fnamesPar==NULL) || (TypeStr==NULL) || (prhs==NULL)){
        ssSetErrorStatus(S, "Could not allocate memory for Jacobian computation.");
        return;
    }
    
    /* Parameter struct field names */
    fnamesPar[0]  = "NumberOfUnits";
    fnamesPar[1]  = "RegressorMean";
    fnamesPar[2]  = "NonLinearSubspace";
    fnamesPar[3]  = "LinearSubspace";
    fnamesPar[4]  = "OutputOffset";
    fnamesPar[5]  = "LinearCoef";
    fnamesPar[6]  = "ScalingCoef";
    fnamesPar[7]  = "WaveletCoef";
    fnamesPar[8]  = "ScalingDilation";
    fnamesPar[9]  = "WaveletDilation";
    fnamesPar[10] = "ScalingTranslation";
    fnamesPar[11] = "WaveletTranslation";
    
    ParStruct     = mxCreateStructMatrix(1,1,12,fnamesPar);
    
    /* do memory error check */
    if (ParStruct==NULL) {
        ssSetErrorStatus(S, "Could not allocate memory for Jacobian computation.");
        return;
    }
    
    /* set fields of Paramater struct */
    mxSetFieldByNumber(ParStruct, 0, 0,  mxDuplicateArray(NUMUNITS(S)));
    mxSetFieldByNumber(ParStruct, 0, 1,  mxDuplicateArray(PAR_REGRESSORMEAN(S)));
    mxSetFieldByNumber(ParStruct, 0, 2,  mxDuplicateArray(PAR_NONLINEARSUBSPACE(S)));
    mxSetFieldByNumber(ParStruct, 0, 3,  mxDuplicateArray(PAR_LINEARSUBSPACE(S)));
    mxSetFieldByNumber(ParStruct, 0, 4,  mxDuplicateArray(PAR_OUTPUTOFFSET(S)));
    mxSetFieldByNumber(ParStruct, 0, 5,  mxDuplicateArray(PAR_LINEARCOEF(S)));
    mxSetFieldByNumber(ParStruct, 0, 6,  mxDuplicateArray(PAR_SCALINGCOEF(S)));
    mxSetFieldByNumber(ParStruct, 0, 7,  mxDuplicateArray(PAR_WAVELETCOEF(S)));
    mxSetFieldByNumber(ParStruct, 0, 8,  mxDuplicateArray(PAR_SCALINGDILATION(S)));
    mxSetFieldByNumber(ParStruct, 0, 9,  mxDuplicateArray(PAR_WAVELETDILATION(S)));
    mxSetFieldByNumber(ParStruct, 0, 10, mxDuplicateArray(PAR_SCALINGTRANSLATION(S)));
    mxSetFieldByNumber(ParStruct, 0, 11, mxDuplicateArray(PAR_WAVELETTRANSLATION(S)));
   
	prhs[0] = mxCreateDoubleMatrix(1,nr,mxREAL);
    temp = mxGetPr(prhs[0]);
	for (k=0; k<nr; k++){
		temp[k] = Reg[k];
	}
    
    prhs[1] = ParStruct;
    prhs[2] = TypeStr;
    
    /* 
     * Call utEvalStateJacobian to compute the regressors 
     * M file: dydx = utEvalStateJacobian(x,par,type) 
     */
    mexCallMATLAB(1,&plhs,3,prhs,"utEvalStateJacobian");

    out = mxGetPr(plhs);
	for(k=0; k<nr; k++){
		Pr[k] = out[k];
        /* ssPrintf("->Pr[%i] = %g\n",k,Pr[k]); */
	}
    
    mxFree((void *)fnamesPar);
    mxDestroyArray(plhs);
    
	mxDestroyArray(prhs[0]);
	mxDestroyArray(TypeStr);
	mxDestroyArray(ParStruct);
    #endif
    
}


/* Function: mdlTerminate =====================================================
 * Abstract:
 *    No termination needed, but we are required to have this routine.
 */
static void mdlTerminate(SimStruct *S)
{
    ParStruc *Par = ssGetUserData(S);
    if(Par != NULL){        
        free(Par->Xnl);
        free(Par);
    }
    
    ssSetUserData(S, NULL);
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
