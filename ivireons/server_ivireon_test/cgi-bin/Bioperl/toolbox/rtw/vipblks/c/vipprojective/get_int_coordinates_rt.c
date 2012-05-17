/*
 *  GET_INT_COORDINATES  helper function for Draw Shape block.
 *	Converts a vector of any Simulink built-in datatype to an int32_T datatype. . 
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $  $Date: 2009/11/16 22:31:33 $
 */
#include "vipprojective_rt.h"  

/* Use the following function to convert count element input array of any Simulink built-in dtype to an int_T array */
/* count is the length of vector which is converted to int_T array */
EXPORT_FCN void MWVIP_GetIntCoordinates(void  *roiPtr, int_T roiDType, int_T *intVal, int_T count, int_T lineNum)
{
    int_T i;
	switch (roiDType) {
	case  0: 
		{ /* SS_DOUBLE */
			const real_T *u = (const real_T *)roiPtr;
            u += lineNum*count;
            for (i = 0; i < count; i++) {
                intVal[i] = (u[i]>=0) ? (int_T)(u[i] + 0.5) : (int_T)(u[i] - 0.5);
            }
		}
		break;
	case  1:
		{   /* SS_SINGLE */
			const real32_T *u = (const real32_T *)roiPtr;
            u += lineNum*count;
            for (i = 0; i < count; i++) {
                intVal[i] = (u[i]>=0) ? (int_T)(u[i] + 0.5F) : (int_T)(u[i] - 0.5F);
            }
		}
		break;
	case   2:
		{   /* SS_INT8 */
			const int8_T *u = (const int8_T *)roiPtr;
            u += lineNum*count;
            for (i = 0; i < count; i++) {
			    intVal[i] = (int_T)(u[i]);
            }
		}
		break;
	case  3 :
		{   /* SS_UINT8 */
			const uint8_T *u = (const uint8_T *)roiPtr;
            u += lineNum*count;
            for (i = 0; i < count; i++) {
			    intVal[i] = (int_T)(u[i]);
            }
		}
		break;
	case 4 :
		{   /* SS_INT16 */
			const int16_T *u = (const int16_T *)roiPtr;
            u += lineNum*count;
            for (i = 0; i < count; i++) {
			    intVal[i] = (int_T)(u[i]);
            }
		}
		break;
	case  5:
		{   /* SS_UINT16 */
			const uint16_T *u = (const uint16_T *)roiPtr;
            u += lineNum*count;
            for (i = 0; i < count; i++) {
			    intVal[i] = (int_T)(u[i]);
            }
		}
		break;
	case 6 :
		{   /* SS_INT32 */
			const int32_T *u = (const int32_T *)roiPtr;
            u += lineNum*count;
            for (i = 0; i < count; i++) {
			    intVal[i] = (int_T)(u[i]);
            }
		}
		break;
	case  7 :
		{   /* SS_UINT32 */
			const uint32_T *u = (const uint32_T *)roiPtr;
            u += lineNum*count;
            for (i = 0; i < count; i++) {
			    intVal[i] = (int_T)(u[i]);
            }
		}
	}
}

/* [EOF] get_int_coordinates_rt.c */
