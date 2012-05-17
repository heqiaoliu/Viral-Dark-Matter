/* Copyright 2007 The MathWorks, Inc. */
/*
 * File: PCG_Eval_CodeMetrics__PI_ctrl_1.c
 *
 * Real-Time Workshop code generated for Simulink model PCG_Eval_CodeMetrics_3.
 *
 * Model version                        : 1.234
 * Real-Time Workshop file version      : 6.6  (R2007b)  27-Jan-2007
 * Real-Time Workshop file generated on : Thu Feb 01 13:27:22 2007
 * TLC version                          : 6.6 (Jan 27 2007)
 * C source code generated on           : Thu Feb 01 13:27:22 2007
 */

#include "PCG_Eval_CodeMetrics__PI_ctrl_1.h"

/* Include model header file for global data */
#include "PCG_Eval_CodeMetrics_3.h"
#include "PCG_Eval_CodeMetrics_3_private.h"

/* Output and update for function-call system: '<Root>/PI_ctrl_1' */
void PCG_Eval_CodeMetrics__PI_ctrl_1(void)
{
  /* local block i/o variables */
  real32_T rtb_Sum2;

  /* Sum: '<S3>/Sum2' incorporates:
   *  Inport: '<Root>/fbk_1'
   *  Inport: '<Root>/pos_rqst'
   */
  rtb_Sum2 = (*pos_rqst) - fbk_1;

  /* DiscreteIntegrator: '<S3>/Discrete_Time_Integrator1' incorporates:
   *  Gain: '<S3>/Int Gain1'
   *  Lookup: '<S3>/Integral  Gain Shape'
   *  Product: '<S3>/Product3'
   */
  PCG_Eval_CodeMetrics_3_B.Discrete_Time_Integrator1_o = I_Gain * rt_Lookup32
    (&(I_InErrMap[0]), 9, rtb_Sum2, &(I_OutMap[0])) * rtb_Sum2 *
    1.000000047E-003F +
    PCG_Eval_CodeMetrics_3_DWork.Discrete_Time_Integrator1_DSTAT;

  /* Sum: '<S3>/Sum3' incorporates:
   *  Gain: '<S3>/Prop Gain1'
   *  Lookup: '<S3>/Proportional  Gain Shape'
   *  Product: '<S3>/Product2'
   */
  rtb_Sum2 = P_Gain * rt_Lookup32(&(P_InErrMap[0]), 7, rtb_Sum2, &(P_OutMap[0]))
    * rtb_Sum2 + PCG_Eval_CodeMetrics_3_B.Discrete_Time_Integrator1_o;

  /* Saturate: '<S3>/Saturation1' */
  pos_cmd_one = rt_SATURATE(rtb_Sum2, -1.0F, 1.0F);

  /* Update for DiscreteIntegrator: '<S3>/Discrete_Time_Integrator1' */
  PCG_Eval_CodeMetrics_3_DWork.Discrete_Time_Integrator1_DSTAT =
    PCG_Eval_CodeMetrics_3_B.Discrete_Time_Integrator1_o;
}

/* File trailer for Real-Time Workshop generated code.
 *
 * [EOF]
 */
