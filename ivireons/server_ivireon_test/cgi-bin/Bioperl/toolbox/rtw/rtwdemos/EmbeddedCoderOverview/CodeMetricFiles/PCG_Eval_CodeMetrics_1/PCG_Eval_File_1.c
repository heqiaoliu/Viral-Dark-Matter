/* Copyright 2007 The MathWorks, Inc. */
/*
 * File: PCG_Eval_File_4.c
 *
 * Real-Time Workshop code generated for Simulink model PCG_Eval_File_4.
 *
 * Model version                        : 1.222
 * Real-Time Workshop file version      : 6.6  (R2007a Prerelease)  08-Jan-2007
 * Real-Time Workshop file generated on : Thu Jan 18 11:17:54 2007
 * TLC version                          : 6.6 (Jan  9 2007)
 * C source code generated on           : Thu Jan 18 11:17:55 2007
 */

#include "PCG_Eval_File_1.h"
#include "PCG_Eval_File_1_private.h"

/* Exported block signals */
extern real_T pos_cmd_one;                    /* '<Root>/Signal Conversion' */
extern real_T pos_cmd_two;                    /* '<Root>/Signal Conversion1' */
ThrottleCommands ThrotComm;            /* '<Root>/Pos_Command_Arbitration' */
ThrottleParams Throt_Param;            /* '<S1>/Bus Creator' */

/* Initial conditions for function-call system: '<Root>/Pos_Command_Arbitration' */
void PC_Pos_Command_Arbitration_Init(void)
{
  /* Initialize code for chart: '<Root>/Pos_Command_Arbitration' */
  {
    int32_T sf_i0;
    for (sf_i0 = 0; sf_i0 < 2; sf_i0++) {
      ThrotComm.pos_cmd_raw[sf_i0] = 0.0;
    }

    ThrotComm.pos_cmd_act = 0.0;
    ThrotComm.pos_failure_mode = 0.0;
    ThrotComm.err_cnt = 0.0;
  }
}

/* Output and update for function-call system: '<Root>/Pos_Command_Arbitration' */
void PCG_Eva_Pos_Command_Arbitration(real_T rtu_pos_cmd_one, const
  ThrottleParams *rtu_Throt_Param, real_T rtu_pos_cmd_two)
{
  /* Stateflow: '<Root>/Pos_Command_Arbitration' */
  ThrotComm.pos_cmd_raw[0] = rtu_pos_cmd_one;
  ThrotComm.pos_cmd_raw[1] = rtu_pos_cmd_two;
  if (fabs(rtu_pos_cmd_one - rtu_pos_cmd_two) > (*rtu_Throt_Param).max_diff) {
    ThrotComm.pos_failure_mode = 1.0;
    ThrotComm.err_cnt = 0.0;
    ThrotComm.pos_cmd_act = (*rtu_Throt_Param).fail_safe_pos;
  } else {
    if (ThrotComm.err_cnt >= (*rtu_Throt_Param).error_reset) {
      ThrotComm.pos_failure_mode = 0.0;
      ThrotComm.err_cnt = 0.0;
    }

    if (ThrotComm.pos_failure_mode > 0.0) {
      ThrotComm.err_cnt = ThrotComm.err_cnt + 1.0;
    } else if (fabs(rtu_pos_cmd_one - ThrotComm.pos_cmd_act) < fabs
               (rtu_pos_cmd_two - ThrotComm.pos_cmd_act)) {
      ThrotComm.pos_cmd_act = rtu_pos_cmd_one;
    } else {
      ThrotComm.pos_cmd_act = rtu_pos_cmd_two;
    }
  }
}


