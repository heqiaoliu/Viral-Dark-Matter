/* Copyright 2007 The MathWorks, Inc. */
/*
 * File: PI_Cntrl_Reusable.c
 *
 * Real-Time Workshop code generated for Simulink model PCG_Eval_File_4.
 *
 * Model version                        : 1.222
 * Real-Time Workshop file version      : 6.6  (R2007a Prerelease)  08-Jan-2007
 * Real-Time Workshop file generated on : Thu Jan 18 11:17:54 2007
 * TLC version                          : 6.6 (Jan  9 2007)
 * C source code generated on           : Thu Jan 18 11:17:55 2007
 */

#include "PI_Cntrl_Reusable.h"

/* Include model header file for global data */
#include "PCG_Eval_File_1.h"
#include "PCG_Eval_File_1_private.h"

/* Output and update for function-call system:
 *   '<Root>/PI_ctrl_1'
 *   '<Root>/PI_ctrl_2'
 */
void PI_Cntrl_Reusable(real_T rtu_0, real_T rtu_1, rtB_PI_Cntrl_Reusable *localB,
  rtDW_PI_Cntrl_Reusable *localDW, real_T rtp_Masked_I_Gain, real_T
  rtp_Masked_P_Gain)
{
  /* local block i/o variables */
  real_T rtb_Sum2;

  /* Sum: '<S3>/Sum2' incorporates:
   *  Inport: '<Root>/fbk_1'
   *  Inport: '<Root>/pos_rqst'
   */
  rtb_Sum2 = rtu_0 - rtu_1;

  /* DiscreteIntegrator: '<S3>/Discrete_Time_Integrator1' incorporates:
   *  Gain: '<S3>/Int Gain1'
   *  Lookup: '<S3>/Integral  Gain Shape'
   *  Product: '<S3>/Product3'
   */
  localB->Discrete_Time_Integrator1 = rtp_Masked_I_Gain * rt_Lookup(&(I_InErrMap
    [0]), 9, rtb_Sum2, &(I_OutMap[0])) * rtb_Sum2 * 0.001 +
    localDW->Discrete_Time_Integrator1_DSTAT;

  /* Sum: '<S3>/Sum3' incorporates:
   *  Gain: '<S3>/Prop Gain1'
   *  Lookup: '<S3>/Proportional  Gain Shape'
   *  Product: '<S3>/Product2'
   */
  rtb_Sum2 = rtp_Masked_P_Gain * rt_Lookup(&(P_InErrMap[0]), 7, rtb_Sum2,
    &(P_OutMap[0])) * rtb_Sum2 + localB->Discrete_Time_Integrator1;

  /* Saturate: '<S3>/Saturation1' */
  localB->Saturation1 = rt_SATURATE(rtb_Sum2, -1.0, 1.0);

  /* Update for DiscreteIntegrator: '<S3>/Discrete_Time_Integrator1' */
  localDW->Discrete_Time_Integrator1_DSTAT = localB->Discrete_Time_Integrator1;
}

/* File trailer for Real-Time Workshop generated code.
 *
 * [EOF]
 */
