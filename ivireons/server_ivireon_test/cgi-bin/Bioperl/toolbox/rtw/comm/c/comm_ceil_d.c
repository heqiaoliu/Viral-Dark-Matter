/* 
 *  comm_ceil_d.c
 *
 * Double precision CEIL
 *  (to get rid of __imp__ceil function call in comm_sim_rt.lib)
 *  
 *  Copyright 2007 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $ $Date: 2009/03/09 19:25:09 $ 
 */

#include <math.h>
#include "comm_ceil_d.h"

int commCeil_D(double x) {
    return (int)ceil(x);
}
