/* 
 *  mimofgcore.h
 *      Filtered Gaussian source (core C-code).
 *
 *  Copyright 2008-2009 The MathWorks, Inc.
 *  $Revision: 1.1.6.2 $ $Date: 2009/04/21 03:55:26 $ 
 */

#ifndef __MIMOFGCORE_H__
#define __MIMOFGCORE_H__

#include "complexops.h"

void coremimofiltgaussian(
    cArray     yc,          /* Output */
    int_T      Nout,        /* Number of samples to output per channel */
    cArray     h,           /* Filter impulse response */
    cArray     u,           /* State matrix */
    cArray     lastOutputs, /* Last two outputs */
    cArray     SQRTCorrMatrix,	/* Square root correlation matrix */
    boolean_T  SQRTisEye,	/* Is the square root correlation matrix unity? */
    cArray     y,           /* Output before correlation (allocated storage) */
    cArray     w,           /* WGN (allocated storage) */
    int_T      NS,          /* Number of samples for y (per channel) */
    int_T      NC,          /* Number of channels */
    int_T      NP,	    /* Number of paths */
    int_T      NL,	    /* Number of links */
    int_T      lengthIR,    /* Length of impulse response */
    boolean_T  hIsReal,	    /* Is the impulse response real? */
    boolean_T  hIsVector    /* Is the impulse response a vector? */
    );

#endif

/* [EOF] */
