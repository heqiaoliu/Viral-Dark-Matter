/* 
 *  mimoifgcore.c
 *  Filtered Gaussian source with interpolation (core C-code).
 *
 *  Copyright 2008-2009 The MathWorks, Inc.
 *  $Revision: 1.1.6.3 $ $Date: 2009/04/21 03:55:19 $ 
 */

/* The interpfilter is currently hard-wired to use a filtgaussian source. */

#include <math.h>
#include "gaussian.h"
#include "mimofgcore.h"
#include "mimoifgcore.h"
#include "comm_ceil_d.h"
#include "comm_floor_d.h"

void mimopolyphasefilter(
    cArray     y,                           /* Interpolating filter output */
    int_T      yStartIdx,                   /* Index of first sample in output */
    int_T      Nout,                        /* Number of samples to output per channel */
    cArray     x,                           /* Filtered Gaussian source output */
    int_T     *numSourceSamples,            /* Number of source samples generated */
    int_T      NS,                          /* Number of samples alloc. to y (per channel) */
    int_T      NC,                          /* Number of channels */
    int_T      NP,                          /* Number of paths */
    int_T      NL,                          /* Number of links */
    int_T      ppInterpFactor,
    int_T      ppSubfilterLength,
    real_T    *ppFilterBank,
    cArray     ppFilterInputState,
    int_T     *ppFilterPhase,
    cArray     ppLastFilterOutputs,
    cArray     fgImpulseResponse,           /* Filter impulse response */
    int_T      fgLengthIR,                  /* Length of impulse response */
    cArray     fgState,                     /* State matrix */
    real_T    *fgWGNState,                  /* WGN generator state */
    cArray     fgLastOutputs,               /* Last two outputs */
    cArray     fgSQRTCorrMatrix,            /* Square root correlation matrix */    
    boolean_T  fgSQRTisEye,                 /* Is the square root correlation matrix unity? */
    cArray     fgY,                         /* Output before correlation (allocated storage) */
    cArray     fgWGN,                       /* WGN (allocated storage) */
    real64_T  *fgWGN2,                      /* WGN (temporary allocated storage) */
    boolean_T  fgImpulseResponseIsReal,     /* Is the impulse response real? */
    boolean_T  fgImpulseResponseIsVector,   /* Is the impulse response a vector? */
    int_T      legacyMode
    )
{
 
    int_T m, n, i, /* Loop indices */
          N, startPhase;
    
    int_T
        R = ppInterpFactor,
        M = ppSubfilterLength;
    
    real_T
       *g = ppFilterBank;
    
    cArray
        u = ppFilterInputState;  /* Not transposed (unlike M-code) */
    
    /* Return if no output samples requested; no source samples required. */
    if (Nout==0) {
        *numSourceSamples = 0; 
        return;
    }
    
    /* Increment polyphase filter phase by 1.
       The additional -1 and +1 are because phase is 1-based, 
       but % is 0-based. */
    startPhase = (*ppFilterPhase+1 - 1)%R + 1;
    
    if (R==1) {
        /* No polyphase interpolation. */
        
        /* Number of source samples equals number of output samples */
        N = Nout;
        
        /* Generate complex Gaussian samples */
        generateGaussianSamples(N, NC, fgWGN, fgWGN2, fgWGNState, legacyMode);
        
        /* Generate source samples. */
        coremimofiltgaussian(
            x,
            N,
            fgImpulseResponse,
            fgState,
            fgLastOutputs,
            fgSQRTCorrMatrix,
            fgSQRTisEye,
            fgY,
            fgWGN,
            NS, /* Number of samples *allocated* to x */
            NC,
            NP,
            NL,
            fgLengthIR,
            fgImpulseResponseIsReal,
            fgImpulseResponseIsVector
            );
        
        /* Output samples are exactly equal to source samples. */
        for (m=0; m<NC; m++) {
            for (n=0; n<Nout; n++) {
                i = NS*m + n;
                Re(y, i) = Re(x, i);
                Im(y, i) = Im(x, i);
            }
        }

        /* State matrix.
           Note: In this case, the state matrix is not used, 
           but is included for completeness. */
        for (m=0; m<NC; m++) {
            n = N*(m+1)-1;
            Re(u, m) = Re(x, n);
            Im(u, m) = Im(x, n);
        } 

    } else
    {
        int_T m0;        
        
        /* m0 is the number of samples to output *without* generating new 
           source samples.  This is necessary when the starting phase is 
           not equal to 1. */
        m0 = (R - (startPhase-1))%R;
        m0 = (m0>Nout)? Nout : m0;
                
        /* Flush polyphase filter if needed. */
        if (m0>0) 
        {
            /* Equivalent M-code: 
               y(:, 1:m0) = (g((1:m0)+startPhase-1, :)*u).'; */
            int_T k, iy, ig, iu;
            for (m=0; m<NC; m++) {
                for (n=0; n<m0; n++) {
                    iy = NS*m + n + yStartIdx;
                    Re(y, iy) = 0.0;
                    Im(y, iy) = 0.0;
                    for (k=0; k<M; k++) {
                        ig = R*k + startPhase-1 + n;
                        iu = NC*k + m;
                        Re(y, iy) += g[ig] * Re(u, iu);
                        Im(y, iy) += g[ig] * Im(u, iu);                     
                    }
                }
            }
        }
                
        /* Required number of source samples. */
        N = commCeil_D(((real_T)(Nout - m0))/((real_T) R));
                
        /* Compute outputs if new source samples needed. */
        if (N>0) 
        {
            /* Generate complex Gaussian samples */
            generateGaussianSamples(N, NC, fgWGN, fgWGN2, fgWGNState, legacyMode);
        
            /* Generate source samples. */
            coremimofiltgaussian(
                x,
                N,
                fgImpulseResponse,
                fgState,
                fgLastOutputs,
                fgSQRTCorrMatrix,
                fgSQRTisEye,
                fgY,
                fgWGN,
                N,
                NC,
                NP,
                NL,
                fgLengthIR,
                fgImpulseResponseIsReal,
                fgImpulseResponseIsVector
                );
                        
            /* Compute outputs and update state matrix. */
            for (m=0; m<NC; m++) 
            {
                for (n=0; n<N; n++) {
                             
                    /* Shift polyphase filter input state. */
                    int_T i1;
                    for (i1=M-2; i1>=0; i1--) {
                        int_T iu1 = NC*i1 + m;
                        int_T iu2 = iu1 + NC;
                        Re(u, iu2) = Re(u, iu1);
                        Im(u, iu2) = Im(u, iu1);                       
                    }
                    
                    /* Set first element of filter input state 
                       (for each channel). */
                    {
                        int_T iu = m;
                        int_T ix = N*m + n;
                        Re(u, iu) = Re(x, ix);
                        Im(u, iu) = Im(x, ix);
                    }
                    
                    /* Compute outputs and update state matrix.
                       Note that these are zero-based indices, 
                       unlike M-code. */
                    {
                        int_T
                            m1 = m0 + n*R,   /* Start index for output */
                            m2 = m1 + R - 1, /* End index for output */
                            nn, ig0;         /* Loop index */
                        
                        /* Modify indices if needed. */
                        if (n==N-1 && m2>Nout-1) {
                            m2 = Nout-1;
                        }                        
                                                                                
                       /* Equivalent M-code:  
                          y(:,m1:m2) = (g(1:Lm,:)*u).'; */
                       ig0 = 0; 
                       for (nn=m1; nn<=m2; nn++) {
                            int_T k, iy;
                            iy = NS*m + nn + yStartIdx;
                            Re(y, iy) = 0.0;
                            Im(y, iy) = 0.0;
                            for (k=0; k<M; k++) {
                                int_T ig, iu;
                                ig = R*k + ig0;
                                iu = NC*k + m;
                                Re(y, iy) += g[ig] * Re(u, iu);
                                Im(y, iy) += g[ig] * Im(u, iu);
                            }
                            ig0++;
                        }
                    }
                   
                }  /* for n */
            }  /* for m */
        } /* if (N>0) */
    } /* if (R==1) */
    
    /* Update polyphase filter phase.
       The additional -1 and +1 are because phase is 1-based,
       but % is 0-based. */
    *ppFilterPhase = (startPhase+(Nout-1) - 1)%R + 1;
    
    /* Store last *two* outputs for each path. 
       Needed for linear interpolation. */
    
    if (Nout==1) {
        /* Equivalent M-code: 
           ppLastFilterOutputs = [ppLastFilterOutputs(:, end) y]; */
        for (m=0; m<NC; m++) {
            int_T mPlusNC = m+NC;
            int_T iy = NS*m + yStartIdx;
            Re(ppLastFilterOutputs, m) = Re(ppLastFilterOutputs, mPlusNC);
            Im(ppLastFilterOutputs, m) = Im(ppLastFilterOutputs, mPlusNC);
            Re(ppLastFilterOutputs, mPlusNC) = Re(y, iy);
            Im(ppLastFilterOutputs, mPlusNC) = Im(y, iy);
        }
    } else {
        /* Equivalent M-code: 
           ppLastFilterOutputs = y(:, end-[1 0]); */
        for (m=0; m<NC; m++) {
            int_T mPlusNC = m+NC;
            int_T 
                iy1 = NS*m + Nout-2 + yStartIdx, 
                iy2 = iy1+1;
            Re(ppLastFilterOutputs, m) = Re(y, iy1);
            Im(ppLastFilterOutputs, m) = Im(y, iy1);
            Re(ppLastFilterOutputs, mPlusNC) = Re(y, iy2);
            Im(ppLastFilterOutputs, mPlusNC) = Im(y, iy2);
        }
    }
    
    /* Store number of source samples processed. */
    *numSourceSamples = N; 
}


