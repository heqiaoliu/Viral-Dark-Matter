/*
*  ONEINPORT_WRITELINE_CG_RT runtime function for VIPBLKS Write Binary File block
*
*  Copyright 1995-2007 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:48:19 $
*/
#include "vipfilewrite_rt.h"
#include <stdio.h>

EXPORT_FCN void MWVIP_oneInport_WriteLine_CG(void *fptrDW,
							 const void *portAddr_0,
							 int_T rows, 
							 int_T cols,
							 int_T bpe)
{
    int_T j;
    FILE **fptr = (FILE **) fptrDW;
	const byte_T *portAddr0 = (const byte_T *)portAddr_0;
	int_T rowsj = 0;

	/* This function is called only in big endian machine */
	/* For big endian machine read from lower 3 bytes */
	if (bpe==3) portAddr0++;

    for (j=0; j < cols; j++) {
        fwrite(&portAddr0[rowsj], 1, bpe, fptr[0]);
        rowsj  += rows;
    }
}

/* [EOF] oneinport_writeline_cg_rt.c */
