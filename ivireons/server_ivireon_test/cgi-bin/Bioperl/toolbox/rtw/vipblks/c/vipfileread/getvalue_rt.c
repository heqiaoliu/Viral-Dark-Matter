/*
* GETVALUE_RT runtime function for VIPBLKS Read Binary File block
*
*  Copyright 1995-2007 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:47:41 $
*/
#include "vipfileread_rt.h"
#include <stdio.h>

/* This function and those below are */
/* not used until we support non-multiple of 8 bits */

EXPORT_FCN void MWVIP_getValue(void *fptrDW, void **tmpOutPtrs, int32_T *bitspe, int_T c, 
			  byte_T currentChar, int32_T leftoverBits)
{
	byte_T **tmpOutptrs = (byte_T **)tmpOutPtrs;
    int_T numbits = bitspe[c];
    uint32_T value;
    int_T cnt = 0;
    if (numbits < 8) {
        *(tmpOutptrs[c]) = MWVIP_getValuelessthan8bits(fptrDW, bitspe[c], currentChar, leftoverBits);
        return;
    }
    while (numbits >= 8) {
        value = MWVIP_getValuelessthan8bits(fptrDW, 8, currentChar, leftoverBits);
        *(tmpOutptrs[c]) |= (value << cnt);
        cnt += 8;
        numbits -= 8;
    }
    if (numbits > 0) {
        value = MWVIP_getValuelessthan8bits(fptrDW, numbits, currentChar, leftoverBits);
        *(tmpOutptrs[c]) |= (value <<= cnt);
    }
}

/* [EOF] getvaluelessthan8bits_rt.c */
