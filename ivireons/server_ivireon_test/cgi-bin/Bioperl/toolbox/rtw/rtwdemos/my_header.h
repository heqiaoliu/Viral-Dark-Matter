/* Copyright 2006 The MathWorks, Inc. */

/* $Revision: 1.1.6.2 $ */
#ifndef _MY_HEADER_H
#define _MY_HEADER_H

#include "tmwtypes.h"

extern real_T my_function(real_T x);

/* Definition of custom type */
typedef struct {
	real_T a;
	int8_T b[10];
}MyStruct;

/* External declaration of a global struct variable */
extern MyStruct gMyStructVar;
extern MyStruct *gMyStructPointerVar;

#endif
