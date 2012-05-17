/*
* BITSREAD_PACKED_BLF_RT runtime function for VIPBLKS Read Binary File block
*
*  Copyright 1995-2007 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:47:30 $
*/
#include "vipfileread_rt.h"
#include <stdio.h>

/* This function is */
/* not used until we support non-multiple of 8 bits */

EXPORT_FCN boolean_T MWVIP_bitsRead_PACKED_BLF(void *fptrDW,
										   uint8_T *portAddr0,
										   uint8_T *portAddr1,
										   uint8_T *portAddr2,
										   uint8_T *portAddr3,
										   uint8_T **tmpOutPtrs,
										   int32_T *offsetC,
										   int32_T *offsetP,
										   int32_T   *numLoops,
										   boolean_T *eofflag, 
										   int_T rows, 
										   int_T cols,										   
										   int32_T *bpeout,
										   int32_T *bitspe,
										   int32_T *ctoport,
										   int_T numCompPerPack,
										   int_T iStartOff,
								           int_T iDecr,
										   byte_T   currentChar,
                                           int32_T  leftoverBits)
{
    FILE **fptr = (FILE **) fptrDW;
	byte_T **tmpOutptrs = (byte_T **)tmpOutPtrs;

    int_T i, j, c, port=0;
     
	byte_T *outptrsP[4];
	/* some might be null in the following initialization */
	outptrsP[0] = (byte_T *)portAddr0;
	outptrsP[1] = (byte_T *)portAddr1;
	outptrsP[2] = (byte_T *)portAddr2;
	outptrsP[3] = (byte_T *)portAddr3;

    for (i=rows-iStartOff; i >= 0; i -=iDecr) {		
        for (c=0; c < numCompPerPack; c++) {
            port = ctoport[c];           
			tmpOutptrs[c] = outptrsP[port] + offsetC[c] + i*bpeout[port];			
        }

        for (j=0; j < cols; j++) {
            for (c=0; c < numCompPerPack; c++) {

				MWVIP_getValue(fptrDW, (void **)tmpOutptrs, bitspe, c, currentChar, leftoverBits);
                if (feof(fptr[0])) {
                    numLoops[0]--;
                    rewind(fptr[0]);
                    eofflag[0] = 1;
                    return 0;
                }
                
				tmpOutptrs[c] += offsetP[port];
            }
        }
    }
	
	return 1;
}
/* [EOF] bitsread_packed_blf_rt.c */
