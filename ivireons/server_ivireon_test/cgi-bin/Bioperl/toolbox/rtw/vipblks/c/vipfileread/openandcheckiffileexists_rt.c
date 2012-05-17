/*
* OPENANDCHECKIFFILEEXISTS_RT runtime function for VIPBLKS Read Binary File block
*
*  Copyright 1995-2007 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:47:50 $
*/
#include "vipfileread_rt.h"
#include <stdio.h>

EXPORT_FCN boolean_T MWVIP_OpenAndCheckIfFileExists(void *fptrDW, 
											   const char *FileName)
{
    FILE **fptr = (FILE **) fptrDW;
	fptr[0] = (FILE *)fopen(FileName, "rb");
	return (fptr[0] == NULL);
}

/* [EOF] openandcheckiffileexists_rt.c */
