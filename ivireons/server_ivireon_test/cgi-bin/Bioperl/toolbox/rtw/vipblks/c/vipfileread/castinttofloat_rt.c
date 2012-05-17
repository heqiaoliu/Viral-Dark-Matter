/*
* CASTINTTOFLOAT_RT runtime function for VIPBLKS Read Binary File block
*
*  Copyright 1995-2007 The MathWorks, Inc.
*  $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:47:33 $
*/
#include "vipfileread_rt.h"

EXPORT_FCN void MWVIP_castIntToFloat(real_T *yfloat, int_T N, int_T inc, int_T dtIdx)
{
	/* dtIdx is not same as simulink DTypeId */
    int_T i;

	switch (dtIdx) 
	{
      case 0:/* uint8 */
		  {
			uint8_T *yint = (uint8_T *)yfloat;
			for (i=0; i < N; i++) {
				yfloat[i] = (real_T) *yint;
				yint += inc;
			}
		  }
        break;

      case 1:/* uint16 */
		  {
			uint16_T *yint = (uint16_T *)yfloat;
			for (i=0; i < N; i++) {
				yfloat[i] = (real_T) *yint;
				yint += inc;
			}
		  }
        break;

      case 2:/* uint32 */
		  {
			uint32_T *yint = (uint32_T *)yfloat;
			for (i=0; i < N; i++) {
				yfloat[i] = (real_T) *yint;
				yint += inc;
			}
		  }
        break;
      case 3:/* int8 */
		  {
			int8_T *yint = (int8_T *)yfloat;
			for (i=0; i < N; i++) {
				yfloat[i] = (real_T) *yint;
				yint += inc;
			}
		  }
        break;

      case 4:/* int16 */
		  {
			int16_T *yint = (int16_T *)yfloat;
			for (i=0; i < N; i++) {
				yfloat[i] = (real_T) *yint;
				yint += inc;
			}
		  }
        break;
      default:/* int32 */
		  {
			int32_T *yint = (int32_T *)yfloat;
			for (i=0; i < N; i++) {
				yfloat[i] = (real_T) *yint;
				yint += inc;
			}
		  }
        break;
    }
}

/* [EOF] castinttofloat_rt.c */
