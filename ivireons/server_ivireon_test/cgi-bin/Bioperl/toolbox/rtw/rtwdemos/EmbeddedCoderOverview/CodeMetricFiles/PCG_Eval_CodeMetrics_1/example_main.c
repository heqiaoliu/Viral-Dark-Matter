/* Copyright 2007 The MathWorks, Inc. */
#ifndef MODEL
/*
 * File: Example Main file for PCG Demo
 * Based on the auto generated ert_main.c file and the PCG_Eval_P5.c file
 *
 */
#include "PCG_Eval_File_1.h"               /* Model's header file */
#include "rtwtypes.h"                  /* MathWorks types */
#include "PCG_Eval_File_1_private.h"       /* Local data for PCG Eval */
#include "defineImportedData.h"        /* The inputs to the system */

static BlockIO_PCG_Eval_File_4 PCG_Eval_File_4_B;/* Observable signals */
static D_Work_PCG_Eval_File_4 PCG_Eval_File_4_DWork;/* Observable states */

real_T pos_cmd_one;                    /* '<Root>/Signal Conversion1' */
real_T pos_cmd_two;                    /* '<Root>/Signal Conversion2' */
extern ThrottleCommands ThrotComm;            /* '<Root>/Pos_Command_Arbitration' */
extern ThrottleParams Throt_Param;            /* '<S1>/Bus Creator' */

int simulationLoop = 0;

int_T main(void)
{
  /* Initialize model */
  PC_Pos_Command_Arbitration_Init();/* Set up the data structures for chart*/
  PCG_Eval_Fil_Define_Throt_Param(); /* SubSystem: '<Root>/Define_Throt_Param' */  
  defineImportData();               /* Defines the memory and values of inputs */
  
  do /* This is the "Schedule" loop.  
      Functions would be called based on a scheduling algorithm */
  {
    /* HARDWARE I/O */
      
  	/* Call control algorithms */
    PI_Cntrl_Reusable((*pos_rqst),fbk_1,&PCG_Eval_File_4_B.PI_ctrl_1,
                       &PCG_Eval_File_4_DWork.PI_ctrl_1,
                       I_Gain, P_Gain);
    PI_Cntrl_Reusable((*pos_rqst),fbk_2,&PCG_Eval_File_4_B.PI_ctrl_2,
                       &PCG_Eval_File_4_DWork.PI_ctrl_2,
                       I_Gain_2, P_Gain_2);
    pos_cmd_one = PCG_Eval_File_4_B.PI_ctrl_1.Saturation1;
    pos_cmd_two = PCG_Eval_File_4_B.PI_ctrl_2.Saturation1;
   
    PCG_Eva_Pos_Command_Arbitration(pos_cmd_one, &Throt_Param, pos_cmd_two);
 	
  	simulationLoop++;
  } while (simulationLoop < 2);
  return 0;
}

/* File trailer for Real-Time Workshop generated code.
 *
 * [EOF]
 */

#endif

