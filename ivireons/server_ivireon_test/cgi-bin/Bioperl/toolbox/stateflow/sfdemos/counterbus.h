#ifndef _COUNTER_BUS_H_
#define _COUNTER_BUS_H_

#include "tmwtypes.h"

typedef struct {
  int input;
} SIGNALBUS;

typedef struct {
  int upper_saturation_limit;
  int lower_saturation_limit;
} LIMITBUS;

typedef struct {
  SIGNALBUS inputsignal;
  LIMITBUS limits;
} COUNTERBUS;

extern void counterbusFcn(COUNTERBUS *u1, int u2, COUNTERBUS *y1, int *y2);

#endif
