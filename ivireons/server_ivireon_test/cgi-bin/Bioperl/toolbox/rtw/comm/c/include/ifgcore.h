/* 
 *  ifgcore.h
 *  Filtered Gaussian source with interpolation (core C-code).
 *  Shared by MATLAB C-MEX function, SIMULINK C-MEX S-Function, and TLC.
 *
 *  Copyright 1996-2009 The MathWorks, Inc.
 *  $Revision: 1.1.6.7 $ $Date: 2009/04/21 03:55:25 $ 
 */

#ifndef __IFGCORE_H__
#define __IFGCORE_H__

#include "complexops.h"
#include "spc_decl.h"

#ifdef __cplusplus
extern "C" {
#endif

SPC_DECL void coreintfiltgaussian(
    cArray     y,                   /* Interpolating filter output */
    cArray     yd,                  /* Filtered Gaussian source output */
    int_T      Nout,                /* Num. of o/p samples per channel */
    int_T      NC,                  /* Number of channels */
    int_T      ppInterpFactor,
    int_T      ppSubfilterLength,
    real_T    *ppFilterBank,
    cArray     ppFilterInputState,
    int_T     *ppFilterPhase,
    cArray     ppLastFilterOutputs,
    cArray     ppOutput,            /* Polyphase filter output */
    int_T      liLinearInterpFactor,
    int_T     *liLinearInterpIndex,
    int_T     *fgNumSamples,        /* Num. of source samples generated */
    cArray     fgImpulseResponse,   /* Filter impulse response */
    int_T      fgLengthIR,          /* Length of impulse response */
    cArray     fgState,             /* State matrix */
    real_T    *fgWGNState,          /* WGN generator state */
    cArray     fgLastOutputs,       /* Last two outputs */
    cArray     fgWGN,               /* WGN (allocated storage) */
    real64_T  *fgWGN2,              /* WGN (temporary allocated storage) */
    boolean_T  fgImpulseResponseIsReal,		/* Is the impulse response real? */
    boolean_T  fgImpulseResponseIsVector,	/* Is the impulse response a vector? */
    int_T      legacyMode
    );

#ifdef __cplusplus
} // end of extern "C" scope
#endif

#endif

/* [EOF] */