/*-----------------------------------------------------------------------*/
/* Equivalent M-code: 
    function z = mimolinearinterpolation(y, N, i);
    if N==1
        z = y(i);
    else
        D = [diff(y) 0]; % Last value unimportant, but needed for indexing.
        b = (i-1)/N;
        k = floor(b);
        n = k+1; % Index into y, based on index into z.
        z =  y(n) + (b-k).*D(n);
    end
 */
void mimolinearinterpolation(
    cArray z,  /* Output after linear interpolation */
    cArray y,  /* Input samples */
    int_T m,   /* Channel index */
    int_T NSz, /* Number of output samples *allocated* per channel */
    int_T NSy, /* Number of input samples *allocated* per channel */
    int_T KI,  /* Interpolation factor  */
    int_T startIdx,
    int_T endIdx) 
{
    int_T n, p=0;
        
    if (KI==1) {
        for (n=startIdx-1; n<endIdx; n++) {
            int_T iz = NSz*m + p;
            int_T iy = NSy*m + n;
            Re(z, iz) = Re(y, iy);
            Im(z, iz) = Im(y, iy);
            p++;
        }      
    } else {
        for (n=startIdx-1; n<endIdx; n++) {
            real_T b = (real_T)n/(real_T)KI;
            int_T k =  commFloor_D(b);
            int_T iz = NSz*m + p;
            int_T iy1 = NSy*m + k;
            int_T iy2 = iy1 + 1;
            Re(z, iz) = Re(y, iy1) + (b-k)*(Re(y, iy2) - Re(y, iy1));
            Im(z, iz) = Im(y, iy1) + (b-k)*(Im(y, iy2) - Im(y, iy1));
            p++;
        }
    }
}

