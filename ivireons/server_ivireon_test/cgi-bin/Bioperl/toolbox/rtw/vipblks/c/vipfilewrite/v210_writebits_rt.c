/*
*  V210_WRITEBITS_RT runtime function for VIPBLKS Write Binary File block
*
*  Copyright 1995-2007 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:48:24 $
*/
#include "vipfilewrite_rt.h"
#include <stdio.h>

/* Write 3 10 bit samples into 4 bytes. */
EXPORT_FCN void MWVIP_V210_WriteBits(void *fptrDW, const uint16_T *p0, const uint16_T *p1, const uint16_T *p2)
{
	FILE **fptr = (FILE **) fptrDW;
    uint8_T char1;

    char1 = *p0 & 0xFF;
    fwrite(&char1, 1, 1, fptr[0]);

    char1 = *p0 >> 8;
    char1 |= (*p1 & 0x3F) << 2;
    fwrite(&char1, 1, 1, fptr[0]);

    char1 = *p1 >> 6;
    char1 |= (*p2 & 0x0F) << 4;
    fwrite(&char1, 1, 1, fptr[0]);

    char1 = *p2 >> 4;
    fwrite(&char1, 1, 1, fptr[0]);
}

/* [EOF] v210_writebits_rt.c */
