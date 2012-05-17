/*
*  OPENWRITEANDCHECKIFFILEEXISTS_RT runtime function for VIPBLKS Write Binary File block
*
*  Copyright 1995-2007 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:48:21 $
*/
#include "vipfilewrite_rt.h"
#include <stdio.h>

EXPORT_FCN boolean_T MWVIP_OpenWriteAndCheckIfFileExists(void *fptrDW, const char *FileName)
{
    FILE **fptr = (FILE **) fptrDW;
	fptr[0] = (FILE *)fopen(FileName, "wb");
	return (fptr[0] == NULL);
}
/* [EOF] openwriteandcheckiffileexists_rt.c */
