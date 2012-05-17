/* 
 *  commrandn.h
 *   Gaussian random source based on v5 (core C-code).
 *   Shared by MATLAB C-MEX function, SIMULINK C-MEX S-Function, and TLC.
 *
 *  Copyright 2009 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $ $Date: 2009/04/21 03:55:22 $ 
 */

#ifndef __COMMRANDN_H__
#define __COMMRANDN_H__

#include "tmwtypes.h"
#include "spc_decl.h"

#ifdef __cplusplus
extern "C" {
#endif

/* 
The following Gaussian random number generator has been adapted from the 
DSP run-time library function MWDSP_RandSrc_GZ_D.
It produces the same output as the randn function in MATLAB.
Note that state is now declared as real for compatibility with MATLAB. 
*/
SPC_DECL void commrandnv5(real64_T *outPtr,     /* output signal */ 
           int_T nRows,          /* number of rows */
           int_T nCols,          /* number of columns */
           real_T *state);        /* state vector */

#ifdef __cplusplus
} // end of extern "C" scope
#endif

#endif 

/* [EOF] */

