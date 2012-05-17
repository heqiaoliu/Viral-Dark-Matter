/* ------------------------------------------------------------------------
 *  Program   :     eval_satdead.h
 *  Author    :     Rajiv Singh
 *
 *  Copyright 2007 The MathWorks, Inc.
 *  $Revision: 1.1.8.2 $    $Date: 2007/12/14 14:46:38 $
 *
 *  Purpose   :     Function declarations and type definitions for
 *                  Saturation and Dead Zone nonlinearities.
 *	To compile: 
 *  mex -g sfunsatdead.c eval_satdead.c  
 * -----------------------------------------------------------------------*/

#ifndef __EVAL_SATDEAD_H__
#define __EVAL_SATDEAD_H__

/* Structure to store saturation/deazone parameters (Parameters.prvParameters) */
typedef struct ParStruc_tag {
  real_T    *Interval;    /* prvParameters.Interval */  
  real_T    Center;       /* internalParameter.OutputOffset */
  real_T    Scale;        /* internalParameter.OutputCoef */
  uint_T    IsSaturation; /* 1 if block represents saturation and 0 if deadzone */
  uint_T    NumInterval;  /* numel(prvParameters.Interval) */
} ParStruc;


/* Parameter Names and Order */
/* This order corresponds to the order of input arguments to S-function: sfunsatdead.c */
enum { Ts_Idx,
       Par_Interval_Idx,        Par_Center_Idx,          
       Par_Scale_Idx,           IsSaturation_Idx,
       NUM_PARAMS
    };

/* SATURATION/DEADZONE parameters */
#define TS(S)           ssGetSFcnParam(S, Ts_Idx)
#define PAR_INTERVAL(S) ssGetSFcnParam(S, Par_Interval_Idx)
#define PAR_CENTER(S)   ssGetSFcnParam(S, Par_Center_Idx)
#define PAR_SCALE(S)    ssGetSFcnParam(S, Par_Scale_Idx)
#define ISSATURATION(S) ssGetSFcnParam(S, IsSaturation_Idx)

#ifndef MAX
#define MAX(a,b) (((a-b)>=0)?a:b)
#endif

#ifndef MIN
#define MIN(a,b) (((a-b)<=0)?a:b)
#endif

/* Function declarations */
/* Note: NumRows = 1 when called from S function*/
#ifdef __cplusplus
extern "C" {
#endif
void evaluate_satdead
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
"Need to supply 5: Ts,  Interval, Center, Scale, IsSaturation"; 

static char *wrongDimInp = "Regressor must have dimension =  1 (scalar).";

#endif /* __EVAL_SATDEAD_H__ */
