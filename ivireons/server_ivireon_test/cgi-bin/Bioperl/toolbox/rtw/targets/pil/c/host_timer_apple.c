/* Copyright 2009 The MathWorks, Inc. */
#define __APPLE__

#include "sys/types.h"
#include "sys/times.h"
#include "host_timer.h"

int64_T cputime_stamp(void)
{
    /* For 32-bit applications that want to use 64-bit instructions, 
     * one may use gcc -fast -mpowerpc64 -c <filename>.c
     */
        
    static double scale = 0.0;
    if (0.0 == scale) {
        mach_timebase_info_data_t info;
        mach_timebase_info(&info);
        scale = info.numer / info.denom;
    }
    return (int64_T)(mach_absolute_time() * scale);
}

