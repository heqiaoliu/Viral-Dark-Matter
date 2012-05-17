/*
 *  randsrccreateseeds_64_rt.c
 *  DSP Random Source Run-Time Library Helper Function
 *
 *  Copyright 1995-2005 The MathWorks, Inc.
 *  $Revision: 1.2.2.5 $ $Date: 2008/11/18 01:45:02 $
 */

#if (!defined(INTEGER_CODE) || !INTEGER_CODE)

#include "dsprandsrc64bit_rt.h"

/* Assumed lengths:
 *  seed:   nChans
 *  state:  35*nChans
 */

NONINLINED_EXPORT_FCN void MWDSP_RandSrcCreateSeeds_64(uint32_T  initSeed,
                                 uint32_T *seedArray,
                                 uint32_T  numSeeds)
{
    real64_T state[35];
    real64_T tmp;
    real64_T min = 0.0;
    real64_T max = 1.0;
    MWDSP_RandSrcInitState_U_64(&initSeed,state,1);
    while (numSeeds--) {
        MWDSP_RandSrc_U_D(&tmp,&min,1,&max,1,state,1,1);
        /* scale by 2^31 = 2147483648 */
        *seedArray++ = (uint32_T)(tmp*2147483648U);
    }
}

#endif /* !INTEGER_CODE */

/* [EOF] randsrccreateseeds_64_rt.c */
