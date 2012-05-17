/*
 *  vipdrawtext_rt.c
 *  For "special" sprintf (taking an array of things and sprintf'ing them). 
 *
 *  Copyright 1995-2008 The MathWorks, Inc.
 *  $Revision: 1.1.12.7 $ $Date: 2008/11/18 02:11:46 $
 */

#include <stdio.h>
/* #include <string.h> */
#include "vipdrawtext_rt.h"

#ifdef _WIN64
#pragma warning(disable:4996)
#endif


/* Use function snprintf since it is more stable. 
 * the function is named as _snprintf on windows, and when the size of 
 * what needs to be printed exceeds the size of the buffer, it returns
 * -1. Need to handle it appropriately. 
 */

#if defined(_WIN32) || defined(_WIN64)
  #define VIP_SNPRINTF(out, size, in, data,result)       \
	 result = _snprintf(out, size, in, data);      \
 	 if (((result == -1) || (result == size)) && (size > 0)) { \
		out[size - 1] = '\0';							 \
        result = size;}
#else
/* incompatible flags on Linux can somtimes hide this declaration, 
 *  so we declare it again here to prevent warnings. 
 */
  extern int snprintf(char *str, size_t size, const char *format, ...);

  #define VIP_SNPRINTF(out, size, in, data, result)   \
	 result = snprintf(out, size, in, data);
#endif


#if defined(_WIN32) || defined(_WIN64)
  #define VIP_SNPRINTF_PP(out, size, result)       \
	VIP_SNPRINTF(out, size, "%%", 0,result)
#else
  #define VIP_SNPRINTF_PP(out, size,  result)   \
	result = snprintf(out, size, "%%");
#endif	


typedef int_T (*SNPRINTF_FUNC)(char_T*,int_T,char_T*,void*,int_T);

static int_T oneSprintfDouble(char_T* out, int_T size, char_T* in, void* data, int_T itemNum)
{	
    int_T result;
	VIP_SNPRINTF(out, size, in, ((real_T*)data)[itemNum], result);
	return result;
}
static int_T oneSprintfSingle(char_T* out, int_T size, char_T* in, void* data, int_T itemNum)
{
	int_T result; 
	VIP_SNPRINTF(out, size, in, ((real32_T*)data)[itemNum], result);
	return result;
}
static int_T oneSprintfInt8(char_T* out, int_T size, char_T* in, void* data, int_T itemNum)
{
	int_T result; 
	VIP_SNPRINTF(out, size, in, ((int8_T*)data)[itemNum], result);
	return result;
}
static int_T oneSprintfUint8(char_T* out, int_T size, char_T* in, void* data, int_T itemNum)
{
	int_T result; 
	VIP_SNPRINTF(out, size, in, ((uint8_T*)data)[itemNum], result);
	return result;
}
static int_T oneSprintfInt16(char_T* out, int_T size, char_T* in, void* data, int_T itemNum)
{
	int_T result; 
	VIP_SNPRINTF(out, size, in, ((int16_T*)data)[itemNum], result);
	return result;
}
static int_T oneSprintfUint16(char_T* out, int_T size, char_T* in, void* data, int_T itemNum)
{
	int_T result; 
	VIP_SNPRINTF(out, size, in, ((uint16_T*)data)[itemNum], result);
	return result;
}
static int_T oneSprintfInt32(char_T* out, int_T size, char_T* in, void* data, int_T itemNum)
{
	int_T result; 
	VIP_SNPRINTF(out, size, in, ((int32_T*)data)[itemNum], result);
	return result;
}
static int_T oneSprintfUint32(char_T* out, int_T size, char_T* in, void* data, int_T itemNum)
{
	int_T result; 
	VIP_SNPRINTF(out, size, in, ((uint32_T*)data)[itemNum], result);
	return result;
}
static int_T oneSprintfBoolean(char_T* out, int_T size, char_T* in, void* data, int_T itemNum)
{
	int_T result; 
	VIP_SNPRINTF(out, size, in, ((boolean_T*)data)[itemNum], result);
	return result;
}

static SNPRINTF_FUNC snprintfFuncs[] = 
{
	oneSprintfDouble,
	oneSprintfSingle,
	oneSprintfInt8,
	oneSprintfUint8,
	oneSprintfInt16,
	oneSprintfUint16,
	oneSprintfInt32,
	oneSprintfUint32,
	oneSprintfBoolean
};

