/* 
 *  mimocfcore.h
 *   Channel filter - filter method (core C-code).
 *
 *  Copyright 2008 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $ $Date: 2008/10/31 06:54:18 $ 
 */

#ifndef __CFCORE_H__
#define __CFCORE_H__

#include "complexops.h"

#ifdef __cplusplus
extern "C" {
#endif

void coremimochannelfilter(
    const cArray x,              /* Input signal */
    const cArray z,              /* Complex path gains */
    cArray       y,              /* Output signal */
    int_T        NS,             /* Number of input/output samples */
    int_T        NP,             /* Number of paths */
    int_T        NG,             /* Number of channel filter gains */
	int_T		 NT,			 /* Number of Tx antennas */
	int_T		 NR,			 /* Number of Rx antennas */
    real_T      *alphaMatrix,    /* Matrix for transforming gains */
    cArray       u,              /* Input state vector */
    cArray       w);             /* Work vector */

#ifdef __cplusplus
} // end of extern "C" scope
#endif

#endif

/* [EOF] */
