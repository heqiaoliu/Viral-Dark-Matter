/* Copyright 2007 The MathWorks, Inc. */
/*
 * File: Plant.h
 *
 * Real-Time Workshop code generated for Simulink model Plant.
 *
 * Model version                        : 1.51
 * Real-Time Workshop file version      : 6.6  (R2007a Prerelease)  10-Dec-2006
 * Real-Time Workshop file generated on : Fri Dec 15 11:48:47 2006
 * TLC version                          : 6.6 (Dec 10 2006)
 * C source code generated on           : Fri Dec 15 11:48:47 2006
 */
#ifndef _RTW_HEADER_Plant_h_
#define _RTW_HEADER_Plant_h_
#ifndef _Plant_COMMON_INCLUDES_
# define _Plant_COMMON_INCLUDES_
#include <math.h>
#include <stddef.h>
#include "rtwtypes.h"
#endif                                 /* _Plant_COMMON_INCLUDES_ */

#include "Plant_types.h"

/* Macros for accessing real-time model data structure */
#ifndef rtmGetErrorStatus
# define rtmGetErrorStatus(rtm)        ((rtm)->errorStatus)
#endif

#ifndef rtmSetErrorStatus
# define rtmSetErrorStatus(rtm, val)   ((rtm)->errorStatus = (val))
#endif

/* Block states (auto storage) for system '<Root>' */
typedef struct {
  real_T UnitDelay_DSTATE;             /* '<S1>/Unit Delay' */
  real_T UnitDelay1_DSTATE;            /* '<S1>/Unit Delay1' */
  real_T UnitDelay3_DSTATE;            /* '<S1>/Unit Delay3' */
  real_T UnitDelay2_DSTATE;            /* '<S1>/Unit Delay2' */
} D_Work_Plant;

/* Parameters (auto storage) */
struct Parameters_Plant {
  real_T Input_Scaling_Gain;           /* Expression: 10
                                        * '<S1>/Input_Scaling'
                                        */
  real_T Gain_Gain;                    /* Expression:  B0
                                        * '<S1>/Gain'
                                        */
  real_T UnitDelay_X0;                 /* Expression: 0
                                        * '<S1>/Unit Delay'
                                        */
  real_T Gain1_Gain;                   /* Expression: B1
                                        * '<S1>/Gain1'
                                        */
  real_T UnitDelay1_X0;                /* Expression: 0
                                        * '<S1>/Unit Delay1'
                                        */
  real_T Gain2_Gain;                   /* Expression: B2
                                        * '<S1>/Gain2'
                                        */
  real_T UnitDelay3_X0;                /* Expression: 0
                                        * '<S1>/Unit Delay3'
                                        */
  real_T Gain3_Gain;                   /* Expression: A1
                                        * '<S1>/Gain3'
                                        */
  real_T UnitDelay2_X0;                /* Expression: 0
                                        * '<S1>/Unit Delay2'
                                        */
  real_T Gain4_Gain;                   /* Expression: A2
                                        * '<S1>/Gain4'
                                        */
  real_T Output_Scaling_Gain;          /* Expression: .3183
                                        * '<S1>/Output_Scaling'
                                        */
};

/* Real-time Model Data Structure */
struct RT_MODEL_Plant {
  const char_T * volatile errorStatus;
};

/* Block parameters (auto storage) */
extern Parameters_Plant Plant_P;

/* Block states (auto storage) */
extern D_Work_Plant Plant_DWork;

/*
 * Exported Global Signals
 *
 * Note: Exported global signals are block signals with an exported global
 * storage class designation.  RTW declares the memory for these signals
 * and exports their symbols.
 *
 */
extern real_T PlantOutput;             /* '<S1>/Output_Scaling' */

/* Model entry point functions */
extern void Plant_initialize(void);
extern void Plant(void);

/* Real-time Model object */
extern RT_MODEL_Plant *Plant_M;

/*
 * The generated code includes comments that allow you to trace directly
 * back to the appropriate location in the model.  The basic format
 * is <system>/block_name, where system is the system number (uniquely
 * assigned by Simulink) and block_name is the name of the block.
 *
 * Note that this particular code originates from a subsystem build,
 * and has its own system numbers different from the parent model.
 * Refer to the system hierarchy for this subsystem below, and use the
 * MATLAB hilite_system command to trace the generated code back
 * to the parent model.  For example,
 *
 * hilite_system('PCGEvalHarness_GenForEclipse/Plant')    - opens subsystem PCGEvalHarness_GenForEclipse/Plant
 * hilite_system('PCGEvalHarness_GenForEclipse/Plant/Kp') - opens and selects block Kp
 *
 * Here is the system hierarchy for this model
 *
 * '<Root>' : PCGEvalHarness_GenForEclipse
 * '<S1>'   : PCGEvalHarness_GenForEclipse/Plant
 */
#endif                                 /* _RTW_HEADER_Plant_h_ */

/* File trailer for Real-Time Workshop generated code.
 *
 * [EOF]
 */
