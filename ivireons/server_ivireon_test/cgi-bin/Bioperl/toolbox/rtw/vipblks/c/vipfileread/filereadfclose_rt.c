/*
* FILEREADFCLOSE_RT runtime function for VIPBLKS Read Binary File block
*
*  Copyright 1995-2007 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:47:35 $
*/
#include "vipfileread_rt.h"
#include <stdio.h>

EXPORT_FCN void MWVIP_FileReadFclose(void *fptrDW)
{
    FILE **fptr = (FILE **) fptrDW;
    fclose(fptr[0]);
}

/* [EOF] filereadfclose_rt.c */
