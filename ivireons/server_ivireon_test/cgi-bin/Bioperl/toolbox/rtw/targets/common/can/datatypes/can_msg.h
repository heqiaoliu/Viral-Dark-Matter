/*
 * File: can_msg.h
 *
 * Abstract:
 *    Definition of CAN_MESSAGE types
 *
 *
 * $Revision: 1.12.6.4 $
 * $Date: 2008/11/04 21:24:11 $
 *
 * Copyright 2001-2003 The MathWorks, Inc.
 */

#ifndef H_SIM_CAN_DATATYPES
#define H_SIM_CAN_DATATYPES

/* can_message.h is included because it has the declaration of
 * the enum CanFrameType */ 
#include "can_message.h"
#include "tmwtypes.h"

typedef struct {

   uint8_T LENGTH;

   uint8_T RTR;

   CanFrameType type;

   uint32_T ID;

   uint8_T DATA[8];

}  CAN_FRAME;

/*-------------------------------------------------------------------
 * Function initExtendedCanFrame
 *
 * Description
 *      
 *      Sets all the bits up for a default extended frame.
 * ----------------------------------------------------------------*/
void initStandardCanFrame(CAN_FRAME * cf);

/*-------------------------------------------------------------------
 * Function initStandardCanFrame
 *
 * Description
 *      
 *      Sets all the bits up for a default stand frame.
 * ----------------------------------------------------------------*/
void initExtendedCanFrame(CAN_FRAME * cf);

#endif 
