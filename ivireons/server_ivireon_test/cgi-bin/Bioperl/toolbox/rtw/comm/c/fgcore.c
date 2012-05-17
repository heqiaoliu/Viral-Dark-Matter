/* 
 *  fgcore.c
 *   Filtered Gaussian source (core C-code).
 *   Shared by MATLAB C-MEX function, SIMULINK C-MEX S-Function, and TLC.
 *
 *  Copyright 1996-2009 The MathWorks, Inc.
 *  $Revision: 1.1.6.5 $ $Date: 2009/04/21 03:55:13 $ 
 */

#include <math.h>
#include "fgcore.h"

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
    boolean_T  hIsReal,		/* Is the impulse response real? */
    boolean_T  hIsVector	/* Is the impulse response a vector? */
    )
{
    int_T m, n, nN; /* Loop indices */

    /* Compute output for each channel.
       Note that M and N have swapped order compared with above. */
    for (n=0; n<NC; n++) {  /* Channel (cols of y, h, u; rows of w) */
        
        nN = n*NS;
        

        if (hIsVector)
        {
            /* Only one impulse response for all path(s) */

            if (hIsReal)
            {
                /* Filter WGN signal, FIR impulse response is real. */
                for (m=0; m<Nout; m++) 
                {  
                    /* m is sample idx (rows of y, h, u; cols of w) */
                    int_T iy = nN+m, k;
                    Re(y, iy) = Im(y, iy) = 0.0;
                    for (k=0; k<=m && k<=lengthIR-1; k++) 
                    {
                        int_T iw = (m-k)*NC + n;
                        Re(y, iy) += Re(h,k) * Re(w, iw);
                        Im(y, iy) += Re(h,k) * Im(w, iw);
                    }
                    for (k=m+1; k<=lengthIR-1; k++) 
                    {
                        int_T iu = (lengthIR+m-k-1)*NC + n;
                        Re(y, iy) += Re(h,k) * Re(u, iu);
                        Im(y, iy) += Re(h,k) * Im(u, iu);
                    }
                }
            }
            else 
            {
                /* Filter WGN signal, FIR impulse response is complex. */
                for (m=0; m<Nout; m++) 
                {  
                    /* m is sample idx (rows of y, h, u; cols of w) */
                    int_T iy = nN+m, k;
                    Re(y, iy) = Im(y, iy) = 0.0;
                    for (k=0; k<=m && k<=lengthIR-1; k++) 
                    {
                        int_T iw = (m-k)*NC + n;
                        Re(y, iy) += Re(h, k) * Re(w, iw) - Im(h, k) * Im(w, iw);
                        Im(y, iy) += Re(h, k) * Im(w, iw) + Im(h, k) * Re(w, iw);
                    }
                    for (k=m+1; k<=lengthIR-1; k++) 
                    {
                        int_T iu = (lengthIR+m-k-1)*NC + n;
                        Re(y, iy) += Re(h, k) * Re(u, iu) - Im(h, k) * Im(u, iu);
                        Im(y, iy) += Re(h, k) * Im(u, iu) + Im(h, k) * Re(u, iu);
                    }
                }
            }

        }
        else
        {
            /* One impulse response per path (several paths) */
            if (hIsReal)
            {
                /* Filter WGN signal, FIR impulse response is real. */
                for (m=0; m<Nout; m++) 
                {  
                    /* m is sample idx (rows of y, h, u; cols of w) */
                    int_T iy = nN+m, k;
                    Re(y, iy) = Im(y, iy) = 0.0;
                    for (k=0; k<=m && k<=lengthIR-1; k++) 
                    {
                        int_T ih = k*NC + n;
                        int_T iw = (m-k)*NC + n;
                        Re(y, iy) += Re(h, ih) * Re(w, iw);
                        Im(y, iy) += Re(h, ih) * Im(w, iw);
                    }
                    for (k=m+1; k<=lengthIR-1; k++) 
                    {
                        int_T ih = k*NC + n;
                        int_T iu = (lengthIR+m-k-1)*NC + n;
                        Re(y, iy) += Re(h, ih) * Re(u, iu);
                        Im(y, iy) += Re(h, ih) * Im(u, iu);
                    }
                }
            }
            else 
            {
                /* Filter WGN signal, FIR impulse response is complex. */
                for (m=0; m<Nout; m++) 
                {  
                    /* m is sample idx (rows of y, h, u; cols of w) */
                    int_T iy = nN+m, k;
                    Re(y, iy) = Im(y, iy) = 0.0;
                    for (k=0; k<=m && k<=lengthIR-1; k++) 
                    {
                        int_T ih = k*NC + n;
                        int_T iw = (m-k)*NC + n;
                        Re(y, iy) += Re(h, ih) * Re(w, iw) - Im(h, ih) * Im(w, iw);
                        Im(y, iy) += Re(h, ih) * Im(w, iw) + Im(h, ih) * Re(w, iw);
                    }
                    for (k=m+1; k<=lengthIR-1; k++) 
                    {
                        int_T ih = k*NC + n;
                        int_T iu = (lengthIR+m-k-1)*NC + n;
                        Re(y, iy) += Re(h, ih) * Re(u, iu) - Im(h, ih) * Im(u, iu);
                        Im(y, iy) += Re(h, ih) * Im(u, iu) + Im(h, ih) * Re(u, iu);
                    }
                }
            }

        }

     
        /* Update state. */
        {
            int_T k, i1 ,i2, k1;
            int_T N = lengthIR - Nout;
            for (k=0; k<=N-2; k++) 
            {
                i1 = k*NC + n;
                i2 = (k+Nout)*NC + n;
                Re(u, i1) = Re(u, i2);
                Im(u, i1) = Im(u, i2);
            }
            if (N<=0) k1=0; else k1=N-1;
            for (k=k1; k<=lengthIR-2; k++) 
            {
                i1 = k*NC + n;
                i2 = (k-N+1)*NC + n;
                Re(u, i1) = Re(w, i2);
                Im(u, i1) = Im(w, i2);
            }
        }   
       
        /* Store last two outputs. */
        {
            int_T i2 = NC + n;
                        
            if (Nout==1)
            {
                Re(lastOutputs, n)  = Re(lastOutputs, i2);
                Im(lastOutputs, n)  = Im(lastOutputs, i2);
                Re(lastOutputs, i2) = Re(y, n);
                Im(lastOutputs, i2) = Im(y, n);
            }
            else
            {
                int_T iy2 = nN + (Nout - 2);
                int_T iy1 = nN + (Nout - 1);
                Re(lastOutputs, n)  = Re(y, iy2);
                Im(lastOutputs, n)  = Im(y, iy2);
                Re(lastOutputs, i2) = Re(y, iy1);
                Im(lastOutputs, i2) = Im(y, iy1);
            }
        }
    }   
}

/* [EOF] */
