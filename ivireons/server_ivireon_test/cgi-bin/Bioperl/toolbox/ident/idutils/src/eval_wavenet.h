/* ------------------------------------------------------------------------
 *  Program   :     eval_wavenet.h
 *  Author    :     Rajiv Singh
 *
 *  Copyright 2007 The MathWorks, Inc.
 *  $Revision: 1.1.8.1 $    $Date: 2007/11/09 20:17:49 $
 *
 *  Purpose   :     Function declarations and type definitions for
 *                  Wavenet nonlinearity.
 *	To compile: 
 *  mex -g sfunwavenet.c eval_wavenet.c
 * -----------------------------------------------------------------------*/

#ifndef __EVAL_WAVENET_H__
#define __EVAL_WAVENET_H__

/* Structure to store Wavenet parameters information */
typedef struct ParStruc_tag {
  uint_T    NumberOfUnits;          /* wavenet.NumberOfUnits */
  real_T    *RegressorMean;         /* Parameters.RegressorMean */
  real_T    *NonLinearSubspace;     /* Parameters.NonLinearSubspace */
  real_T    *LinearSubspace;        /* Parameters.LinearSubspace */
  real_T    OutputOffset;           /* Parameters.OutputOffset */
  real_T    *LinearCoef;            /* Parameters.LinearCoef */
  real_T    *ScalingCoef;           /* Parameters.ScalingCoef */
  real_T    *WaveletCoef;           /* Parameters.WaveletCoef */
  real_T    *ScalingDilation;       /* Parameters.ScalingDilation */
  real_T    *WaveletDilation;       /* Parameters.WaveletDilation */
  real_T    *ScalingTranslation;    /* Parameters.ScalingTranslation */
  real_T    *WaveletTranslation;    /* Parameters.WaveletTranslation */
  real_T    *Xnl;                   /* Preallocated variable for nonlinear subspace */
  uint_T    NumWavelet;             /* size(Parameters.WaveletTranslation,1) */
  uint_T    NumScale;               /* size(Parameters.ScalingTranslation,1) */
  uint_T    DimXlin;                /* size(Parameters.LinearSubspace,2) */
  uint_T    DimXnl;                 /* size(Parameters.NonlinearSubspace,2) */
} ParStruc;


/* Parameter Names and Order */
/* This order corresponds to the order of input arguments to S-function: sfunwavenet */
enum { 
       NumUnits_Idx = 2,            Par_RegressorMean_Idx,  
       Par_NonLinearSubspace_Idx,   Par_LinearSubspace_Idx,
       Par_OutputOffset_Idx,        Par_LinearCoef_Idx,
       Par_ScalingCoef_Idx,         Par_WaveletCoef_Idx,
       Par_ScalingDilation_Idx,     Par_WaveletDilation_Idx,
       Par_ScalingTranslation_Ix,   Par_WaveletTranslation_Idx,
       NUM_PARAMS 
    };

/* Linear parameters */
#define NUMUNITS(S) ssGetSFcnParam(S, NumUnits_Idx)
#define PAR_REGRESSORMEAN(S) ssGetSFcnParam(S, Par_RegressorMean_Idx)
#define PAR_NONLINEARSUBSPACE(S) ssGetSFcnParam(S, Par_NonLinearSubspace_Idx)
#define PAR_LINEARSUBSPACE(S) ssGetSFcnParam(S, Par_LinearSubspace_Idx)
#define PAR_OUTPUTOFFSET(S) ssGetSFcnParam(S, Par_OutputOffset_Idx)
#define PAR_LINEARCOEF(S) ssGetSFcnParam(S, Par_LinearCoef_Idx)
#define PAR_SCALINGCOEF(S) ssGetSFcnParam(S, Par_ScalingCoef_Idx)
#define PAR_WAVELETCOEF(S) ssGetSFcnParam(S, Par_WaveletCoef_Idx)
#define PAR_SCALINGDILATION(S) ssGetSFcnParam(S, Par_ScalingDilation_Idx)
#define PAR_WAVELETDILATION(S) ssGetSFcnParam(S, Par_WaveletDilation_Idx)
#define PAR_SCALINGTRANSLATION(S) ssGetSFcnParam(S, Par_ScalingTranslation_Ix)
#define PAR_WAVELETTRANSLATION(S) ssGetSFcnParam(S, Par_WaveletTranslation_Idx)

/* Function declarations */
/* Note: NumRows = 1 when called from S function*/
#ifdef __cplusplus
extern "C" {
#endif
void evaluate_wavenet
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
"Need to supply 14: Ts, NumReg, NumUnits, "
"RegressorMean, NonLinearSubspace, LinearSubspace, OutputOffset, LinearCoef, "
"ScalingCoef, WaveletCoef, ScalingDilation, WaveletDilation, ScalingTranslation, "
"WaveletTranslation";

#endif /* __EVAL_WAVENET_H__ */
