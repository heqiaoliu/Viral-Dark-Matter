/*
*  V210_READLINE_RT runtime function for VIPBLKS Read Binary File block
*
*  Copyright 1995-2007 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:47:56 $
*/
#include "vipfileread_rt.h"
#include <stdio.h>

EXPORT_FCN boolean_T MWVIP_V210_ReadLine(void *fptrDW,
							 void *portAddr_0,
							 void *portAddr_1,
							 void *portAddr_2,
							 int32_T   *numLoops,
							 boolean_T *eofflag, 
							 int_T rows, 
							 int_T cols)
{
    int_T j;
	byte_T *portAddr0 = (byte_T *)portAddr_0;
	byte_T *portAddr1 = (byte_T *)portAddr_1;
	byte_T *portAddr2 = (byte_T *)portAddr_2;
	
    FILE **fptr = (FILE **) fptrDW;

    /* ptr arithmetics take into account output size of 2 bytes */
	int_T rowsj6 = 0;
	int_T rowsj12 = 0;
	int_T rows2 = 2*rows;
	int_T rows4 = 4*rows;
	int_T rows6 = 6*rows;
	int_T rows8 = 8*rows;
	int_T rows10 = 10*rows;
	int_T rows12 = 12*rows;
	 
    for (j=0; j < cols; j++) {
        MWVIP_V210_ReadBits(fptrDW, (uint16_T *)&portAddr1[rowsj6],
                (uint16_T *)&portAddr0[rowsj12],
                (uint16_T *)&portAddr2[rowsj6]);
        MWVIP_V210_ReadBits(fptrDW, (uint16_T *)(&portAddr0[rowsj12+rows2]),
                (uint16_T *)(&portAddr1[rowsj6+rows2]),
                (uint16_T *)(&portAddr0[rowsj12+rows4]));
        MWVIP_V210_ReadBits(fptrDW, (uint16_T *)(&portAddr2[rowsj6+rows2]),
                (uint16_T *)(&portAddr0[rowsj12+rows6]),
                (uint16_T *)(&portAddr1[rowsj6+rows4]));
        MWVIP_V210_ReadBits(fptrDW, (uint16_T *)(&portAddr0[rowsj12+rows8]),
                (uint16_T *)(&portAddr2[rowsj6+rows4]),
                (uint16_T *)(&portAddr0[rowsj12+rows10]));
        if (feof(fptr[0])) {
            numLoops[0]--;
            rewind(fptr[0]);
            eofflag[0] = 1;
            return 0;
        }
		rowsj6  += rows6;
		rowsj12 += rows12;
    }
    return 1;
}

/* [EOF] v210_readline_rt.c */
