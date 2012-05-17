/*
 *  File: psk_opt_approx_llr_r_rt.h
 * 
 *  Header file for the optimized Approximate LLR function of the MPSK demodulator
 *  for single/float data-type.
 *
 *  Copyright 2006-2007 The MathWorks, Inc.
 *  $Revision: 1.1.6.4 $ $Date: 2009/03/09 19:25:43 $
 */

#ifndef __PSK_OPT_APPROX_LLR_R_RT_H__
#define __PSK_OPT_APPROX_LLR_R_RT_H__

#include "dsp_rt.h"
#include "complexops.h"
#include "spc_decl.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Optimized approximate LLR for Double types */
SPC_DECL void psk_opt_approx_llr_r(const cArray32   inputSignal,       /* input signal */
                          const int_T      numElements,       /* number of input signal elements */
                          const real32_T  *noiseVariance,     /* noise variance */
                          const int_T      M,                 /* M            */
                          const int_T      nBits,             /* number of bits in symbol (log2(M)) */
                          const real32_T   normFactor,        /* normalization factor (M/DSP_PI) */
                          const real32_T  *cosInitialPhase,   /* cos of initial phase */
                          const real32_T  *sinInitialPhase,   /* sin of initial phase */
                          const cArray32   constellation,     /* signal constellation */
                          const int32_T   *minIdx0,           /* index of nearest symbol having 0 */
                          const int32_T   *minIdx1,           /* index of nearest symbol having 1 */
                          real32_T        *approxLLR          /* output values - Approximate LLR */
    );
    
#ifdef __cplusplus
} // end of extern "C" scope
#endif

#endif  /* __PSK_OPT_APPROX_LLR_R_RT_H__ */

/* EOF */
