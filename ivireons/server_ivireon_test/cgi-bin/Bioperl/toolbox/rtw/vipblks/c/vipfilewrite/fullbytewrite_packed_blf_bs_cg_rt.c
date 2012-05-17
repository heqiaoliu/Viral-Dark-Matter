/*
*  FULLBYTEWRITE_PACKED_BLF_BS_CG_RT runtime function for VIPBLKS Write Binary File block
*
*  Copyright 1995-2007 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:48:05 $
*/
#include "vipfilewrite_rt.h"
#include <stdio.h>

EXPORT_FCN void MWVIP_fullByteWrite_PACKED_BLF_BS_CG(void *fptrDW,
										   const void *portAddr0,
										   const void *portAddr1,
										   const void *portAddr2,
										   const void *portAddr3,
										   const uint8_T **tmpInPtrs,
										   int32_T *offsetC,
										   int32_T *offsetP,
										   int_T rows, 
										   int_T cols,										   
										   int32_T *bpe,   
										   int32_T *bpein,
										   int32_T *ctoport,
										   int_T numCompPerPack,
										   int_T iStartOff,
								           int_T iDecr)
{
    FILE **fptr = (FILE **) fptrDW;

    int_T i, j, c, port;
    const byte_T **tmpInptrs = (const byte_T **)tmpInPtrs;
	byte_T temp[4];

	/* some might be null in the following initialization */
	const byte_T *inptrsP[4];
	inptrsP[0] = (const byte_T *)portAddr0;
	inptrsP[1] = (const byte_T *)portAddr1;
	inptrsP[2] = (const byte_T *)portAddr2;
	inptrsP[3] = (const byte_T *)portAddr3;

	/* This function is called only in big endian machine */
	/* For big endian machine read from lower 3 bytes */
    for (c=0; c < numCompPerPack; c++) {
        port = ctoport[c];            
		if (bpe[port]==3) inptrsP[port]++;
    }

    for (i=rows-iStartOff; i >= 0; i -=iDecr) {
        for (c=0; c < numCompPerPack; c++) {
            port = ctoport[c];            
			tmpInptrs[c] = inptrsP[port] + offsetC[c] + i*bpein[port];
        }

        for (j=0; j < cols; j++) {
            for (c=0; c < numCompPerPack; c++) {
                port = ctoport[c];
                MWVIP_WriteByteSwapN(bpe[port], tmpInptrs[c], temp);                   
				fwrite(temp, 1, bpe[port], fptr[0]);				
                
				tmpInptrs[c] += offsetP[port];
            }
        }
    }
}
/* [EOF] fullbytewrite_packed_blf_bs_cg_rt.c */
