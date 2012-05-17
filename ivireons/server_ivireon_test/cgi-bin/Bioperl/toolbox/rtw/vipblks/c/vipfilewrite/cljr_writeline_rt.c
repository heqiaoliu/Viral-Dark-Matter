/*
*  CLJR_WRITELINE_RT runtime function for VIPBLKS Write Binary File block
*
*  Copyright 1995-2007 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:48:04 $
*/
#include "vipfilewrite_rt.h"
#include <stdio.h>

EXPORT_FCN void MWVIP_CLJR_WriteLine(void *fptrDW,
							 const byte_T *portAddr0,
							 const byte_T *portAddr1,
							 const byte_T *portAddr2,
							 int_T rows, 
							 int_T cols)
{
    int_T j;
    FILE **fptr = (FILE **) fptrDW;
    uint8_T char1;

	int_T rowsj = 0;
	int_T rowsj4 = 0;
	int_T rows2 = 2*rows;
	int_T rows3 = 3*rows;
	int_T rows4 = 4*rows;

    for (j=0; j < cols; j++) {
        char1 = portAddr2[rowsj];
        char1 |= (portAddr1[rowsj] << 6);
        fwrite(&char1, 1, 1, fptr[0]);

        char1 = (portAddr1[rowsj] >> 2);
        char1 |= (portAddr0[rowsj4] << 4);
        fwrite(&char1, 1, 1, fptr[0]);

        char1 = (portAddr0[rowsj4] >> 4);
        char1 |= (portAddr0[rowsj4 + rows] << 1);
        char1 |=  (portAddr0[rowsj4 + rows2] << 6);
        fwrite(&char1, 1, 1, fptr[0]);

        char1 = (portAddr0[rowsj4 + rows2] >> 2);
        char1 |= (portAddr0[rowsj4 + rows3] << 3);
        fwrite(&char1, 1, 1, fptr[0]);

		rowsj  += rows;
		rowsj4 += rows4;
    }
}

/* [EOF] cljr_writeline_rt.c */
