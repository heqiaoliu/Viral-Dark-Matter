/* Copyright 2006 The MathWorks, Inc. */

/* $Revision: 1.1.6.1 $ */

#include "cplxgain.h"

void cplx_gain(creal_T *in, creal_T *gain, creal_T *out) {
    out->re = in->re*gain->re - in->im*gain->im;
    out->im = in->re*gain->im + in->im*gain->re;
}


