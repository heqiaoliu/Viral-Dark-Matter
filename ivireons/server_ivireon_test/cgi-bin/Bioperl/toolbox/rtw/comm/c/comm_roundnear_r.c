/* 
 *  comm_roundnear_r.h
 *
 * Single precision ROUND macro that rounds to the nearest integer
 *  (to get rid of __imp__ceil function call in comm_sim_rt.lib)
 *  
 *  Copyright 2007 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $ $Date: 2009/03/09 19:25:12 $ 
 */
#ifndef MW_COMMSTOOLBOX
#include "dsp_rt.h"
#endif
#include "comm_roundnear_r.h"

int commROUNDnear_R(float x) {
    return (int)((x < 0.0F) ? ceilf(x-0.5F) : floorf(x+0.5F));
}