EXPORT_FCN void MWVIP_snprintf(char_T* outbuf, 
				char_T* formatString, void* items, int_T numItems,
				int_T itemDataType,boolean_T isString, int_T maxChars)
{
	const char_T* percentSign = "%";
	char_T* thisPercentInString;
	char_T* nextPercentInString;
	char_T nullChar = '\0';
	char_T* lastCharInOutBuf = outbuf;
	int_T itemCount = 0;
	SNPRINTF_FUNC dTypeSprintfFunc = snprintfFuncs[itemDataType];
	int_T numPrintedStorage = 0;	/* used for printing nothing -- %n */
	int_T charsPrinted;

	if(outbuf == NULL ||
		formatString == NULL ||
		items == 0 ||
		(itemDataType > 8 || itemDataType < 0))  /* (itemDataType > SS_BOOLEAN || itemDataType < SS_DOUBLE)) */
		return;

	/* first check to see if it's a string... */
	if(isString)
	{
		char_T* stringIn = (char_T*) items;
		if(itemDataType != 3)	/* SS_UINT8 */
		{
			strcpy(outbuf, formatString);
			return;
		}
		stringIn[numItems-1] = '\0';	/* make sure it's NULL-terminated */
		sprintf(outbuf, formatString, stringIn);
		return;
	}

	nextPercentInString = strstr(formatString, percentSign);
	if(nextPercentInString == NULL)
	{
		strcpy(outbuf, formatString);
		return;
	}

	/* first copy up to the first % into the output buffer */
	if(nextPercentInString != formatString)
	{
		*nextPercentInString = nullChar;

		VIP_SNPRINTF(lastCharInOutBuf, maxChars, formatString, 0, charsPrinted);

		if (charsPrinted >= maxChars) return;
		lastCharInOutBuf += charsPrinted;
		maxChars -= charsPrinted;
		*nextPercentInString = *percentSign;
	}

	/* now go though the rest of the segments in the string, sprintf'ing along... */
	while(1)
	{
		thisPercentInString = nextPercentInString;
		if(  thisPercentInString == NULL || 
			*thisPercentInString == '\0' || 
			itemCount > numItems) {
			break;
		}
		nextPercentInString = strstr(thisPercentInString + 1, percentSign);
		if(nextPercentInString != NULL)
		{
			if(nextPercentInString - thisPercentInString == 1)	/* %% */
			{
				VIP_SNPRINTF_PP(lastCharInOutBuf, maxChars, charsPrinted);
				/* charsPrinted = snprintf(lastCharInOutBuf, maxChars, "%%");*/
				if (charsPrinted >=  maxChars) return;
				lastCharInOutBuf += charsPrinted;
				maxChars -= charsPrinted;
				nextPercentInString++;
				continue;
			}
			*nextPercentInString = nullChar;

			/* special case -- if one wishes to print nothing via %n, we need to call sprintf
			   with a pointer to an integer for storage */
			if(*(thisPercentInString + 1) == 'n')
			{
				VIP_SNPRINTF(lastCharInOutBuf, maxChars, thisPercentInString, &numPrintedStorage, charsPrinted);
				if (charsPrinted >= maxChars ) return;
				lastCharInOutBuf += charsPrinted;
				maxChars -= charsPrinted;
				itemCount++;
			}
			else { 
                            /* This is a temporary workaround for G366931 (03/21/2007). snprintf utility on mac seems to
                             * have some mac compiler bug when the conversion specification is %f or %e. This is
                             * circumvented by calling the function for double-precision seperately and NOT via the 
                             * function pointer. There were couple of other workarounds which are mentioned in the geck.
                             */
#if defined (__ppc__)
                            if (itemDataType == 0) {
				charsPrinted = oneSprintfDouble(lastCharInOutBuf, maxChars, thisPercentInString, items, itemCount);
                            } else {
#endif 
				charsPrinted = dTypeSprintfFunc(lastCharInOutBuf, maxChars, thisPercentInString, items, itemCount);
#if defined (__ppc__)
                            }
#endif
				if (charsPrinted >= maxChars ) return;
				lastCharInOutBuf += charsPrinted;
				maxChars -= charsPrinted;
				/* Only if the current string starts with %, increment itemCount*/
				if (*thisPercentInString == *percentSign) itemCount++;
			}
			
			*nextPercentInString = *percentSign;
		}
		else 
		{
			/* special case -- if one wishes to print nothing via %n, we need to call sprintf
			   with a pointer to an integer for storage */
			if(*(thisPercentInString + 1) == 'n')
			{
				VIP_SNPRINTF(lastCharInOutBuf, maxChars, thisPercentInString, &numPrintedStorage, charsPrinted);
				if (charsPrinted >= maxChars ) return;
				lastCharInOutBuf += charsPrinted;
				maxChars -= charsPrinted;
				itemCount++;
			}
			else 
			{
#if defined (__ppc__)
                                if (itemDataType == 0) {
				    charsPrinted = oneSprintfDouble(lastCharInOutBuf, maxChars, thisPercentInString, items, itemCount++);
                                } else {
#endif 
				    charsPrinted = dTypeSprintfFunc(lastCharInOutBuf, maxChars, thisPercentInString, items, itemCount++);
#if defined (__ppc__)
                                }
#endif
				if (charsPrinted >= maxChars ) return;
				lastCharInOutBuf += charsPrinted;
				maxChars -= charsPrinted;
			}
		}
	}
}

EXPORT_FCN void MWVIP_snprintf_wrapper(void* outbuf, 
				void* formatString, void* items, int_T numItems,
				int_T itemDataType,boolean_T isString, int_T maxChars)
{
	MWVIP_snprintf((char_T*) outbuf, 
				(char_T*) formatString, items, numItems,
				itemDataType, isString, maxChars);
}
				    
#ifdef _WIN64
#pragma warning(default:4996) /* C4996 warning state set to default */  
#endif
