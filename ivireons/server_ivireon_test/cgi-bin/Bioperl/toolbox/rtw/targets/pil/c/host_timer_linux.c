/* Copyright 2009 The MathWorks, Inc. */
#define __LINUX__

#include "sys/types.h"
#include "sys/times.h"
#include "host_timer.h"

int64_T pentium_cyclecount(void) 
{
    int64_T count;
    __asm__ volatile ("rdtsc" : "=A" (count));
    return (count);
}

