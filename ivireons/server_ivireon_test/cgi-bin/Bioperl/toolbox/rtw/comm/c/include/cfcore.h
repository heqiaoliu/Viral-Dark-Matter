/* 
 *  cfcore.h
 *   Channel filter - filter method (core C-code).
 *   Shared by MATLAB C-MEX function, SIMULINK C-MEX S-Function, and TLC.
 *
 *  Copyright 1996-2006 The MathWorks, Inc.
 *  $Revision: 1.1.6.4 $ $Date: 2009/03/09 19:25:31 $ 
 */

#ifndef __CFCORE_H__
#define __CFCORE_H__

#include "complexops.h"
#include "spc_decl.h"

#ifdef __cplusplus
extern "C" {
#endif

SPC_DECL void corechannelfilter(
    const cArray x,              /* Input signal */
    const cArray z,              /* Complex path gains */
    cArray       y,              /* Output signal */
    cArray       zStore,         /* Complex path gains - store */
    boolean_T    storePathGains, /* Flag denoting to store path gains 
                                    in zStore */
    int_T        NS,             /* Number of input/output samples */
    int_T        NP,             /* Number of paths */
    int_T        NG,             /* Number of channel filter gains */
    real_T      *alphaMatrix,    /* Matrix for transforming gains */
    int_T       *alphaIndices,   /* Matrix indices for transform */
    cArray       u,              /* Input state vector */
    cArray       w);             /* Work vector */

#ifdef __cplusplus
} // end of extern "C" scope
#endif

#endif

/* [EOF] */
