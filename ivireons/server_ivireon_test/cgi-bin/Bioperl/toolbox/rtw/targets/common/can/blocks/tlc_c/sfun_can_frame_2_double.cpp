/*
 * File: sfun_can_frame_2_double.cpp
 *
 * Abstract:
 *    Description of file contents and purpose.
 *
 *
 * $Revision: 1.1.10.2 $
 * $Date: 2006/12/27 21:22:09 $
 *
 * Copyright 2001-2006 The MathWorks, Inc.
 */

/*
 * You must specify the S_FUNCTION_NAME as the name of your S-function
 * (i.e. replace sfuntmpl_basic with the name of your S-function).
 */
#define S_FUNCTION_NAME sfun_can_frame_2_double
#define S_FUNCTION_LEVEL 2

#ifdef __cplusplus
extern "C" { // use the C fcn-call standard for all functions  
            // defined within this scope                     
#endif

#include "sfun_can_util.h"

enum {P_NPARMS = 0};

static boolean_T isAcceptableDataType(SimStruct * S, DTypeId dataType) {
   int_T     canExDT      = ssGetDataTypeId(S,SL_CAN_EXTENDED_FRAME_DTYPE_NAME );
   int_T     canStDT      = ssGetDataTypeId(S,SL_CAN_STANDARD_FRAME_DTYPE_NAME );
   boolean_T isAcceptable = (dataType == canExDT || dataType == canStDT );
   return isAcceptable;
}
   
/*====================*
 * S-function methods *
 *====================*/

#define MDL_SET_INPUT_PORT_DATA_TYPE
static void mdlSetInputPortDataType(SimStruct *S, int_T port, DTypeId dataType) {
   /* dynamic typing for message input port */
   if (port == 0) {
      if (isAcceptableDataType(S, dataType)) {
         /*
          * Accept proposed data type if it is std / xtd message type
          */
         ssSetInputPortDataType(S, 0, dataType);
      } 
      else {
         /* Reject proposed data type */
         ssSetErrorStatus(S,"Invalid input signal data type.");
         return;
      }
   } 
   else {
      /*
       * Should not end up here.  Simulink will only call this function
       * for existing input ports whose data types are unknown.
       */
      ssSetErrorStatus(S, "Error setting input port data type.");
      return;
   }
}

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
*    The sizes information is used by Simulink to determine the S-function
*    block's characteristics (number of inputs, outputs, states, etc.).
*/
static void mdlInitializeSizes(SimStruct *S)
{
   // loop counter
   int idx;

   ssSetNumSFcnParams(S, P_NPARMS);  /* Number of expected parameters */
   // No parameters will be tunable
   for(idx=0; idx<P_NPARMS; idx++){
      ssSetSFcnParamNotTunable(S,idx);
   }

   if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
      /* Return if number of expected != number of actual parameters */
      return;
   }

   // Setup all the CAN datatypes
   CAN_Common_MdlInitSizes(S);
   // Extended frame
   int_T canExDT = ssGetDataTypeId(S,SL_CAN_EXTENDED_FRAME_DTYPE_NAME );
   // Standard frame
   int_T canStDT = ssGetDataTypeId(S,SL_CAN_STANDARD_FRAME_DTYPE_NAME );

   // Setup input port
   ssSetNumInputPorts(S,1);
   ssSetInputPortWidth(S,0,1);
   ssSetInputPortDirectFeedThrough(S,0,true);
   ssSetInputPortDataType(S,0,DYNAMICALLY_TYPED);
   
   // Setup output ports
   ssSetNumOutputPorts(S,4);

   ssSetOutputPortWidth(S,0,1); /* ID */
   ssSetOutputPortDataType(S,0, SS_DOUBLE);
   
   
   ssSetOutputPortWidth(S,1,1); /* Length */
   ssSetOutputPortDataType(S,1, SS_DOUBLE);
 
   ssSetOutputPortWidth(S,2,1); /* Type */
   ssSetOutputPortDataType(S,2, SS_DOUBLE);

   ssSetOutputPortWidth(S,3,1); /* Data */
   ssSetOutputPortDataType(S,3, SS_DOUBLE);
   

   ssSetNumContStates(S, 0);
   ssSetNumDiscStates(S, 0);

   ssSetNumSampleTimes(S, 1);
   
   ssSetNumRWork(S, 0);
   ssSetNumIWork(S, 0);
   ssSetNumPWork(S, 0);
   ssSetNumModes(S, 0);
   ssSetNumNonsampledZCs(S, 0);

   /* use generated code in Accelerator Mode */   
   ssSetOptions(S, SS_OPTION_USE_TLC_WITH_ACCELERATOR);
}

/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    This function is used to specify the sample time(s) for your
 *    S-function. You must register the same number of sample times as
 *    specified in ssSetNumSampleTimes.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
   ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
   ssSetOffsetTime(S, 0, 0.0);
}

#undef MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START) 
/* Function: mdlStart =======================================================
 * Abstract:
 *    This function is called once at start of model execution. If you
 *    have states that should be initialized once, this is the place
 *    to do it.
 */
static void mdlStart(SimStruct *S)
{
}
#endif /*  MDL_START */


/* Function: mdlOutputs =======================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block. Generally outputs are placed in the output vector, ssGetY(S).
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
   
/*
 *typedef struct {

   uint8_T LENGTH;

   uint8_T RTR;

   CanFrameType type;

   uint32_T ID;

   uint8_T DATA[8];

}  CAN_FRAME;
 */

  /* pointer to input frame */
   CAN_FRAME * frame = ((CAN_FRAME *) (ssGetInputPortSignalPtrs(S,0)[0]));

   /* pointer to output double */
   real_T * outputData = ssGetOutputPortRealSignal(S, 0);
   real_T * outputData1 = ssGetOutputPortRealSignal(S, 1); 
   real_T * outputData2 = ssGetOutputPortRealSignal(S, 2); 
   real_T * outputData3 = ssGetOutputPortRealSignal(S, 3); 
   

   /* copy data bytes */
   *outputData=frame->ID;
   *outputData1 =frame->type; //STD or Extended
   *outputData2=frame->LENGTH;
    memcpy(outputData3,frame->DATA,8); 
   
}

/* Function: mdlTerminate =====================================================
 * Abstract:
 *    In this function, you should perform any actions that are necessary
 *    at the termination of a simulation.  For example, if memory was
 *    allocated in mdlStart, this is the place to free it.
 */
static void mdlTerminate(SimStruct *S)
{
}


/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

#ifdef __cplusplus
} // end of extern "C" scope
#endif
