/*
 *  randsrcinitstate_gc_32_rt.c
 *  DSP Random Source Run-Time Library Helper Function
 *
 *  Copyright 1995-2005 The MathWorks, Inc.
 *  $Revision: 1.1.2.5 $ $Date: 2008/11/18 01:45:03 $
 */

#if (!defined(INTEGER_CODE) || !INTEGER_CODE)


#include "dsprandsrc32bit_rt.h"
#include <math.h>

/* Assumed lengths:
 *  seed:   nChans
 *  state:  35*nChans
 */

NONINLINED_EXPORT_FCN void MWDSP_RandSrcInitState_GC_32(const uint32_T *seed,  /* seed value vector */
                                                        real32_T       *state, /* state vectors */
                                                        int_T          nChans) /* number channels */
{
    MWDSP_RandSrcInitState_U_32(seed, state, nChans);
}

#endif /* !INTEGER_CODE */

/* [EOF] randsrcinitstate_gc_32_rt.c */
