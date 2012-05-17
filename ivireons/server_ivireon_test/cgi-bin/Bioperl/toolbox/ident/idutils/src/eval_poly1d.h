/* ------------------------------------------------------------------------
 *  Program   :     eval_poly1d.h
 *  Author    :     Rajiv Singh
 *
 *  Copyright 2007 The MathWorks, Inc.
 *  $Revision: 1.1.8.1 $    $Date: 2007/11/09 20:17:39 $
 *
 *  Purpose   :     Function declarations and type definitions for
 *                  Poly1d nonlinearity.
 *	To compile: 
 *  mex -g sfunpoly1d.c eval_poly1d.c  
 * -----------------------------------------------------------------------*/

#ifndef __EVAL_POLY1D_H__
#define __EVAL_POLY1D_H__

/* Structure to store poly1d parameters */
typedef struct ParStruc_tag {
  uint_T    Degree;         /* Degree */  
  real_T    *Coefficients;  /* Coefficients */
 } ParStruc;


/* Parameter Names and Order */
/* This order corresponds to the order of input arguments to S-function: sfunpoly1d */
enum { Ts_Idx,
       Par_Degree_Idx,          Par_Coefficients_Idx,
       NUM_PARAMS
    };

/* POLY1D parameters */
#define TS(S)               ssGetSFcnParam(S, Ts_Idx)
#define PAR_DEGREE(S)       ssGetSFcnParam(S, Par_Degree_Idx)
#define PAR_COEFFICIENTS(S) ssGetSFcnParam(S, Par_Coefficients_Idx)

/* Function declarations */
/* Note: NumRows = 1 when called from S function*/
#ifdef __cplusplus
extern "C" {
#endif
void evaluate_poly1d
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
"Need to supply 3: Ts,  Degree, Coefficients"; 

static char *wrongDimInp = "Regressor must have dimension =  1 (scalar).";

#endif /* __EVAL_POLY1D_H__ */
