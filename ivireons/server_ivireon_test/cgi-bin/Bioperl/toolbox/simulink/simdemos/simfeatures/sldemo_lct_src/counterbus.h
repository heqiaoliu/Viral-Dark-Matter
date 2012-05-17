/* Copyright 2005-2006 The MathWorks, Inc. */

/* $Revision: 1.1.6.1 $ */

#ifndef _COUNTER_BUS_H_
#define _COUNTER_BUS_H_

#include "tmwtypes.h"

typedef struct {
  int32_T input;
} SIGNALBUS;

typedef struct {
  int32_T upper_saturation_limit;
  int32_T lower_saturation_limit;
} LIMITBUS;

typedef struct {
  SIGNALBUS inputsignal;
  LIMITBUS limits;
} COUNTERBUS;

extern void counterbusFcn(COUNTERBUS *u1, int32_T u2, COUNTERBUS *y1, int32_T *y2);

#endif
