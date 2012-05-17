/*
 *  mimocfcore.c
 *   Channel filter - filter method (core C-code).
 *
 *  Copyright 2008 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $ $Date: 2008/10/31 06:54:13 $ 
 */

#include <math.h>
#include "mimocfcore.h"

void coremimochannelfilter(
    const cArray x,              /* Input signal */
    const cArray z,              /* Complex path gains */
    cArray       y,              /* Output signal */
    int_T        NS,             /* Number of input/output samples */
    int_T        NP,             /* Number of paths */
    int_T        NG,             /* Number of channel filter gains */
    int_T        NT,             /* Number of Tx antennas */
    int_T        NR,             /* Number of Rx antennas */
    real_T      *alphaMatrix,    /* Matrix for transforming gains */
    cArray       u,              /* Input state vector */
    cArray       w)              /* Work vector */
{ 
                        
    int_T it, ir, m, n, k;  /* Loop indices */
        
    /* Calculate output */                    
    for (it=0; it<NT; it++)
    {
        for (ir=0; ir<NR; ir++) 
        {
            for (m=0; m<NS; m++) 
            {
                Re(y, m + it*NR*NS + ir*NS) = Im(y, m + it*NR*NS + ir*NS) = 0.0;
                for (k=0; k<NP; k++) 
                {
                    int_T mi = m+1;

                    Re(w, k) = Im(w, k) = 0.0;
                    for (n=0; n<=m && n<NG; n++) 
                    {
                        int_T ix = m-n + it*NS;
                        real_T A = alphaMatrix[n*NP + k];
                        Re(w, k) += A * Re(x, ix);
                        Im(w, k) += A * Im(x, ix);
                    }
                    for (n=mi; n<NG; n++) 
                    {
                        int_T iu = n-m-1 + it*NG;
                        real_T A = alphaMatrix[n*NP + k];
                        Re(w, k) += A * Re(u, iu);
                        Im(w, k) += A * Im(u, iu);
                    }

                    {
                        int_T iz = k*NS + m + it*NR*NS*NP + ir*NS*NP;
                        Re(y, m + it*NR*NS + ir*NS) += cmult_Re(z, iz, w, k);
                        Im(y, m + it*NR*NS + ir*NS) += cmult_Im(z, iz, w, k);
                    }
                }
            }
        }
    }

    /* Update state. */
    for (it=0; it<NT; it++)
    {
        for (n=NG-1; n>=NS; n--) 
        {
            int_T iu = n-NS + it*NG;
            Re(u, n + it*NG) = Re(u, iu);
            Im(u, n + it*NG) = Im(u, iu);
        }
    }
    for (it=0; it<NT; it++)
    {
        for (n=0; n<NS && n<NG; n++) 
        {
            int_T ix = NS-1-n + it*NS;
            Re(u, n + it*NG) = Re(x, ix);
            Im(u, n + it*NG) = Im(x, ix);
        }
    }
}

/* [EOF] */
