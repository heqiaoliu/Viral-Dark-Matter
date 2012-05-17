/*
*  WRITEFCLOSE_RT runtime function for VIPBLKS Write Binary File block
*
*  Copyright 1995-2007 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:48:27 $
*/
#include "vipfilewrite_rt.h"
#include <stdio.h>

EXPORT_FCN void MWVIP_WriteFclose(void *fptrDW)
{
    FILE **fptr = (FILE **) fptrDW;
    fclose(fptr[0]);
}
/* [EOF] writefclose_rt.c */
