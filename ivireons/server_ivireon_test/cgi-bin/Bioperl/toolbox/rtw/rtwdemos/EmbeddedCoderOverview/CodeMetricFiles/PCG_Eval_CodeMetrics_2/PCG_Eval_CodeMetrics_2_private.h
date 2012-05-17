/* Copyright 2007 The MathWorks, Inc. */
/*
 * File: PCG_Eval_CodeMetrics_2_private.h
 *
 * Real-Time Workshop code generated for Simulink model PCG_Eval_CodeMetrics_2.
 *
 * Model version                        : 1.229
 * Real-Time Workshop file version      : 6.6  (R2007b)  27-Jan-2007
 * Real-Time Workshop file generated on : Thu Feb 01 11:58:53 2007
 * TLC version                          : 6.6 (Jan 27 2007)
 * C source code generated on           : Thu Feb 01 11:58:53 2007
 */

#ifndef _RTW_HEADER_PCG_Eval_CodeMetrics_2_private_h_
#define _RTW_HEADER_PCG_Eval_CodeMetrics_2_private_h_
#include "rtwtypes.h"
#  include "rtlibsrc.h"
#define CALL_EVENT                     (MAX_uint8_T)
#ifndef __RTWTYPES_H__
#error This file requires rtwtypes.h to be included
#else
#ifdef TMWTYPES_PREVIOUSLY_INCLUDED
#error This file requires rtwtypes.h to be included before tmwtypes.h
#else

/* Check for inclusion of an incorrect version of rtwtypes.h */
#ifndef RTWTYPES_ID_C08S16I32L32N32F1
#error This code was generated with a different "rtwtypes.h" than the file included
#endif                                 /* RTWTYPES_ID_C08S16I32L32N32F1 */
#endif                                 /* TMWTYPES_PREVIOUSLY_INCLUDED */
#endif                                 /* __RTWTYPES_H__ */

/* Imported (extern) block signals */
extern real32_T fbk_1;                 /* '<Root>/fbk_1' */
extern real32_T fbk_2;                 /* '<Root>/fbk_2' */

/* Imported (extern) pointer block signals */
extern real32_T *pos_rqst;             /* '<Root>/pos_rqst' */
void PC_Pos_Command_Arbitration_Init(void);
void PCG_Eva_Pos_Command_Arbitration(real32_T rtu_pos_cmd_one, const
  ThrottleParams *rtu_Throt_Param, real32_T rtu_pos_cmd_two);

#endif                                 /* _RTW_HEADER_PCG_Eval_CodeMetrics_2_private_h_ */

/* File trailer for Real-Time Workshop generated code.
 *
 * [EOF]
 */
