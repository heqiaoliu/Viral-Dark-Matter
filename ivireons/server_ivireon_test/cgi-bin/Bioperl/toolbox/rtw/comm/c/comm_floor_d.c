/* 
 *  comm_floor_d.c
 *
 * Double precision FLOOR  
 *  (to get rid of __imp__floor function call in comm_sim_rt.lib)
 *  
 *  Copyright 2007 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $ $Date: 2009/03/09 19:25:10 $ 
 */

#include <math.h>
#include "comm_floor_d.h"

int commFloor_D(double x) {
    return (int)floor(x);
}
