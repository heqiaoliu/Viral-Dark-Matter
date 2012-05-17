/* Copyright 2007 The MathWorks, Inc. */
/* Define structures */
#ifndef __throttlebus
#define __throttlebus


typedef struct  
{
    float pos_cmd_raw[2];
    float pos_cmd_act;
    float pos_failure_mode;
    float err_cnt;
} ThrottleCommands;

   
typedef struct 
{
    float fail_safe_pos;    
    float max_diff;    
    float error_reset;
} ThrottleParams;

#endif
