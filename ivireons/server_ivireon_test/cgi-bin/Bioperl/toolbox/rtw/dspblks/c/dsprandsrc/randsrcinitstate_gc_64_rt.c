/*
 *  randsrcinitstate_gc_64_rt.c
 *  DSP Random Source Run-Time Library Helper Function
 *
 *  Copyright 1995-2005 The MathWorks, Inc.
 *  $Revision: 1.1.2.5 $ $Date: 2008/11/18 01:45:04 $
 */

#if (!defined(INTEGER_CODE) || !INTEGER_CODE)

#include "dsprandsrc64bit_rt.h"
#include <math.h>

/* Assumed lengths:
 *  seed:   nChans
 *  state:  35*nChans
 */

NONINLINED_EXPORT_FCN void MWDSP_RandSrcInitState_GC_64(const uint32_T *seed,  /* seed value vector */
                                  real64_T       *state, /* state vectors */
                                  int_T          nChans) /* number channels */
{
    MWDSP_RandSrcInitState_U_64(seed, state, nChans);
}

#endif /* !INTEGER_CODE */

/* [EOF] randsrcinitstate_gc_64_rt.c */
