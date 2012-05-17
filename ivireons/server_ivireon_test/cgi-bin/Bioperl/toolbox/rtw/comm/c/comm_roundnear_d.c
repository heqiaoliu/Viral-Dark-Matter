/* 
 *  comm_roundnear_r.h
 *
 * Double precision ROUND macro that rounds to the nearest integer
 *  (to get rid of __imp__ceil function call in comm_sim_rt.lib)
 *  
 *  Copyright 2007 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $ $Date: 2009/03/09 19:25:11 $ 
 */

#include <math.h>
#include "comm_roundnear_d.h"

int commROUNDnear_D(double x) {
    return (int)((x < 0.0) ? ceil(x-0.5) : floor(x+0.5));
}
