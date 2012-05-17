/* 
 * File : sfun_frmad_wrapper.h
 * Abstract:
 *    External definitions of routines that implements a frame-based
 *    source.
 *
 * Copyright 1990-2009 The MathWorks, Inc.
 * $Revision: 1.1.6.1 $
 */

#ifdef __cplusplus
extern "C" {
#endif

void sfun_frmad_const_wrapper(real_T *y, 
                              int_T  frmSize, real_T ts,
                              int_T  count,
                              int_T  nAmps,   const real_T *amps,
                              real_T noisA,   real_T noiseF);

void sfun_frmad_sine_wrapper(real_T *y, 
                             int_T  frmSize, real_T ts,
                             int_T  count,
                             int_T  nAmps,   const real_T *amps,
                             int_T  nFreqs,  const real_T *freqs,
                             real_T noisA,   real_T noiseF);

#ifdef __cplusplus
}
#endif

/* [eof] sfun_frmad_wrapper.h */
