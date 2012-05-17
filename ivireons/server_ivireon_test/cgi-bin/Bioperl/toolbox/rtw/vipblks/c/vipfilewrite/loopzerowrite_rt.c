/*
*  LOOPZEROWRITE_RT runtime function for VIPBLKS Write Binary File block
*
*  Copyright 1995-2007 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:48:16 $
*/
#include "vipfilewrite_rt.h"
#include <stdio.h>

EXPORT_FCN void MWVIP_loopZeroWrite(void *fptrDW, int_T cols)
{
    FILE **fptr = (FILE **) fptrDW;
	int_T j;
	const byte_T zero = 0;
    for (j=0; j < cols; j++) {
        fwrite(&zero, 1, 1, fptr[0]);
    }
}
/* [EOF] loopzerowrite_rt.c */
