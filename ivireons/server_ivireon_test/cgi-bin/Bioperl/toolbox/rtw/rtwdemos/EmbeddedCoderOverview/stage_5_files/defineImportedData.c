/* Copyright 2007 The MathWorks, Inc. */
/* Define imported data */
#include "rtwtypes.h"
real_T fbk_1;
real_T fbk_2;
real_T dummy_pos_value = 10.0;
real_T *pos_rqst;
void defineImportData(void)
{
	pos_rqst = &dummy_pos_value;
}	

