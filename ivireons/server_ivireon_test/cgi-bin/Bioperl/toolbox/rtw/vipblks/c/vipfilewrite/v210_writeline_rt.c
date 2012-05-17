/*
*  V210_WRITELINE_RT runtime function for VIPBLKS Write Binary File block
*
*  Copyright 1995-2007 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:48:25 $
*/
#include "vipfilewrite_rt.h"
#include <stdio.h>

EXPORT_FCN void MWVIP_V210_WriteLine(void *fptrDW,
							 const void *portAddr_0,
							 const void *portAddr_1,
							 const void *portAddr_2,
							 int_T rows, 
							 int_T cols)
{
    int_T j;
	const byte_T *portAddr0 = (const byte_T *)portAddr_0;
	const byte_T *portAddr1 = (const byte_T *)portAddr_1;
	const byte_T *portAddr2 = (const byte_T *)portAddr_2;

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
        MWVIP_V210_WriteBits(fptrDW, (const uint16_T *)&portAddr1[rowsj6],
                (const uint16_T *)&portAddr0[rowsj12],
                (const uint16_T *)&portAddr2[rowsj6]);
        MWVIP_V210_WriteBits(fptrDW, (const uint16_T *)(&portAddr0[rowsj12+rows2]),
                (const uint16_T *)(&portAddr1[rowsj6+rows2]),
                (const uint16_T *)(&portAddr0[rowsj12+rows4]));
        MWVIP_V210_WriteBits(fptrDW, (const uint16_T *)(&portAddr2[rowsj6+rows2]),
                (const uint16_T *)(&portAddr0[rowsj12+rows6]),
                (const uint16_T *)(&portAddr1[rowsj6+rows4]));
        MWVIP_V210_WriteBits(fptrDW, (const uint16_T *)(&portAddr0[rowsj12+rows8]),
                (const uint16_T *)(&portAddr2[rowsj6+rows4]),
                (const uint16_T *)(&portAddr0[rowsj12+rows10]));
		rowsj6  += rows6;
		rowsj12 += rows12;
    }
}

/* [EOF] v210_writeline_rt.c */
