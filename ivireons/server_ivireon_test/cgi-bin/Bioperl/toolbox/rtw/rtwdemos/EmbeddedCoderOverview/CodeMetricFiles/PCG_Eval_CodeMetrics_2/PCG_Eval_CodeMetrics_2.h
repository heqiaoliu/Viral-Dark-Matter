/* Copyright 2007 The MathWorks, Inc. */
/*
 * File: PCG_Eval_CodeMetrics_2.h
 *
 * Real-Time Workshop code generated for Simulink model PCG_Eval_CodeMetrics_2.
 *
 * Model version                        : 1.229
 * Real-Time Workshop file version      : 6.6  (R2007b)  27-Jan-2007
 * Real-Time Workshop file generated on : Thu Feb 01 11:58:53 2007
 * TLC version                          : 6.6 (Jan 27 2007)
 * C source code generated on           : Thu Feb 01 11:58:53 2007
 */

#ifndef _RTW_HEADER_PCG_Eval_CodeMetrics_2_h_
#define _RTW_HEADER_PCG_Eval_CodeMetrics_2_h_
#ifndef _PCG_Eval_CodeMetrics_2_COMMON_INCLUDES_
# define _PCG_Eval_CodeMetrics_2_COMMON_INCLUDES_
#include <stdlib.h>
#include <math.h>
#include <stddef.h>
#include "rtwtypes.h"
#include "rtlibsrc.h"
#endif                                 /* _PCG_Eval_CodeMetrics_2_COMMON_INCLUDES_ */

#include "PCG_Eval_CodeMetrics_2_types.h"

/* Child system includes */
#include "PCG_Eval_Cod_Define_Throt_Param.h"
#include "PI_Cntrl_Reusable.h"

/* Includes for objects with custom storage classes. */
#include "eval_data.h"

/* Macros for accessing real-time model data structure */
#ifndef rtmGetErrorStatus
# define rtmGetErrorStatus(rtm)        ((void*) 0)
#endif

#ifndef rtmSetErrorStatus
# define rtmSetErrorStatus(rtm, val)   ((void) 0)
#endif

/* user code (top of header file) */
#include "ThrottleBus.h"
#include "defineImportedData.h"

/* Block signals (auto storage) */
typedef struct {
  rtB_PI_Cntrl_Reusable PI_ctrl_2;     /* '<Root>/PI_ctrl_2' */
  rtB_PI_Cntrl_Reusable PI_ctrl_1;     /* '<Root>/PI_ctrl_1' */
} BlockIO_PCG_Eval_CodeMetrics_2;

/* Block states (auto storage) for system '<Root>' */
typedef struct {
  rtDW_PI_Cntrl_Reusable PI_ctrl_2;    /* '<Root>/PI_ctrl_2' */
  rtDW_PI_Cntrl_Reusable PI_ctrl_1;    /* '<Root>/PI_ctrl_1' */
} D_Work_PCG_Eval_CodeMetrics_2;

/*
 * Exported Global Signals
 *
 * Note: Exported global signals are block signals with an exported global
 * storage class designation.  RTW declares the memory for these signals
 * and exports their symbols.
 *
 */
extern real32_T pos_cmd_one;           /* '<Root>/Signal Conversion' */
extern real32_T pos_cmd_two;           /* '<Root>/Signal Conversion1' */
extern ThrottleCommands ThrotComm;     /* '<Root>/Pos_Command_Arbitration' */
extern ThrottleParams Throt_Param;     /* '<S1>/Bus Creator' */

/* Model entry point functions */
extern void PCG_Eval_CodeMetrics_2_initialize(void);
extern void PCG_Eval_CodeMetrics_2_step(BlockIO_PCG_Eval_CodeMetrics_2
  *PCG_Eval_CodeMetrics_2_B, D_Work_PCG_Eval_CodeMetrics_2
  *PCG_Eval_CodeMetrics_2_DWork);

/*
 * The generated code includes comments that allow you to trace directly
 * back to the appropriate location in the model.  The basic format
 * is <system>/block_name, where system is the system number (uniquely
 * assigned by Simulink) and block_name is the name of the block.
 *
 * Use the MATLAB hilite_system command to trace the generated code back
 * to the model.  For example,
 *
 * hilite_system('<S3>')    - opens system 3
 * hilite_system('<S3>/Kp') - opens and selects block Kp which resides in S3
 *
 * Here is the system hierarchy for this model
 *
 * '<Root>' : PCG_Eval_CodeMetrics_2
 * '<S1>'   : PCG_Eval_CodeMetrics_2/Define_Throt_Param
 * '<S2>'   : PCG_Eval_CodeMetrics_2/Execution_Order_Control
 * '<S3>'   : PCG_Eval_CodeMetrics_2/PI_ctrl_1
 * '<S4>'   : PCG_Eval_CodeMetrics_2/PI_ctrl_2
 * '<S5>'   : PCG_Eval_CodeMetrics_2/Pos_Command_Arbitration
 * '<S6>'   : PCG_Eval_CodeMetrics_2/Execution_Order_Control/PI_1_then_PI_2_then_Pos_Cmd_Arb
 * '<S7>'   : PCG_Eval_CodeMetrics_2/Execution_Order_Control/PI_1_then_PI_2_then_Pos_Cmd_Arb/PI_1_then_PI_2_then_Pos_Cmd_Arb
 */
#endif                                 /* _RTW_HEADER_PCG_Eval_CodeMetrics_2_h_ */

/* File trailer for Real-Time Workshop generated code.
 *
 * [EOF]
 */
