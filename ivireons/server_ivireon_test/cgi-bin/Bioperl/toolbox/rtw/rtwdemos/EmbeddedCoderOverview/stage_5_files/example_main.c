/* Copyright 2007-2008 The MathWorks, Inc. */
#ifndef MODEL
/*
 * File: Example Main file for PCG Demo
 * Based on the auto generated ert_main.c file and the rtwdemo_PCG_Eval_P5.c file
 *
 */
#include <stdio.h>                     /* This ert_main.c example uses printf/fflush */
#include "rtwdemo_PCG_Eval_P5.h"               /* Model's header file */
#include "rtwtypes.h"                  /* MathWorks types */
#include "rtwdemo_PCG_Eval_P5_private.h"       /* Local data for PCG Eval */
#include "defineImportedData.h"        /* The inputs to the system */


static BlockIO_rtwdemo_PCG_Eval_P5 rtwdemo_PCG_Eval_P5_B;/* Observable signals */
static D_Work_rtwdemo_PCG_Eval_P5 rtwdemo_PCG_Eval_P5_DWork;/* Observable states */

real_T pos_cmd_one;                    /* '<Root>/Signal Conversion1' */
real_T pos_cmd_two;                    /* '<Root>/Signal Conversion2' */
ThrottleCommands ThrotComm;            /* '<Root>/Pos_Command_Arbitration' */
ThrottleParams Throt_Param;            /* '<S1>/Bus Creator' */


int simulationLoop = 0;

int_T main(void)
{
  /* Initialize model */
  rt_Pos_Command_Arbitration_Init(); /* Set up the data structures for chart*/
  rtwdemo_PCG__Define_Throt_Param(); /* SubSystem: '<Root>/Define_Throt_Param' */  
  defineImportData();                /* Defines the memory and values of inputs */
  
  do /* This is the "Schedule" loop.  
      Functions would be called based on a scheduling algorithm */
  {
    /* HARDWARE I/O */
      
  	/* Call control algorithms */
    PI_Cntrl_Reusable((*pos_rqst),fbk_1,&rtwdemo_PCG_Eval_P5_B.PI_ctrl_1,
                       &rtwdemo_PCG_Eval_P5_DWork.PI_ctrl_1);
    PI_Cntrl_Reusable((*pos_rqst),fbk_2,&rtwdemo_PCG_Eval_P5_B.PI_ctrl_2,
                       &rtwdemo_PCG_Eval_P5_DWork.PI_ctrl_2);
    pos_cmd_one = rtwdemo_PCG_Eval_P5_B.PI_ctrl_1.Saturation1;
    pos_cmd_two = rtwdemo_PCG_Eval_P5_B.PI_ctrl_2.Saturation1;
   
    rtwdemo_Pos_Command_Arbitration(pos_cmd_one, &Throt_Param, pos_cmd_two, 
                                    &rtwdemo_PCG_Eval_P5_B.sf_Pos_Command_Arbitration);
    

 	
  	simulationLoop++;
  } while (simulationLoop < 2);
  return 0;
}

/* File trailer for Real-Time Workshop generated code.
 *
 * [EOF]
 */

#endif

