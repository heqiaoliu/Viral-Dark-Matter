/*
*  CASTDOUBLETOFIX_RT runtime function for VIPBLKS Write Binary File block
*
*  Copyright 1995-2007 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:48:03 $
*/
#include "vipfilewrite_rt.h"
#include <stdio.h>

EXPORT_FCN void MWVIP_castDoubleToFix(const real_T *uin, void *dworkPtrO, int_T inWidth, int_T dtIdx)
{
	/* dtIdx is not same as simulink DTypeId */
    int_T i;

	switch (dtIdx) 
	{
      case 0:/* uint8 */
		  {
			uint8_T *dworkPtr = (uint8_T *)dworkPtrO;
			for (i=0; i < inWidth; i++) {
				dworkPtr[i] = (uint8_T) uin[i];
			}
		  }
        break;

      case 1:/* uint16 */
		  {
			uint16_T *dworkPtr = (uint16_T *)dworkPtrO;
			for (i=0; i < inWidth; i++) {
				dworkPtr[i] = (uint16_T) uin[i];
			}
		  }
        break;

      case 2:/* uint32 */
		  {
			uint32_T *dworkPtr = (uint32_T *)dworkPtrO;
			for (i=0; i < inWidth; i++) {
				dworkPtr[i] = (uint32_T) uin[i];
			}
		  }
        break;
      case 3:/* int8 */
		  {
			int8_T *dworkPtr = (int8_T *)dworkPtrO;
			for (i=0; i < inWidth; i++) {
				dworkPtr[i] = (int8_T) uin[i];
			}
		  }
        break;

      case 4:/* int16 */
		  {
			int16_T *dworkPtr = (int16_T *)dworkPtrO;
			for (i=0; i < inWidth; i++) {
				dworkPtr[i] = (int16_T) uin[i];
			}
		  }
        break;
      default:/* int32 */
		  {
			int32_T *dworkPtr = (int32_T *)dworkPtrO;
			for (i=0; i < inWidth; i++) {
				dworkPtr[i] = (int32_T) uin[i];
			}
		  }
        break;
    }
}
/* [EOF] castdoubletofix_rt.c */
