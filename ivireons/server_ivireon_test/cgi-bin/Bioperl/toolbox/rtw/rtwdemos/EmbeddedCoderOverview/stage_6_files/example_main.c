/* Copyright 2007 The MathWorks, Inc. */
/*
 * File: Example Main file for PCG Demo
 * Based on the auto generated ert_main.c file and the PCG_Eval_P6.c file
 *
 */
#include <stdio.h>                     /* This ert_main.c example uses printf/fflush */
#include "rtwdemo_PCG_Eval_P6.h"               /* Model's header file */
#include "rtwdemo_PCG_Eval_P6_private.h"       /* Local data for PCG Eval */
#include "Plant.h"                     /* Plant data */

 BlockIO_rtwdemo_PCG_Eval_P6 rtwdemo_PCG_Eval_P6_B;/* Observable signals */
 D_Work_rtwdemo_PCG_Eval_P6 rtwdemo_PCG_Eval_P6_DWork;/* Observable states */

real_T pos_cmd_one;                    /* '<Root>/Signal Conversion1' */
real_T pos_cmd_two;                    /* '<Root>/Signal Conversion2' */
ThrottleCommands ThrotComm;            /* '<Root>/Pos_Command_Arbitration' */
ThrottleParams Throt_Param;            /* '<S1>/Bus Creator' */

int_T simulationLoop = 0;
real_T PlantInput;              
real_T logData[2001];


extern void hardwareInputs(void); /* Function that writes that assigns the input data*/
extern void writeDataForEval(void);
/* Functions and data for the plant */

int_T main(void)
{
  
  /* Initialize model */
  rt_Pos_Command_Arbitration_Init();/* Set up the data structures for chart*/
  rtwdemo_PCG__Define_Throt_Param(); /* SubSystem: '<Root>/Define_Throt_Param' */  
  Plant_initialize();               /* Initilizes the Plant / Hardware model */  
  
  do 
  {
  	/* OS based scheduler executes calls */
  	
  	/* Transfer hardware outputs to controller variables */
  	
  	/* The hardware is provided by the plant: run it to get the data */
  	hardwareInputs(); /* Adds the noise to to the plant feedback 
  	                     and the position request function */ 
  	/* Call control algorithms */

    /* Call PI_Cnt_1 */
    PI_Cntrl_Reusable((*pos_rqst),
                       fbk_1, 
                       &rtwdemo_PCG_Eval_P6_B.PI_ctrl_1,
                       &rtwdemo_PCG_Eval_P6_DWork.PI_ctrl_1);
	/* Call PI_Cnt_2 */
	                       
    PI_Cntrl_Reusable((*pos_rqst), 
                       fbk_2, 
                       &rtwdemo_PCG_Eval_P6_B.PI_ctrl_2,
                       &rtwdemo_PCG_Eval_P6_DWork.PI_ctrl_2);

	/* SignalConversion: '<Root>/Signal Conversion1' */
    pos_cmd_one = rtwdemo_PCG_Eval_P6_B.PI_ctrl_1.Saturation1;
    /* SignalConversion: '<Root>/Signal Conversion2' */
    pos_cmd_two = rtwdemo_PCG_Eval_P6_B.PI_ctrl_2.Saturation1;
                       
	/* Call the command arbitration */                       
    rtwdemo_Pos_Command_Arbitration();
        
  	/* Transfer data from control algorithms to hardware: e.g. the plant */
    PlantInput = ThrotComm.pos_cmd_act; /* Assign the data from the structure */  	
    Plant();  	
    logData[simulationLoop] = PlantOutput;  	
  	/* Need to write out the Throttle command structure */
  	
  	simulationLoop++;
  } while (simulationLoop < 2001);
  /* The final step is to write out the data to file for
   *  comparison in the MATLAB environment */
   writeDataForEval();
  return 0;
}

