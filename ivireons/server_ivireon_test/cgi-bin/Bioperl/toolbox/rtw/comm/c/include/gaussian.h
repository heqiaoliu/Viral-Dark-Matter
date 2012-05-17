/* 
 *  gaussian.h
 *   Gaussian source (core C-code).
 *   Shared by MATLAB C-MEX function, SIMULINK C-MEX S-Function, and TLC.
 *
 *  Copyright 2009 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $ $Date: 2009/04/21 03:55:24 $ 
 */

#ifndef __GAUSSIAN_H__
#define __GAUSSIAN_H__

#include <math.h>
#include "commrandn.h"
#include "complexops.h"
#include "spc_decl.h"

#ifdef __cplusplus
extern "C" {
#endif

SPC_DECL void generateGaussianSamples(int Nout, int NC, cArray w, real64_T *w2, real_T *WGNState, int legacyMode);

#ifdef __cplusplus
} // end of extern "C" scope
#endif

#endif

/* [EOF] */
