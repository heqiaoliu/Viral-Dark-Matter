/*
*  Y41P_WRITELINE_RT runtime function for VIPBLKS Write Binary File block
*
*  Copyright 1995-2007 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:48:28 $
*/
#include "vipfilewrite_rt.h"
#include <stdio.h>

EXPORT_FCN void MWVIP_Y41P_WriteLine(void *fptrDW,
							 const byte_T *portAddr0,
							 const byte_T *portAddr1,
							 const byte_T *portAddr2,
							 int_T rows, 
							 int_T cols)
{
    int_T j;
    FILE **fptr = (FILE **) fptrDW;

	int_T rowsj2 = 0;
	int_T rowsj8 = 0;
	int_T rows2 = 2*rows;
	int_T rows3 = 3*rows;
	int_T rows4 = 4*rows;
	int_T rows5 = 5*rows;
	int_T rows6 = 6*rows;
	int_T rows7 = 7*rows;
	int_T rows8 = 8*rows;

    for (j=0; j < cols; j++) {
        fwrite(&portAddr1[rowsj2], 1, 1, fptr[0]);
        fwrite(&portAddr0[rowsj8], 1, 1, fptr[0]);
        fwrite(&portAddr2[rowsj2], 1, 1, fptr[0]);
        fwrite(&portAddr0[rowsj8]+rows, 1, 1, fptr[0]);
        fwrite(&portAddr1[rowsj2]+rows, 1, 1, fptr[0]);
        fwrite(&portAddr0[rowsj8+rows2], 1, 1, fptr[0]);
        fwrite(&portAddr2[rowsj2+rows], 1, 1, fptr[0]);
        fwrite(&portAddr0[rowsj8+rows3], 1, 1, fptr[0]);
        fwrite(&portAddr0[rowsj8+rows4], 1, 1, fptr[0]);
        fwrite(&portAddr0[rowsj8+rows5], 1, 1, fptr[0]);
        fwrite(&portAddr0[rowsj8+rows6], 1, 1, fptr[0]);
        fwrite(&portAddr0[rowsj8+rows7], 1, 1, fptr[0]);
		rowsj2 += rows2;
		rowsj8 += rows8;
    }
}

/* [EOF] y41p_writeline_rt.c */
