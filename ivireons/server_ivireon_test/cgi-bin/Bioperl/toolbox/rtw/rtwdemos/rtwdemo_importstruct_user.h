/* rtwdemo_importstruct_user.h */

/* $Revision: 1.1.6.1 $ */
/* Copyright 2006 The MathWorks, Inc. */

/*
 * This header file contains the type definition of the parameter
 * structure to be imported via const volatile pointer.
 */

#ifndef rtwdemo_import_struct_h
#define rtwdemo_import_struct_h

#include "rtwtypes.h"

typedef enum {
    Reference=0,
    Working
} Dataset_T;

typedef struct DataStruct_tag {
  int16_T   OFFSET; /* OFFSET */
  int16_T   GAIN;   /* GAIN */
} DataStruct_type;

extern const volatile DataStruct_type *StructPointer;

extern void Init_WorkingStruct(void);
extern void SwitchPage(uint8_T PageNumber);

#endif
