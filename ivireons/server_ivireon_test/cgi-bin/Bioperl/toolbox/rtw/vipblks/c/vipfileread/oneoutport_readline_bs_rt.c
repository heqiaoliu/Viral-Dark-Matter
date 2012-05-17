/*
* ONEOUTPORT_READLINE_BS_RT runtime function for VIPBLKS Read Binary File block
*
*  Copyright 1995-2007 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:47:48 $
*/
#include "vipfileread_rt.h"
#include <stdio.h>

EXPORT_FCN boolean_T MWVIP_oneOutport_ReadLine_BS(void *fptrDW,
							 void *portAddr_0,
							 int32_T   *numLoops,
							 boolean_T *eofflag, 
							 int_T rows, 
							 int_T cols,
							 int_T bpe)
{
    int_T j;
	byte_T *portAddr0 = (byte_T *)portAddr_0;
    FILE **fptr = (FILE **) fptrDW;

	int_T rowsj = 0;
    for (j=0; j < cols; j++) {
        fread(&portAddr0[rowsj], 1, bpe, fptr[0]);
		
        MWVIP_byteSwapN(bpe, &portAddr0[rowsj]);
        if (feof(fptr[0])) {
            numLoops[0]--;
            rewind(fptr[0]);
            eofflag[0] = 1;
            return 0;
        }
        rowsj  += rows;
    }
    return 1;
}

/* [EOF] oneoutport_readline_bs_rt.c */
