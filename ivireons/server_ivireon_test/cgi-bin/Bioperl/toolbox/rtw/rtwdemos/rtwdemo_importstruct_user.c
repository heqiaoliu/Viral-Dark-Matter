/* rtwdemo_importstruct_user.c */

/* $Revision: 1.1.6.1 $ */
/* Copyright 2006 The MathWorks, Inc. */

/* This source file defines two data structures that can be accessed via
 * pointer in code generated from Simulink. One of these structures,
 * called the ReferenceStruct, is located in const memory. The other,
 * called WorkingStruct, is located in volatile memory and is intended
 * to be changed during runtime by an external calibration tool. The
 * extern declaration for the const volatile StructPointer is included
 * in the corresponding header file.
 *
 * It also contains functions that can be used to initialize the working
 * structure and switch between the two parameter structures.
 * 
 * CAUTION!
 * When using a multitasking model or operating system, switching to a
 * different dataset must be done by the lowest-priority task (e.g.
 * background task) to ensure that data is not changed in the middle of
 * model calculation.
 */

#include "rtwdemo_importstruct_user.h"

/* Constant default data struct: ReferenceStruct */
const DataStruct_type ReferenceStruct = 
{
  11,   /* OFFSET */
  2     /* GAIN */
};

/* Volatile data struct: WorkingStruct */ 
volatile DataStruct_type WorkingStruct;

/* Create pointer to the default data struct, e.g. ReferenceStruct */
const volatile DataStruct_type *StructPointer = &ReferenceStruct;

/* Function to initialize WorkingStruct with data from ReferenceStruct */
void Init_WorkingStruct(void)
{
      memcpy((void*)&WorkingStruct, &ReferenceStruct, sizeof(ReferenceStruct));
}

/* Function to switch between structures */
void SwitchStructPointer(Dataset_T Dataset)
{
    switch (Dataset)
    {
        case Working:
          StructPointer = &WorkingStruct;
          break;
        default:
          StructPointer = &ReferenceStruct;
    }
}

/* EOF */
