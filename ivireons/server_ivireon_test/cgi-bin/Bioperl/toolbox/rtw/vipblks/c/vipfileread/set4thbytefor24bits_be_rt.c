/*
* SET4THBYTEFOR24BITS_BE_RT runtime function for VIPBLKS Read Binary File block
*
*  Copyright 1995-2007 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:47:51 $
*/
#include "vipfileread_rt.h"

/* For 3 byte data we send 4 bytes output. The data from file is read into
 * the first 3 bytes. We set 4th byte to 0x00 or 0xFF depending on sign. */
EXPORT_FCN void MWVIP_set4thBytefor24Bits_BE(void *yO, int_T N, boolean_T signedData, int_T inc)
{
    int_T i;
	byte_T *y = (byte_T *)yO;
    if (signedData) {
        for (i=0; i < N; i++) {
            y[3] = y[2];
            y[2] = y[1];
            y[1] = y[0];
            /* Fill 0x00 or 0xFF based on sign */
            y[0] = 0xFF * ((y[0] & 0x80) >> 7);
            y += inc;
        }
    } else {
        for (i=0; i < N; i++) {
            y[3] = y[2];
            y[2] = y[1];
            y[1] = y[0];
            y[0] = 0x00;
            y += inc;
        }
    }
}

/* [EOF] set4thbytefor24bits_be_rt.c */
