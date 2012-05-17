/* 
 *  gaussian.c
 *   Gaussian noise generator
 *   Shared by SIMULINK C-MEX S-Function, and TLC.
 *
 *  Copyright 2009 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $ Date: 2007/05/14 15:16:50 $ 
 */

#include "gaussian.h"

SPC_DECL void generateGaussianSamples(int Nout, int NC, cArray w, real64_T *w2, real_T *WGNState, int legacyMode)
{
    int_T m, n, i1, i2;
    real_T sqrt2 = sqrt(2.0);

    legacyMode = 1; /* This should always work in legacy mode */

    /* Generate multi-channel white Gaussian signal.
       Note that these w and w2 have each channel in a row, *NOT* col. */
    commrandnv5(w2, 2*NC, Nout, WGNState);

    for (m=0; m<Nout; m++) {
        for (n=0; n<NC; n++) {
            i1 = m*NC + n;
            i2 = m*(2*NC) + n;
            Re(w, i1) = w2[i2] / sqrt2;
            Im(w, i1) = w2[i2+NC] / sqrt2;
        }
    }

}


/* [EOF] */