/*-----------------------------------------------------------------------*/
void coremimointfiltgaussian(
    cArray     y,                   /* Interpolating filter output */
    cArray     yd,                  /* Filtered Gaussian source output */
    int_T      Nout,                /* Num. of o/p samples per channel */
    int_T      NC,                  /* Number of channels */
    int_T      NP,                  /* Number of paths */
    int_T      NL,                  /* Number of links */
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
    cArray     fgSQRTCorrMatrix,    /* Square root correlation matrix */    
    boolean_T  fgSQRTisEye,         /* Is the square root correlation matrix unity? */
    cArray     fgY,                 /* Output before correlation (allocated storage) */
    cArray     fgWGN,               /* WGN (allocated storage) */
    real64_T  *fgWGN2,              /* WGN (temporary allocated storage) */
    boolean_T  fgImpulseResponseIsReal,     /* Is the impulse response real? */
    boolean_T  fgImpulseResponseIsVector,   /* Is the impulse response a vector? */
    int_T      legacyMode
    )
{
        
   int_T
      NSpp = Nout>1 ? Nout : 2,
      /* Nout is the number of samples allocated to y. 
         NSpp is the number of samples allocated to each channel of ppOutput.
      */
      ppOutStartIdx,
      KI = liLinearInterpFactor;
   
   if (Nout==0) {
       *fgNumSamples = 0;
       return;
   }
   
   if (KI==1) {
       
       /* Polyphase filtering only; no linear interpolation. */
       ppOutStartIdx = 0;
       mimopolyphasefilter(
           y,
           ppOutStartIdx,
           Nout,
           yd,
           fgNumSamples,
           Nout,  /* Number of samples *allocated* to y */
           NC,
           NP,
           NL,
           ppInterpFactor,
           ppSubfilterLength,
           ppFilterBank,
           ppFilterInputState,
           ppFilterPhase,
           ppLastFilterOutputs,
           fgImpulseResponse,
           fgLengthIR,
           fgState,
           fgWGNState,
           fgLastOutputs,
           fgSQRTCorrMatrix,
           fgSQRTisEye,
           fgY,
           fgWGN,
           fgWGN2,
           fgImpulseResponseIsReal,
           fgImpulseResponseIsVector,
           legacyMode);

   } else {
       
       int_T 
           startIdx, 
           endIdx, 
           numSamples,
           numPrevOutputs,
           numNewOutputs,
           m, n;
                     
       /* Hybrid of polyphase filtering and linear interpolation. */
       
       /* Linear interpolation indices. */
       startIdx = *liLinearInterpIndex;
       endIdx = startIdx + Nout - 1;
       
       /* Number of samples required for linear interpolation.  
          Special cases:
          startIdx==1 and Nout==1 ==> numSamples = 1 (no interpolation)
          startIdx==1 and Nout<=KI+1 OR
          startIdx==2 and Nout<=KI ==> numSamples = 2 (2-pt interpolation) 
       */
       numSamples = commCeil_D((real_T)(endIdx-1) / (real_T)KI) + 1;
       
       /* Determine *previous* polyphase filter outputs.
          If startIdx of linear interpolation is 1 or 2,
          use only last filter output.
          Otherwise, use last *two* outputs. */
       
       numPrevOutputs = (startIdx>2)? 2 : 1;
       for (m=0; m<NC; m++) {
           for (n=0; n<numPrevOutputs; n++) {
               int_T iy = NSpp*m + n;
               int_T iL = NC*((2-numPrevOutputs)+n) + m;
               Re(ppOutput, iy) = Re(ppLastFilterOutputs, iL);
               Im(ppOutput, iy) = Im(ppLastFilterOutputs, iL);
           }
       }
       
       /* Generate *new* polyphase filter outputs. */
       ppOutStartIdx = numPrevOutputs;
       numNewOutputs = numSamples - numPrevOutputs;
        
       mimopolyphasefilter(
           ppOutput,
           ppOutStartIdx,
           numNewOutputs,
           yd,
           fgNumSamples,
           NSpp,  /* Number of samples *allocated* to ppOutput */
           NC,
           NP,
           NL,
           ppInterpFactor,
           ppSubfilterLength,
           ppFilterBank,
           ppFilterInputState,
           ppFilterPhase,
           ppLastFilterOutputs,
           fgImpulseResponse,
           fgLengthIR,
           fgState,
           fgWGNState,
           fgLastOutputs,
           fgSQRTCorrMatrix,
           fgSQRTisEye,
           fgY,
           fgWGN,
           fgWGN2,
           fgImpulseResponseIsReal,
           fgImpulseResponseIsVector,
           legacyMode);
       
       /* Linear interpolation of polyphase filter outputs. */
       for (m=0; m<NC; m++) {
           mimolinearinterpolation(y, ppOutput, m, Nout, NSpp, KI, startIdx, endIdx);
       }
       
       /* Starting interpolation index for the next block. */
       *liLinearInterpIndex = endIdx%KI + 1;
   }
}

/* [EOF] */
