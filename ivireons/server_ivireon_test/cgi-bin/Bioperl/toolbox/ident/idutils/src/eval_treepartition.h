/* ------------------------------------------------------------------------
 *  Program   :     eval_treepartition.h
 *  Author    :     Rajiv Singh
 *
 *  Copyright 2007 The MathWorks, Inc.
 *  $Revision: 1.1.8.2 $    $Date: 2007/12/14 14:46:40 $
 *
 *  Purpose   :     Function declarations and type definitions for
 *                  Tree Partition nonlinearity.
 *	To compile: mex -g sfuntreepartition.c eval_treepartition.c
 * -----------------------------------------------------------------------*/

#ifndef __EVAL_TREEPARTITION_H__
#define __EVAL_TREEPARTITION_H__

/* Structure to store tree-partition's Parameters.Tree variables */
typedef struct TreeStruc_tag {
    real_T  *TreeLevelPntr;         /* treepartition.Parameters.Tree.TreeLevelPntr */
    real_T  *AncestorDescendantPntr;/* treepartition.Parameters.Tree.AncestorDescendantPntr */
    real_T  *LocalizingVectors;     /* treepartition.Parameters.Tree.LocalizingVectors */
    real_T  *LocalCovMatrix;        /* treepartition.Parameters.Tree.LocalCovMatrix */
    real_T  *LocalParVector;        /* treepartition.Parameters.Tree.LocalParVector */
} TreeStruc;

/* Structure to store tree-partition parameters information */
typedef struct ParStruc_tag {
  boolean_T IsLinear;    /* Flag to denote if Tree Partition is linear (trivial case) */
  real_T	*ttv;		/* temporary array required by evaluate_tree */
  real_T	*ttm;		/* temporary array required by evaluate_tree */
  real_T	*lfmax;		/* temporary array required by evaluate_tree */
  real_T	*lfmin;		/* temporary array required by evaluate_tree */
  uint_T    NumberOfUnits;      /* treepartition.NumberOfUnits */
  real_T    Threshold;          /* treepartition.Options.Threshold */
  real_T    *RegressorMean;     /* treepartition.Parameters.RegressorMean */
  real_T    OutputOffset;       /* treepartition.Parameters.OutputOffset */
  real_T    *LinearCoef;        /* treepartition.Parameters.LinearCoef */
  uint_T    SampleLength;       /* treepartition.Parameters.SampleLength */
  real_T    NoiseVariance;      /* treepartition.Parameters.NoiseVariance */
  TreeStruc *Tree;              /* treepartition.Parameters.Tree */
} ParStruc;

/* -----------------------------------------------------------------------
 * Stuff required by S function
 * -----------------------------------------------------------------------
 */ 

/* Parameter Names and Order */
/* This order corresponds to the order of input arguments to S-function: sfun_treepartition */
enum { 
       NumUnits_Idx = 2,            Par_RegressorMean_Idx,  
       Par_OutputOffset_Idx,        Par_LinearCoef_Idx,
       Par_SampleLength_Idx,        Par_NoiseVariance_Idx, 
       Tree_TreeLevelPntr_Idx,      Tree_AncestorDescendantPntr_Idx, 
       Tree_LocalizingVectors_Idx,  Tree_LocalCovMatrix_Idx, 
       Tree_LocalParVector_Idx,     Opt_Threshold_Idx,
       NUM_PARAMS
    };
   
/* Tree Partition parameters */
#define NUMUNITS(S) ssGetSFcnParam(S, NumUnits_Idx)
#define PAR_REGRESSORMEAN(S) ssGetSFcnParam(S, Par_RegressorMean_Idx)
#define PAR_OUTPUTOFFSET(S) ssGetSFcnParam(S, Par_OutputOffset_Idx)
#define PAR_LINEARCOEF(S) ssGetSFcnParam(S, Par_LinearCoef_Idx)
#define PAR_SAMPLELENGTH(S) ssGetSFcnParam(S, Par_SampleLength_Idx)
#define PAR_NOISEVARIANCE(S) ssGetSFcnParam(S, Par_NoiseVariance_Idx)

#define TREE_TREELEVELPNTR(S) ssGetSFcnParam(S, Tree_TreeLevelPntr_Idx)
#define TREE_ANCESTORDESCENDANTPNTR(S) ssGetSFcnParam(S, Tree_AncestorDescendantPntr_Idx)
#define TREE_LOCALIZINGVECTORS(S) ssGetSFcnParam(S, Tree_LocalizingVectors_Idx)
#define TREE_LOCALCOVMATRIX(S) ssGetSFcnParam(S, Tree_LocalCovMatrix_Idx)
#define TREE_LOCALPARVECTOR(S) ssGetSFcnParam(S, Tree_LocalParVector_Idx)

#define OPT_THRESHOLD(S) ssGetSFcnParam(S, Opt_Threshold_Idx)

#ifndef MAX
#define MAX(a,b) (((a-b)>=0)?a:b)
#endif

#ifndef MIN
#define MIN(a,b) (((a-b)<=0)?a:b)
#endif


/* Function declarations */
/* Note: NumRows = 1 when called from S function */
#ifdef __cplusplus
extern "C" {
#endif
void evaluate_treepartition
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
"Need to supply 14: Ts, NumReg, NumUnits, RegressorMean, OutputOffset, "
"LinearCoef, SampleLength, NoiseVariance, TreeLevelPntr, "
"AncestorDescendantPntr, LocalizingVectors, LocalCovMatrix, LocalParVector, "
"Threshold";

#endif /* __EVAL_TREEPARTITION_H__ */
