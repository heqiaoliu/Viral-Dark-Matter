/*
* GETVALUELESSTHAN8BITS_RT runtime function for VIPBLKS Read Binary File block
*
*  Copyright 1995-2007 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:47:42 $
*/
#include "vipfileread_rt.h"
#include <stdio.h>

/* This function and those below are */
/* not used until we support non-multiple of 8 bits */
EXPORT_FCN uint8_T MWVIP_getValuelessthan8bits(void *fptrDW, int_T numbits, 
							  byte_T currentChar, int32_T leftoverBits)
{
    uint8_T value;
    if (numbits <= leftoverBits) {
        value = (currentChar << (8-numbits)) >> (8-numbits);
        currentChar >>= numbits;
        leftoverBits -= numbits;
    } else {
		FILE **fptr = (FILE **) fptrDW;
        uint8_T temp;
        int_T bitsneeded;
        value = currentChar;
        fread(&(currentChar), 1, 1, fptr[0]);
        temp = currentChar;
        bitsneeded = numbits - leftoverBits;
        temp = (temp << (8-bitsneeded)) >> (8-(bitsneeded+leftoverBits));
        value |= temp;
        currentChar >>= bitsneeded;
        leftoverBits = 8 - bitsneeded;
    }
    return value;
}

/* [EOF] getvaluelessthan8bits_rt.c */
