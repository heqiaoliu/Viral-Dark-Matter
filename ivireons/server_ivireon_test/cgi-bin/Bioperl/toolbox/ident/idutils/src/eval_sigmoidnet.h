/* ------------------------------------------------------------------------
 *  Program   :     eval_sigmoidnet.h
 *  Author    :     Rajiv Singh
 *
 *  Copyright 2007 The MathWorks, Inc.
 *  $Revision: 1.1.8.1 $    $Date: 2007/11/09 20:17:45 $
 *
 *  Purpose   :     Function declarations and type definitions for
 *                  Sigmoidnet nonlinearity.
 *	To compile: 
 *  mex -g sfunsigmoidnet.c eval_sigmoidnet.c etc 
 * -----------------------------------------------------------------------*/

#ifndef __EVAL_SIGMOIDNET_H__
#define __EVAL_SIGMOIDNET_H__

/* Structure to store Sigmoidnet parameters information */
typedef struct ParStruc_tag {
  uint_T    NumberOfUnits;          /* sigmoidnet.NumberOfUnits */
  real_T    *RegressorMean;         /* Parameters.RegressorMean */
  real_T    *NonLinearSubspace;     /* Parameters.NonLinearSubspace */
  real_T    *LinearSubspace;        /* Parameters.LinearSubspace */
  real_T    *LinearCoef;            /* Parameters.LinearCoef */  
  real_T    *Dilation;              /* Parameters.Dilation */
  real_T    *Translation;           /* Parameters.Translation */
  real_T    *OutputCoef;           /* Parameters.OutputCoef */
  real_T    OutputOffset;           /* Parameters.OutputOffset */
  real_T    *Xnl;                   /* Preallocated variable for nonlinear subspace */
  uint_T    DimXlin;                /* size(Parameters.LinearSubspace,2) */
  uint_T    DimXnl;                 /* size(Parameters.NonlinearSubspace,2) */
} ParStruc;


/* Parameter Names and Order */
/* This order corresponds to the order of input arguments to S-function: sfunsigmoidnet */
enum { 
       NumUnits_Idx = 2,            Par_RegressorMean_Idx,  
       Par_NonLinearSubspace_Idx,   Par_LinearSubspace_Idx,
       Par_LinearCoef_Idx,          Par_Dilation_Idx,     
       Par_Translation_Ix,          Par_OutputCoef_Idx,
       Par_OutputOffset_Idx,        NUM_PARAMS 
    };

/* Linear parameters */
#define NUMUNITS(S) ssGetSFcnParam(S, NumUnits_Idx)
#define PAR_REGRESSORMEAN(S) ssGetSFcnParam(S, Par_RegressorMean_Idx)
#define PAR_NONLINEARSUBSPACE(S) ssGetSFcnParam(S, Par_NonLinearSubspace_Idx)
#define PAR_LINEARSUBSPACE(S) ssGetSFcnParam(S, Par_LinearSubspace_Idx)
#define PAR_LINEARCOEF(S) ssGetSFcnParam(S, Par_LinearCoef_Idx)
#define PAR_DILATION(S) ssGetSFcnParam(S, Par_Dilation_Idx)
#define PAR_TRANSLATION(S) ssGetSFcnParam(S, Par_Translation_Ix)
#define PAR_OUTPUTCOEF(S) ssGetSFcnParam(S, Par_OutputCoef_Idx)
#define PAR_OUTPUTOFFSET(S) ssGetSFcnParam(S, Par_OutputOffset_Idx)

/* Function declarations */
/* Note: NumRows = 1 when called from S function*/
#ifdef __cplusplus
extern "C" {
#endif
void evaluate_sigmoidnet
(
    real_T *Output, 
    const real_T *Regressors, 
    uint_T NumRows, 
    uint_T DimInp, 
    ParStruc *Pars
);
#ifdef __cplusplus
}
#endif

/* Error & Warning messages */
static char *wrongNumParams = "Incorrect number of parameters specified. "
"Need to supply 11: Ts, NumReg, NumUnits, "
"RegressorMean, NonLinearSubspace, LinearSubspace, LinearCoef, "
"Dilation, Translation, OutputCoef, OutputOffset, ";

#endif /* __EVAL_SIGMOIDNET_H__ */
