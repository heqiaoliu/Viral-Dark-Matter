/*
*  FULLBYTEWRITE_PACKED_TLF_CG_RT runtime function for VIPBLKS Write Binary File block
*
*  Copyright 1995-2007 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:48:11 $
*/
#include "vipfilewrite_rt.h"
#include <stdio.h>

EXPORT_FCN void MWVIP_fullByteWrite_PACKED_TLF_CG(void *fptrDW,
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
										   int_T iStart,
								           int_T iIncr)
{
    FILE **fptr = (FILE **) fptrDW;

    int_T i, j, c, port;
    const byte_T **tmpInptrs = (const byte_T **)tmpInPtrs;
    
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

    for (i=iStart; i < rows; i +=iIncr) {
        for (c=0; c < numCompPerPack; c++) {
            port = ctoport[c];            
			tmpInptrs[c] = inptrsP[port] + offsetC[c] + i*bpein[port];
        }

        for (j=0; j < cols; j++) {
            for (c=0; c < numCompPerPack; c++) {
                port = ctoport[c];                
				fwrite(tmpInptrs[c], 1, bpe[port], fptr[0]);
                
				tmpInptrs[c] += offsetP[port];
            }
        }
    }
}
/* [EOF] fullbytewrite_packed_tlf_cg_rt.c */
