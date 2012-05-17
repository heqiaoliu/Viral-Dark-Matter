/* Copyright 2009 The MathWorks, Inc. */
#define __WIN32__

#include "host_timer.h"

int64_T pentium_cyclecount(void) 
{
    return __rdtsc();
}

