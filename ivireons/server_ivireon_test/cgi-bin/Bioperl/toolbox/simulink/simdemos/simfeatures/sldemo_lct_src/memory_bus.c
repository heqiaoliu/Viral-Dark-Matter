/* Copyright 2006 The MathWorks, Inc. */

/* $Revision: 1.1.6.1 $ */

#include "memory_bus.h"
#include <string.h>

void memory_bus_init(COUNTERBUS *memory, int32_T upper_sat, int32_T lower_sat) {
    memory->inputsignal.input = 0;
    memory->limits.upper_saturation_limit = upper_sat;
    memory->limits.lower_saturation_limit = lower_sat;
}


void memory_bus_step(COUNTERBUS *input, COUNTERBUS *memory, COUNTERBUS *output) {
    memcpy(output, memory, sizeof(COUNTERBUS));
    memcpy(memory, input, sizeof(COUNTERBUS));
}
