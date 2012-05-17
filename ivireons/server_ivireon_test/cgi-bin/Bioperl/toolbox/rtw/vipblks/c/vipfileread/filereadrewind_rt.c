/*
* FILEREADREWIND_RT runtime function for VIPBLKS Read Binary File block
*
*  Copyright 1995-2007 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:47:36 $
*/
#include "vipfileread_rt.h"
#include <stdio.h>

EXPORT_FCN void MWVIP_FileReadRewind(void *fptrDW)
{
    FILE **fptr = (FILE **) fptrDW;
	if (fptr[0] != NULL)
       rewind(fptr[0]);
}

/* [EOF] filereadrewind_rt.c */
