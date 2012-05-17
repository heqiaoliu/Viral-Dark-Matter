/* Copyright 2007 The MathWorks, Inc. */
/*
 * File: PI_Cntrl_Reusable.h
 *
 * Real-Time Workshop code generated for Simulink model PCG_Eval_CodeMetrics_2.
 *
 * Model version                        : 1.229
 * Real-Time Workshop file version      : 6.6  (R2007b)  27-Jan-2007
 * Real-Time Workshop file generated on : Thu Feb 01 11:58:53 2007
 * TLC version                          : 6.6 (Jan 27 2007)
 * C source code generated on           : Thu Feb 01 11:58:53 2007
 */

#ifndef _RTW_HEADER_PI_Cntrl_Reusable_h_
#define _RTW_HEADER_PI_Cntrl_Reusable_h_
#ifndef _PCG_Eval_CodeMetrics_2_COMMON_INCLUDES_
# define _PCG_Eval_CodeMetrics_2_COMMON_INCLUDES_
#include <stdlib.h>
#include <math.h>
#include <stddef.h>
#include "rtwtypes.h"
#include "rtlibsrc.h"
#endif                                 /* _PCG_Eval_CodeMetrics_2_COMMON_INCLUDES_ */

#include "PCG_Eval_CodeMetrics_2_types.h"

/* Block signals for system '<Root>/PI_ctrl_1' */
typedef struct {
  real32_T Discrete_Time_Integrator1;  /* '<S3>/Discrete_Time_Integrator1' */
  real32_T Saturation1;                /* '<S3>/Saturation1' */
} rtB_PI_Cntrl_Reusable;

/* Block states (auto storage) for system '<Root>/PI_ctrl_1' */
typedef struct {
  real32_T Discrete_Time_Integrator1_DSTAT;/* '<S3>/Discrete_Time_Integrator1' */
} rtDW_PI_Cntrl_Reusable;

extern void PI_Cntrl_Reusable(real32_T rtu_0, real32_T rtu_1,
  rtB_PI_Cntrl_Reusable *localB, rtDW_PI_Cntrl_Reusable *localDW, real32_T
  rtp_Masked_I_Gain, real32_T rtp_Masked_P_Gain);

#endif                                 /* _RTW_HEADER_PI_Cntrl_Reusable_h_ */

/* File trailer for Real-Time Workshop generated code.
 *
 * [EOF]
 */
