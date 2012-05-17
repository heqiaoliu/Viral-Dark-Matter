/* Copyright 2007 The MathWorks, Inc. */
/*
 * File: Plant.c
 *
 * Real-Time Workshop code generated for Simulink model Plant.
 *
 * Model version                        : 1.51
 * Real-Time Workshop file version      : 6.6  (R2007a Prerelease)  10-Dec-2006
 * Real-Time Workshop file generated on : Fri Dec 15 11:48:47 2006
 * TLC version                          : 6.6 (Dec 10 2006)
 * C source code generated on           : Fri Dec 15 11:48:47 2006
 */
#include "Plant.h"
#include "Plant_private.h"

/* Exported block signals */
real_T PlantOutput;                    /* '<S1>/Output_Scaling' */

/* Block states (auto storage) */
D_Work_Plant Plant_DWork;

/* Real-time model */
RT_MODEL_Plant Plant_M_;
RT_MODEL_Plant *Plant_M = &Plant_M_;

/* Initial conditions for exported function: Trigger */
void Trigger_Init(void)
{
  /* InitializeConditions for S-Function (fcncallgen): '<S2>/Function-Call Generator' */

  /* InitializeConditions for UnitDelay: '<S1>/Unit Delay' */
  Plant_DWork.UnitDelay_DSTATE = Plant_P.UnitDelay_X0;

  /* InitializeConditions for UnitDelay: '<S1>/Unit Delay1' */
  Plant_DWork.UnitDelay1_DSTATE = Plant_P.UnitDelay1_X0;

  /* InitializeConditions for UnitDelay: '<S1>/Unit Delay3' */
  Plant_DWork.UnitDelay3_DSTATE = Plant_P.UnitDelay3_X0;

  /* InitializeConditions for UnitDelay: '<S1>/Unit Delay2' */
  Plant_DWork.UnitDelay2_DSTATE = Plant_P.UnitDelay2_X0;
}

/* Output and update for exported function: Trigger */
void Plant(void)
{
  /* local block i/o variables */
  real_T rtb_Input_Scaling;
  real_T rtb_UnitDelay;
  real_T rtb_UnitDelay3;
  real_T rtb_Sum3;

  /* S-Function (fcncallgen): '<S2>/Function-Call Generator' incorporates:
   *  Inport: '<Root>/V_cmd'
   */

  /* Gain: '<S1>/Input_Scaling' */
  rtb_Input_Scaling = Plant_P.Input_Scaling_Gain * PlantInput;

  /* UnitDelay: '<S1>/Unit Delay' */
  rtb_UnitDelay = Plant_DWork.UnitDelay_DSTATE;

  /* UnitDelay: '<S1>/Unit Delay3' */
  rtb_UnitDelay3 = Plant_DWork.UnitDelay3_DSTATE;

  /* Sum: '<S1>/Sum3' incorporates:
   *  Gain: '<S1>/Gain'
   *  Gain: '<S1>/Gain1'
   *  Gain: '<S1>/Gain2'
   *  Gain: '<S1>/Gain3'
   *  Gain: '<S1>/Gain4'
   *  Sum: '<S1>/Sum'
   *  Sum: '<S1>/Sum1'
   *  Sum: '<S1>/Sum2'
   *  UnitDelay: '<S1>/Unit Delay'
   *  UnitDelay: '<S1>/Unit Delay1'
   *  UnitDelay: '<S1>/Unit Delay2'
   *  UnitDelay: '<S1>/Unit Delay3'
   */
  rtb_Sum3 = (((Plant_P.Gain_Gain * rtb_Input_Scaling + Plant_P.Gain1_Gain *
                Plant_DWork.UnitDelay_DSTATE) + Plant_P.Gain2_Gain *
               Plant_DWork.UnitDelay1_DSTATE) - Plant_P.Gain4_Gain *
              Plant_DWork.UnitDelay2_DSTATE) - Plant_P.Gain3_Gain *
    Plant_DWork.UnitDelay3_DSTATE;

  /* Gain: '<S1>/Output_Scaling' */
  PlantOutput = Plant_P.Output_Scaling_Gain * rtb_Sum3;

  /* Update for UnitDelay: '<S1>/Unit Delay' */
  Plant_DWork.UnitDelay_DSTATE = rtb_Input_Scaling;

  /* Update for UnitDelay: '<S1>/Unit Delay1' */
  Plant_DWork.UnitDelay1_DSTATE = rtb_UnitDelay;

  /* Update for UnitDelay: '<S1>/Unit Delay3' */
  Plant_DWork.UnitDelay3_DSTATE = rtb_Sum3;

  /* Update for UnitDelay: '<S1>/Unit Delay2' */
  Plant_DWork.UnitDelay2_DSTATE = rtb_UnitDelay3;
}

/* Model initialize function */
void Plant_initialize(void)
{

  /* block I/O */

  /* exported global signals */
  PlantOutput = 0.0;

  /* states (dwork) */
  {
    real_T *dwork_ptr = (real_T *) &Plant_DWork.UnitDelay_DSTATE;
    dwork_ptr[0] = 0.0;
    dwork_ptr[1] = 0.0;
    dwork_ptr[2] = 0.0;
    dwork_ptr[3] = 0.0;
  }

  /* InitializeConditions for S-Function (fcncallgen): '<Root>/__FcnCallGen__0' */
  Trigger_Init();
}

/* File trailer for Real-Time Workshop generated code.
 *
 * [EOF]
 */
