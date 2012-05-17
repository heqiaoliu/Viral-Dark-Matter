/*
 *  File: approx_llr_d_rt.h
 * 
 *  Header file for the Approximate LLR function of the Soft Demodulation feature
 *  for single/float data type.
 *
 *  Copyright 2006 The MathWorks, Inc.
 *  $Revision: 1.1.6.3 $ $Date: 2009/03/09 19:25:29 $
 */

#ifndef __APPROX_LLR_D_RT_H__
#define __APPROX_LLR_D_RT_H__

#include <math.h>
#include <float.h>

#ifndef MW_COMMSTOOLBOX
#include "dsp_rt.h"
#endif

#include "complexops.h"
#include "spc_decl.h"

#ifdef __cplusplus
extern "C" {
#endif
    
/* Approximate LLR for Double types */
SPC_DECL void approx_llr_d(const cArray    inputSignal,    /* input signal */
                  const int_T     numElements,    /* number of input signal elements */
                  const real_T   *noiseVariance,  /* noise variance */
                  const int_T     M,              /* M            */
                  const int_T     nBits,          /* number of bits in symbol (log2(M)) */
                  const cArray    constellation,  /* signal constellation */
                  const int32_T  *S0,             /* symbols having 0 */
                  const int32_T  *S1,             /* symbols having 1 */
                  real_T         *approxLLR       /* output values - Approximate LLR */
    );
    
#ifdef __cplusplus
} // end of extern "C" scope
#endif

#endif  /* __APPROX_LLR_D_RT_H__ */

/* EOF */
