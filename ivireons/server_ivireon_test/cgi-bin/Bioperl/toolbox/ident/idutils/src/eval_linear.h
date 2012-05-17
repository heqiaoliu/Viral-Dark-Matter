/* ------------------------------------------------------------------------
 *  Program   :     eval_linear.h
 *  Author    :     Rajiv Singh
 *
 *  Copyright 2007 The MathWorks, Inc.
 *  $Revision: 1.1.8.1 $    $Date: 2007/11/09 20:17:37 $
 *
 *  Purpose   :     Function declarations and type definitions for
 *                  Linear nonlinearity.
 *	To compile: 
 *  mex -g sfunlinear.c eval_linear.c identsfunutils.c
 *  mex -g -output soevaluate soevaluate_linear.c eval_linear.c identsfunutils.c
 * -----------------------------------------------------------------------*/

#ifndef __EVAL_LINEAR_H__
#define __EVAL_LINEAR_H__

/* Structure to store Linear parameters information */
typedef struct ParStruc_tag {
  real_T    OutputOffset;       /* linear.Parameters.OutputOffset */
  real_T    *LinearCoef;        /* linear.Parameters.LinearCoef */
} ParStruc;


/* Parameter Names and Order */
/* This order corresponds to the order of input arguments to S-function: sfun_linear */
enum { 
       Par_OutputOffset_Idx = 2,        Par_LinearCoef_Idx,
       NUM_PARAMS 
    };

/* Linear parameters */
#define PAR_LINEARCOEF(S) ssGetSFcnParam(S, Par_LinearCoef_Idx)
#define PAR_OUTPUTOFFSET(S) ssGetSFcnParam(S, Par_OutputOffset_Idx)

/* Function declarations */
/* Note: NumRows = 1 when called from S function*/
#ifdef __cplusplus
extern "C" {
#endif
void evaluate_linear
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
"Need to supply 4: Ts, NumReg, OutputOffset, LinearCoef";

#endif /* __EVAL_LINEAR_H__ */
