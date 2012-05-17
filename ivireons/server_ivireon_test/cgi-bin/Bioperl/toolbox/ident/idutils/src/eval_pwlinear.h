/* ------------------------------------------------------------------------
 *  Program   :     eval_pwlinear.h
 *  Author    :     Rajiv Singh
 *
 *  Copyright 2007 The MathWorks, Inc.
 *  $Revision: 1.1.8.1 $    $Date: 2007/11/09 20:17:41 $
 *
 *  Purpose   :     Function declarations and type definitions for
 *                  Pwlinear nonlinearity.
 *	To compile: 
 *  mex -g sfunpwlinear.c eval_pwlinear.c etc 
 * -----------------------------------------------------------------------*/

#ifndef __EVAL_PWLINEAR_H__
#define __EVAL_PWLINEAR_H__

/* Structure to store Pwlinear parameters (Parameters.internalParameters 
 * and NumberOfUnits) information 
 */
typedef struct ParStruc_tag {
  uint_T    NumberOfUnits;      /* pwlinear.NumberOfUnits */
  real_T    *LinearCoef;        /* internalParameter.LinearCoef */  
  real_T    OutputOffset;       /* internalParameter.OutputOffset */
  real_T    *OutputCoef;        /* internalParameter.OutputCoef */
  real_T    *Translation;       /* internalParameter.Translation */
  uint_T    DimXlin;            /* size(internalParameter.LinearCoef,1) */
} ParStruc;


/* Parameter Names and Order */
/* This order corresponds to the order of input arguments to S-function: sfunpwlinear */
enum { 
       NumUnits_Idx = 2,        
       Par_LinearCoef_Idx,      Par_OutputOffset_Idx,    
       Par_OutputCoef_Idx,      Par_Translation_Ix,      
       NUM_PARAMS 
    };

/* PWLINEAR parameters */
#define NUMUNITS(S)         ssGetSFcnParam(S, NumUnits_Idx)
#define PAR_LINEARCOEF(S)   ssGetSFcnParam(S, Par_LinearCoef_Idx)
#define PAR_OUTPUTOFFSET(S) ssGetSFcnParam(S, Par_OutputOffset_Idx)
#define PAR_OUTPUTCOEF(S)   ssGetSFcnParam(S, Par_OutputCoef_Idx)
#define PAR_TRANSLATION(S)  ssGetSFcnParam(S, Par_Translation_Ix)


/* Function declarations */
/* Note: NumRows = 1 when called from S function */
#ifdef __cplusplus
extern "C" {
#endif
void evaluate_pwlinear
(
    real_T *Output, 
    const real_T *Regressors, 
    uint_T NumRows, 
    ParStruc *Pars
);
#ifdef __cplusplus
}
#endif

/* Error & Warning messages */
static char *wrongNumParams = "Incorrect number of parameters specified. "
"Need to supply 7: Ts, NumReg, NumUnits, "
"LinearCoef, OutputOffset, OutputCoef, Translation";

static char *wrongDimInp = "Regressor must have dimension =  1 (scalar).";

#endif /* __EVAL_PWLINEAR_H__ */
