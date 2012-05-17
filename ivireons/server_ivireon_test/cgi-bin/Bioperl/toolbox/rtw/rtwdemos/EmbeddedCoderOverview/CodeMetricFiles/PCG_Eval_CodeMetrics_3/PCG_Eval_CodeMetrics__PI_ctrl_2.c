/* Copyright 2007 The MathWorks, Inc. */
/*
 * File: PCG_Eval_CodeMetrics__PI_ctrl_2.c
 *
 * Real-Time Workshop code generated for Simulink model PCG_Eval_CodeMetrics_3.
 *
 * Model version                        : 1.234
 * Real-Time Workshop file version      : 6.6  (R2007b)  27-Jan-2007
 * Real-Time Workshop file generated on : Thu Feb 01 13:27:22 2007
 * TLC version                          : 6.6 (Jan 27 2007)
 * C source code generated on           : Thu Feb 01 13:27:22 2007
 */

#include "PCG_Eval_CodeMetrics__PI_ctrl_2.h"

/* Include model header file for global data */
#include "PCG_Eval_CodeMetrics_3.h"
#include "PCG_Eval_CodeMetrics_3_private.h"

/* Output and update for function-call system: '<Root>/PI_ctrl_2' */
void PCG_Eval_CodeMetrics__PI_ctrl_2(void)
{
  /* local block i/o variables */
  real32_T rtb_Sum2_b;

  /* Sum: '<S4>/Sum2' incorporates:
   *  Inport: '<Root>/fbk_2'
   *  Inport: '<Root>/pos_rqst'
   */
  rtb_Sum2_b = (*pos_rqst) - fbk_2;

  /* DiscreteIntegrator: '<S4>/Discrete_Time_Integrator1' incorporates:
   *  Gain: '<S4>/Int Gain1'
   *  Lookup: '<S4>/Integral  Gain Shape'
   *  Product: '<S4>/Product3'
   */
  PCG_Eval_CodeMetrics_3_B.Discrete_Time_Integrator1 = I_Gain_2 * rt_Lookup32
    (&(I_InErrMap[0]), 9, rtb_Sum2_b, &(I_OutMap[0])) * rtb_Sum2_b *
    1.000000047E-003F +
    PCG_Eval_CodeMetrics_3_DWork.Discrete_Time_Integrator1_DST_h;

  /* Sum: '<S4>/Sum3' incorporates:
   *  Gain: '<S4>/Prop Gain1'
   *  Lookup: '<S4>/Proportional  Gain Shape'
   *  Product: '<S4>/Product2'
   */
  rtb_Sum2_b = P_Gain_2 * rt_Lookup32(&(P_InErrMap[0]), 7, rtb_Sum2_b,
    &(P_OutMap[0])) * rtb_Sum2_b +
    PCG_Eval_CodeMetrics_3_B.Discrete_Time_Integrator1;

  /* Saturate: '<S4>/Saturation1' */
  pos_cmd_two = rt_SATURATE(rtb_Sum2_b, -1.0F, 1.0F);

  /* Update for DiscreteIntegrator: '<S4>/Discrete_Time_Integrator1' */
  PCG_Eval_CodeMetrics_3_DWork.Discrete_Time_Integrator1_DST_h =
    PCG_Eval_CodeMetrics_3_B.Discrete_Time_Integrator1;
}

/* File trailer for Real-Time Workshop generated code.
 *
 * [EOF]
 */
