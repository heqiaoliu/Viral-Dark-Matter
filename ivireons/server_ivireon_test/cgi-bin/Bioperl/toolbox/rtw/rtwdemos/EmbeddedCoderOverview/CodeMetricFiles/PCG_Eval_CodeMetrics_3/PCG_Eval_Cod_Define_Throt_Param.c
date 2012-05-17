/* Copyright 2007 The MathWorks, Inc. */
/*
 * File: PCG_Eval_Cod_Define_Throt_Param.c
 *
 * Real-Time Workshop code generated for Simulink model PCG_Eval_CodeMetrics_3.
 *
 * Model version                        : 1.234
 * Real-Time Workshop file version      : 6.6  (R2007b)  27-Jan-2007
 * Real-Time Workshop file generated on : Thu Feb 01 13:27:22 2007
 * TLC version                          : 6.6 (Jan 27 2007)
 * C source code generated on           : Thu Feb 01 13:27:22 2007
 */

#include "PCG_Eval_Cod_Define_Throt_Param.h"

/* Include model header file for global data */
#include "PCG_Eval_CodeMetrics_3.h"
#include "PCG_Eval_CodeMetrics_3_private.h"

/* Output and update for atomic system: '<Root>/Define_Throt_Param' */
void PCG_Eval_Cod_Define_Throt_Param(void)
{
  /* BusCreator: '<S1>/Bus Creator' incorporates:
   *  Constant: '<S1>/Constant'
   *  Constant: '<S1>/Constant3'
   *  Constant: '<S1>/Constant4'
   */
  Throt_Param.fail_safe_pos = 0.1000000015F;
  Throt_Param.max_diff = 0.1000000015F;
  Throt_Param.error_reset = 10.0F;
}

/* File trailer for Real-Time Workshop generated code.
 *
 * [EOF]
 */
