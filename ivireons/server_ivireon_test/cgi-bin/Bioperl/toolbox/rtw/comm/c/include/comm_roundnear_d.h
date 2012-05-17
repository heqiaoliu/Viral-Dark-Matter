/* 
 *  comm_roundnear_r.h
 *
 * Double precision ROUND macro that rounds to the nearest integer
 *  (to get rid of __imp__ceil function call in comm_sim_rt.lib)
 *  
 *  Copyright 2007 The MathWorks, Inc.
 *  $Revision: 1.1.8.1 $ $Date: 2007/08/03 21:34:46 $ 
 */
#ifndef __COMM_ROUNDNEAR_D_H__
#define __COMM_ROUNDNEAR_D_H__

#ifdef __cplusplus
extern "C" {
#endif

extern int commROUNDnear_D(double x);

#ifdef __cplusplus
} // end of extern "C" scope
#endif

#endif /* __COMM_ROUNDNEAR_D_H__ */
