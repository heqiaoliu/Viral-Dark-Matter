/*
* FULLBYTEREAD_PACKED_TLF_BS_RT runtime function for VIPBLKS Read Binary File block
*
*  Copyright 1995-2007 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:47:39 $
*/
#include "vipfileread_rt.h"
#include <stdio.h>

EXPORT_FCN boolean_T MWVIP_fullByteRead_PACKED_TLF_BS(void *fptrDW,
										   void *portAddr0,
										   void *portAddr1,
										   void *portAddr2,
										   void *portAddr3,
										   uint8_T **tmpOutPtrs,
										   int32_T *offsetC,
										   int32_T *offsetP,
										   int32_T   *numLoops,
										   boolean_T *eofflag, 
										   int_T rows, 
										   int_T cols,										   
										   int32_T *bpe,   
										   int32_T *bpeout,
										   int32_T *ctoport,
										   int_T numCompPerPack,
										   int_T iStart,
								           int_T iIncr)
{
    FILE **fptr = (FILE **) fptrDW;
	byte_T **tmpOutptrs = (byte_T **)tmpOutPtrs;

    int_T i, j, c, port;
    
	byte_T *outptrsP[4];
    /* some might be null in the following initialization */
	outptrsP[0] = (byte_T *)portAddr0;
	outptrsP[1] = (byte_T *)portAddr1;
	outptrsP[2] = (byte_T *)portAddr2;
	outptrsP[3] = (byte_T *)portAddr3;

    for (i=iStart; i < rows; i +=iIncr) {
		
        for (c=0; c < numCompPerPack; c++) {
            port = ctoport[c];            
			tmpOutptrs[c] = outptrsP[port] + offsetC[c] + i*bpeout[port];			
        }

        for (j=0; j < cols; j++) {
            for (c=0; c < numCompPerPack; c++) {
                port = ctoport[c];
                
				fread(tmpOutptrs[c], 1, bpe[port], fptr[0]);
				
                MWVIP_byteSwapN(bpe[port], tmpOutptrs[c]);
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

/* [EOF] fullbyteread_packed_tlf_bs_rt.c */
