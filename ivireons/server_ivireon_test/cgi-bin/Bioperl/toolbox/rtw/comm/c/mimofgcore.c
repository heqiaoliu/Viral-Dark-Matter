/* 
 *  mimofgcore.c
 *      Filtered Gaussian source (core C-code).
 *
 *  Copyright 2008-2009 The MathWorks, Inc.
 *  $Revision: 1.1.6.3 $ $Date: 2009/04/21 03:55:17 $ 
 */

#include <math.h>
#include "mimofgcore.h"
#include "comm_floor_d.h"

void coremimofiltgaussian(
    cArray     yc,          /* Output */
    int_T      Nout,        /* Number of samples to output per channel */
    cArray     h,           /* Filter impulse response */
    cArray     u,           /* State matrix */
    cArray     lastOutputs, /* Last two outputs */
    cArray     SQRTCorrMatrix,  /* Square root correlation matrix */
    boolean_T  SQRTisEye,   /* Is the square root correlation matrix unity? */
    cArray     y,           /* Output before correlation (allocated storage) */
    cArray     w,           /* WGN (allocated storage) */
    int_T      NS,          /* Number of samples for y (per channel) */
    int_T      NC,          /* Number of channels */
    int_T      NP,          /* Number of paths */
    int_T      NL,          /* Number of links */
    int_T      lengthIR,    /* Length of impulse response */
    boolean_T  hIsReal,     /* Is the impulse response real? */
    boolean_T  hIsVector    /* Is the impulse response a vector? */
    )
{
    int_T m, n, l, i; /* Loop indices */
             
    /* Compute output for each channel.
       Note that M and N have swapped order compared with above. */
    for (n=0; n<NC; n++)  /* Channel (cols of y, h, u; rows of w) */
    {    
        int_T nN = n*NS;
        
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
                    for (k=0; k<=m && k<=lengthIR-1; k++){
                        int_T iw = (m-k)*NC + n;
                        Re(y, iy) += Re(h,k) * Re(w, iw);
                        Im(y, iy) += Re(h,k) * Im(w, iw);
                    }
                    for (k=m+1; k<=lengthIR-1; k++){
                        int_T iu = (lengthIR+m-k-1)*NC + n;
                        Re(y, iy) += Re(h,k) * Re(u, iu);
                        Im(y, iy) += Re(h,k) * Im(u, iu);
                    }
                }
            } else {
                /* Filter WGN signal, FIR impulse response is complex. */
                for (m=0; m<Nout; m++) 
                {  
                    /* m is sample idx (rows of y, h, u; cols of w) */
                    int_T iy = nN+m, k;
                    Re(y, iy) = Im(y, iy) = 0.0;
                    for (k=0; k<=m && k<=lengthIR-1; k++){
                        int_T iw = (m-k)*NC + n;
                        Re(y, iy) += Re(h, k) * Re(w, iw) - Im(h, k) * Im(w, iw);
                        Im(y, iy) += Re(h, k) * Im(w, iw) + Im(h, k) * Re(w, iw);
                    }
                    for (k=m+1; k<=lengthIR-1; k++){
                        int_T iu = (lengthIR+m-k-1)*NC + n;
                        Re(y, iy) += Re(h, k) * Re(u, iu) - Im(h, k) * Im(u, iu);
                        Im(y, iy) += Re(h, k) * Im(u, iu) + Im(h, k) * Re(u, iu);
                    }
                }
            }
        } else
        {
            /* One impulse response per path (several paths) */
            if (hIsReal)
            {
                /* Filter WGN signal, FIR impulse response is real. */
                for (m=0; m<Nout; m++) {  
                    /* m is sample idx (rows of y, h, u; cols of w) */
                    int_T iy = nN+m, k;
                    Re(y, iy) = Im(y, iy) = 0.0;
                    for (k=0; k<=m && k<=lengthIR-1; k++) {
                        int_T ih = k*NP + commFloor_D(n/NL);
                        int_T iw = (m-k)*NC + n;
                        Re(y, iy) += Re(h, ih) * Re(w, iw);
                        Im(y, iy) += Re(h, ih) * Im(w, iw);
                    }
                    for (k=m+1; k<=lengthIR-1; k++) {
                        int_T ih = k*NP + commFloor_D(n/NL);
                        int_T iu = (lengthIR+m-k-1)*NC + n;
                        Re(y, iy) += Re(h, ih) * Re(u, iu);
                        Im(y, iy) += Re(h, ih) * Im(u, iu);
                    }
                }
            } else 
            {
                /* Filter WGN signal, FIR impulse response is complex. */
                for (m=0; m<Nout; m++) 
                {  
                    /* m is sample idx (rows of y, h, u; cols of w) */
                    int_T iy = nN+m, k;
                    Re(y, iy) = Im(y, iy) = 0.0;
                    for (k=0; k<=m && k<=lengthIR-1; k++) {
                        int_T ih = k*NP + commFloor_D(n/NL);
                        int_T iw = (m-k)*NC + n;
                        Re(y, iy) += Re(h, ih) * Re(w, iw) - Im(h, ih) * Im(w, iw);
                        Im(y, iy) += Re(h, ih) * Im(w, iw) + Im(h, ih) * Re(w, iw);
                    }
                    for (k=m+1; k<=lengthIR-1; k++) {
                        int_T ih = k*NP + commFloor_D(n/NL);
                        int_T iu = (lengthIR+m-k-1)*NC + n;
                        Re(y, iy) += Re(h, ih) * Re(u, iu) - Im(h, ih) * Im(u, iu);
                        Im(y, iy) += Re(h, ih) * Im(u, iu) + Im(h, ih) * Re(u, iu);
                    }
                }
            }
        }
    }

    /* Perform correlation */
    if (SQRTisEye)
    {
        for (i=0; i<NP*NL*Nout; i++) {
            Re(yc, i) = Re(y, i);
            Im(yc, i) = Im(y, i);
        }
    } else
    {
        for (n=0; n<NP; n++) {
            for (l=0; l<NL; l++) {
                for (m=0; m<Nout; m++) {
                    int_T iyc = n*(NL*Nout) + l*Nout + m;
                    Re(yc, iyc) = Im(yc, iyc) = 0.0;
                    for (i=0; i<NL; i++) {
                        int_T iR = n*(NL*NL) + l + i*NL;
                        int_T iy = n*(NL*Nout) + i*Nout + m;
                        Re(yc, iyc) += Re(SQRTCorrMatrix, iR) * Re(y, iy) - 
                                       Im(SQRTCorrMatrix, iR) * Im(y, iy);
                        Im(yc, iyc) += Re(SQRTCorrMatrix, iR) * Im(y, iy) + 
                                       Im(SQRTCorrMatrix, iR) * Re(y, iy);  
                    }
                }
            }
        }
    }

    for (n=0; n<NC; n++) 
    {
        int_T nN = n*NS;

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
                Re(lastOutputs, i2) = Re(yc, n);
                Im(lastOutputs, i2) = Im(yc, n);
            } else
            {
                int_T iy2 = nN + (Nout - 2);
                int_T iy1 = nN + (Nout - 1);
                Re(lastOutputs, n)  = Re(yc, iy2);
                Im(lastOutputs, n)  = Im(yc, iy2);
                Re(lastOutputs, i2) = Re(yc, iy1);
                Im(lastOutputs, i2) = Im(yc, iy1);
            }
        }
    }   
}

/* [EOF] */
