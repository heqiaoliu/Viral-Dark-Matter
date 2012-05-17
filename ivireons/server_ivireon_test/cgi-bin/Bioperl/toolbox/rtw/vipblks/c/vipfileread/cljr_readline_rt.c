/*
*  CLJR_READLINE_RT runtime function for VIPBLKS Read Binary File block
*
*  Copyright 1995-2007 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:47:34 $
*/
#include "vipfileread_rt.h"
#include <stdio.h>

EXPORT_FCN boolean_T MWVIP_CLJR_ReadLine(void *fptrDW,
							 uint8_T *portAddr_0,
							 uint8_T *portAddr_1,
							 uint8_T *portAddr_2,
							 int32_T   *numLoops,
							 boolean_T *eofflag, 
							 int_T rows, 
							 int_T cols)
{
    int_T j;
    FILE **fptr = (FILE **) fptrDW;
    uint8_T char1, char2, char3, char4;
	byte_T *portAddr0 = (byte_T *)portAddr_0;
	byte_T *portAddr1 = (byte_T *)portAddr_1;
	byte_T *portAddr2 = (byte_T *)portAddr_2;

	int_T rowsj = 0;
	int_T rowsj4 = 0;
	int_T rows2 = 2*rows;
	int_T rows3 = 3*rows;
	int_T rows4 = 4*rows;

    for (j=0; j < cols; j++) {
        fread(&char1, 1, 1, fptr[0]);
        fread(&char2, 1, 1, fptr[0]);
        fread(&char3, 1, 1, fptr[0]);
        fread(&char4, 1, 1, fptr[0]);
        portAddr2[rowsj] = char1 & 0x3F;
        portAddr1[rowsj] = char1 >> 6;
        portAddr1[rowsj] |= (char2 & 0x0F) << 2;
        portAddr0[rowsj4] = char2 >> 4;
        portAddr0[rowsj4] |= ((char3 & 0x01) << 4);
        portAddr0[rowsj4+rows] = (char3 >> 1) & 0x1F;
        portAddr0[rowsj4+rows2] = (char3 >> 6);
        portAddr0[rowsj4+rows2] |= ((char4 & 0x07) << 2);
        portAddr0[rowsj4+rows3] = (char4 >> 3);
        if (feof(fptr[0])) {
            numLoops[0]--;
            rewind(fptr[0]);
            eofflag[0] = 1;
            return 0;
        }
		rowsj  += rows;
		rowsj4 += rows4;
    }
    return 1;
}

/* [EOF] cljr_readline_rt.c */
