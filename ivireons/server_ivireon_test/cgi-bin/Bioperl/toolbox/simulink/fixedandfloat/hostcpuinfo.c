/*=================================================================
 *
 * HOSTCPUINFO.C
 *
 * The calling syntax is:
 *
 *		 hostcpuinfo(double yp[])
 *
 * $Revision: 1.1.6.5 $
 *
 * This is a MEX-file for MATLAB.  
 * Copyright 1984-2009 The MathWorks, Inc.
 *
 *=================================================================*/
/* $Revision $ */
#include "hostcpuinfo.h"

void hostcpuinfo(double cpu_info[])
{

  real_T  r1, r2;

  int i1, i2, i3, i4, i5, i6, i7, i8, i9;

  /* num and denom must be declared volatile to force the divisions below to
   * happen on the target, instead of being optimized away by the compiler.
   */
  volatile int num, denom;

  short s1 = 1;

  int index = 0;

  /*-----------------------------------------------------------------------
   * shifts right on signed integers
   */
  i1 = -28;
  i2 = ( i1 >> 2 );

  cpu_info[index++] = ( i2 == ( i1 /  4) );

  /*-----------------------------------------------------------------------
   * negative operand integer division rounding
   */
  denom = 4;
  num = -7;
  i1 = num / denom;   /* -7/4 */
  num = -6;
  i2 = num / denom;   /* -6/4 */
  num = -5;
  i3 = num / denom;   /* -5/4 */
  denom = -4;
  num = 7;
  i4 = num / denom;   /* 7/-4 */
  num = 6;
  i5 = num / denom;   /* 6/-4 */
  num = 5;
  i6 = num / denom;   /* 5/-4 */
  num = -7;
  i7 = num / denom;   /* -7/-4 */
  num = -6;
  i8 = num / denom;   /* -6/-4 */
  num = -5;
  i9 = num / denom;   /* -5/-4 */

  /* round toward floor test */
  r1 = ((i1 == -2) && (i2 == -2) && (i3 == -2) &&
        (i4 == -2) && (i5 == -2) && (i6 == -2) &&
        (i7 ==  1) && (i8 ==  1) && (i9 ==  1));
        
  /* round toward zero test */
  r2 = ((i1 == -1) && (i2 == -1) && (i3 == -1) &&
        (i4 == -1) && (i5 == -1) && (i6 == -1) &&
        (i7 ==  1) && (i8 ==  1) && (i9 ==  1));

  /* set rounding behaviour*/
  if (r1 && !r2)
      /* Rounds to floor */
      cpu_info[index++] = 1;
  else if (!r1 && r2)
      /* rounds to zero */
      cpu_info[index++] = 2;
  else
      /* undefined */
      cpu_info[index++] = 3;

  /*-----------------------------------------------------------------------
   * Byte order test (little-endian == 0, big-endian == 1)
   */
  cpu_info[index++] =  (*((char *) &s1) == 1) ? 0 : 1;
   
  /*-----------------------------------------------------------------------
   * bits per char, short, int, long
   */
  r1 = UCHAR_MAX + 1.0;
  r2 = frexp( r1, &i1 );
  cpu_info[index++] = i1-1;

  r1 = USHRT_MAX + 1.0;
  r2 = frexp( r1, &i1 );
  cpu_info[index++] = i1-1;

  r1 = UINT_MAX + 1.0;
  r2 = frexp( r1, &i1 );
  cpu_info[index++] = i1-1;

  r1 = ULONG_MAX + 1.0;
  r2 = frexp( r1, &i1 );
  cpu_info[index++] = i1-1;


    return;
}
