/*
*  Y42T_READLINE_RT runtime function for VIPBLKS Read Binary File block
*
*  Copyright 1995-2007 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:47:59 $
*/
#include "vipfileread_rt.h"
#include <stdio.h>

EXPORT_FCN boolean_T MWVIP_Y42T_ReadLine(void *fptrDW,
							 uint8_T *portAddr_0,
							 uint8_T *portAddr_1,
							 uint8_T *portAddr_2,
							 uint8_T *portAddr_3,
							 int32_T   *numLoops,
							 boolean_T *eofflag, 
							 int_T rows, 
							 int_T cols)
{
    int_T j;
    FILE **fptr = (FILE **) fptrDW;
	byte_T *portAddr0 = (byte_T *)portAddr_0;
	byte_T *portAddr1 = (byte_T *)portAddr_1;
	byte_T *portAddr2 = (byte_T *)portAddr_2;
	byte_T *portAddr3 = (byte_T *)portAddr_3;

	int_T rowsj = 0;
	int_T rowsj2 = 0;
	int_T rows2 = 2*rows;

    for (j=0; j < cols; j++) {
        fread(&portAddr1[rowsj], 1, 1, fptr[0]);
        fread(&portAddr0[rowsj2], 1, 1, fptr[0]);
        fread(&portAddr2[rowsj], 1, 1, fptr[0]);
        fread(&portAddr0[rowsj2+rows], 1, 1, fptr[0]);
        portAddr3[rowsj2] = portAddr0[rowsj2] & 0x01;
        portAddr0[rowsj2] = portAddr0[rowsj2] & 0xFE;
        portAddr3[rowsj2+rows] = portAddr0[rowsj2+rows] & 0x01;
        portAddr0[rowsj2+rows] = portAddr0[rowsj2+rows] & 0xFE;
        if (feof(fptr[0])) {
            numLoops[0]--;
            rewind(fptr[0]);
            eofflag[0] = 1;
            return 0;
        }
		rowsj  += rows;
		rowsj2 += rows2;
    }
    return 1;
}

/* [EOF] y42t_readline_rt.c */
