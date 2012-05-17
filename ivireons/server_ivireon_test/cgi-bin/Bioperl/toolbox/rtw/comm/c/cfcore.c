/*
 *  cfcore.c
 *   Channel filter - filter method (core C-code).
 *   Shared by MATLAB C-MEX function, SIMULINK C-MEX S-Function, and TLC.
 *
 *  Copyright 1996-2006 The MathWorks, Inc.
 *  $Revision: 1.1.6.3 $ $Date: 2009/03/09 19:25:08 $ 
 */

#include <math.h>
#include "cfcore.h"

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
    cArray       w)              /* Work vector */
{ 
                        
    int_T m, n, k;  /* Loop indices */
        
    if (storePathGains) {
        for (n=0; n<NP*NS; n++) {
            Re(zStore, n) = Re(z, n);
            Im(zStore, n) = Im(z, n);
        }
    }
                         
    /* Fast method for computing output signal.
       May be able to make faster via improved index math. */
    for (m=0; m<NS; m++) {
        Re(y, m) = Im(y, m) = 0.0;
        for (k=0; k<NP; k++) {
            int_T mi;
            if (m+1 >= alphaIndices[k]-1)
                mi = m+1;
            else
                mi = alphaIndices[k]-1;
            Re(w, k) = Im(w, k) = 0.0;
            for (n=alphaIndices[k]-1; n<=m && n<alphaIndices[k+NP]; n++) {
                int_T ix = m-n;
                real_T A = alphaMatrix[n*NP + k];
                Re(w, k) += A * Re(x, ix);
                Im(w, k) += A * Im(x, ix);
            }
            for (n=mi; n<alphaIndices[k+NP]; n++) {
                int_T iu = n-m-1;
                real_T A = alphaMatrix[n*NP + k];
                Re(w, k) += A * Re(u, iu);
                Im(w, k) += A * Im(u, iu);
            }
            {
                int_T iz = k*NS + m;
                Re(y, m) += cmult_Re(z, iz, w, k);
                Im(y, m) += cmult_Im(z, iz, w, k);
            }
        }
    }
    
    /* Update state. */
     for (n=NG-1; n>=NS; n--) {
        int_T iu = n-NS;
        Re(u, n) = Re(u, iu);
        Im(u, n) = Im(u, iu);
    }
    for (n=0; n<NS && n<NG; n++) {
        int_T ix = NS-1-n;
        Re(u, n) = Re(x, ix);
        Im(u, n) = Im(x, ix);
    }
    
}

/* [EOF] */
