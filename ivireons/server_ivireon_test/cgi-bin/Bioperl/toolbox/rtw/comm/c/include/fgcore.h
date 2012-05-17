/* 
 *  fgcore.h
 *   Filtered Gaussian source (core C-code).
 *   Shared by MATLAB C-MEX function, SIMULINK C-MEX S-Function, and TLC.
 *
 *  Copyright 1996-2009 The MathWorks, Inc.
 *  $Revision: 1.1.6.5 $ $Date: 2009/04/21 03:55:23 $ 
 */

#ifndef __FGCORE_H__
#define __FGCORE_H__

#include "complexops.h"

void corefiltgaussian(
    cArray     y,           /* Output */
    int_T      Nout,        /* Number of samples to output per channel */
    cArray     h,           /* Filter impulse response */
    cArray     u,           /* State matrix */
    cArray     lastOutputs, /* Last two outputs */
    cArray     w,           /* WGN (allocated storage) */
    int_T      NS,          /* Number of samples for y (per channel) */
    int_T      NC,          /* Number of channels */
    int_T      lengthIR,    /* Length of impulse response */
    boolean_T  hIsReal,	    /* Is the impulse response real? */
    boolean_T  hIsVector    /* Is the impulse response a vector? */
    );

#endif

/* [EOF] */
