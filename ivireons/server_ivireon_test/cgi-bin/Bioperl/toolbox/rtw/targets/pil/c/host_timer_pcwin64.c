/* Copyright 2009 The MathWorks, Inc. */
#define __WIN64__

#include "host_timer.h"

int64_T pentium_cyclecount(void)
{
    int64_T count;
    __asm__ volatile ("rdtsc" : "=A" (count));
    return (count);
}

