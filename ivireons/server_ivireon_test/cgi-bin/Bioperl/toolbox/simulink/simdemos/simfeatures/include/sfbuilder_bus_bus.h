/* Copyright 2008-2009 The MathWorks, Inc. */
/* Generated by S-function Builder */
#ifndef _SFBUILDER_BUS_BUS_H_
#define _SFBUILDER_BUS_BUS_H_
/* Read only - STARTS */
#include "tmwtypes.h"



typedef struct {
  int32_T upper_saturation_limit;
  int32_T lower_saturation_limit;
} SFB_LIMITBUS;


typedef struct {
  int32_T input;
} SFB_SIGNALBUS;


typedef struct {
  SFB_SIGNALBUS inputsignal;
  SFB_LIMITBUS limits;
} SFB_COUNTERBUS;


/* Read only - ENDS */


#endif