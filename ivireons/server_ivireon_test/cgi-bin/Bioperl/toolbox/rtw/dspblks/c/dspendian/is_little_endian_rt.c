/*
 *  is_little_endian_rt.c
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $ $Date: 2008/11/18 01:43:52 $
 */
#include "dspendian_rt.h"

NONINLINED_EXPORT_FCN int_T isLittleEndian(void)
{
	int16_T  endck  = 1;
	int8_T  *pendck = (int8_T *)&endck;
	return(pendck[0] == (int8_T)1);
}

/* [EOF] is_little_endian_rt.c */
