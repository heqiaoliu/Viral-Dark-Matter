/*
*  Y42T_WRITELINE_RT runtime function for VIPBLKS Write Binary File block
*
*  Copyright 1995-2007 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:48:30 $
*/
#include "vipfilewrite_rt.h"
#include <stdio.h>

EXPORT_FCN void MWVIP_Y42T_WriteLine(void *fptrDW,
							 const byte_T *portAddr0,
							 const byte_T *portAddr1,
							 const byte_T *portAddr2,
							 const byte_T *portAddr3,
							 int_T rows, 
							 int_T cols)
{
    int_T j;
    FILE **fptr = (FILE **) fptrDW;
	uint8_T char1;

	int_T rowsj = 0;
	int_T rowsj2 = 0;
	int_T rows2 = 2*rows;

    for (j=0; j < cols; j++) {
        fwrite(&portAddr1[rowsj], 1, 1, fptr[0]);
		char1 = (portAddr0[rowsj2] | portAddr3[rowsj2]);
        fwrite(&char1, 1, 1, fptr[0]);

		fwrite(&portAddr2[rowsj], 1, 1, fptr[0]);

        char1 = (portAddr0[rowsj2+rows] | portAddr3[rowsj2+rows]);
        fwrite(&char1, 1, 1, fptr[0]);

		rowsj  += rows;
		rowsj2 += rows2;
    }
}

/* [EOF] y42t_writeline_rt.c */
