/* Copyright 2007 The MathWorks, Inc. */
/* Define imported data */
#include "rtwtypes.h"
real32_T fbk_1;
real32_T fbk_2;
real32_T dummy_pos_value = 10.0;
real32_T *pos_rqst;
void defineImportData(void)
{
	pos_rqst = &dummy_pos_value;
}	

