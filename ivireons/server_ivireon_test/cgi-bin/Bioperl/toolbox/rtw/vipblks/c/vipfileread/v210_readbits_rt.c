/*
*  V210_READBITS_RT runtime function for VIPBLKS Read Binary File block
*
*  Copyright 1995-2007 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:47:55 $
*/
#include "vipfileread_rt.h"
#include <stdio.h>

/* Read 3 10 bit samples from 4 bytes. */
EXPORT_FCN void MWVIP_V210_ReadBits(void *fptrDW, 
									uint16_T *p0, 
									uint16_T *p1, 
									uint16_T *p2)
{
	FILE **fptr = (FILE **) fptrDW;
    uint8_T char1, char2, char3, char4;

    fread(&char1, 1, 1, fptr[0]);
    fread(&char2, 1, 1, fptr[0]);
    fread(&char3, 1, 1, fptr[0]);
    fread(&char4, 1, 1, fptr[0]);
    *(p0) = char2 & 0x03;
    *(p0) <<= 8;
    *(p0) |= char1;
    *(p1) = char3 & 0x0F;
    *(p1) <<= 6;
    *(p1) |= (char2 >> 2);
    *(p2) = char4;
    *(p2) <<= 4;
    *(p2) |= (char3 >> 4);
}

/* [EOF] v210_readbits_rt.c */
