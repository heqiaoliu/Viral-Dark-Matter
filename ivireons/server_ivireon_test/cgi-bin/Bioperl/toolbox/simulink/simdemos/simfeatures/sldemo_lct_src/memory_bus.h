/* Copyright 2006 The MathWorks, Inc. */

/* $Revision: 1.1.6.1 $ */

#ifndef _MEMORY_BUS_H_
#define _MEMORY_BUS_H_

#include "tmwtypes.h"
#include "counterbus.h"

extern void memory_bus_init(COUNTERBUS *mem, int32_T upper_sat, int32_T lower_sat);
extern void memory_bus_step(COUNTERBUS *input, COUNTERBUS *mem, COUNTERBUS *output);

#endif
