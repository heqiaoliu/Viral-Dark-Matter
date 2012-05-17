/* Copyright 2004 The MathWorks, Inc. */

/*
 * fi_mdl_radix2fft_withscaling_private.h
 *
 * Real-Time Workshop code generation for Simulink model "fi_mdl_radix2fft_withscaling.mdl".
 *
 * Model Version              : 1.12
 * Real-Time Workshop version : 6.1  (R14SP2)  01-Nov-2004
 * C source code generated on : Tue Dec  7 16:22:22 2004
 */
#ifndef _RTW_HEADER_fi_mdl_radix2fft_withscaling_private_h_
#define _RTW_HEADER_fi_mdl_radix2fft_withscaling_private_h_

#include "rtwtypes.h"

/* Private macros used by the generated code to access rtModel */

#include "dsp_rt.h"                     /* Signal Processing Blockset general run time support functions */

#ifndef UCHAR_MAX
#include <limits.h>
#endif

#if ( UCHAR_MAX != (0xFFU) ) || ( SCHAR_MAX != (0x7F) )
#error Code was generated for compiler with different sized uchar/char. Consider adjusting Emulation Hardware word size settings on the Hardware Implementation pane to match your compiler word sizes as defined in the compilers limits.h header file.
#endif

#if ( USHRT_MAX != (0xFFFFU) ) || ( SHRT_MAX != (0x7FFF) )
#error Code was generated for compiler with different sized ushort/short. Consider adjusting Emulation Hardware word size settings on the Hardware Implementation pane to match your compiler word sizes as defined in the compilers limits.h header file.
#endif

#if ( UINT_MAX != (0xFFFFFFFFU) ) || ( INT_MAX != (0x7FFFFFFF) )
#error Code was generated for compiler with different sized uint/int. Consider adjusting Emulation Hardware word size settings on the Hardware Implementation pane to match your compiler word sizes as defined in the compilers limits.h header file.
#endif

#if ( ULONG_MAX != (0xFFFFFFFFU) ) || ( LONG_MAX != (0x7FFFFFFF) )
#error Code was generated for compiler with different sized ulong/long. Consider adjusting Emulation Hardware word size settings on the Hardware Implementation pane to match your compiler word sizes as defined in the compilers limits.h header file.
#endif

/* Used by FromWorkspace Block: <Root>/From Workspace */
#ifndef rtInterpolate
# define rtInterpolate(v1,v2,f1,f2) (((v1)==(v2))?((double)(v1)): (((f1)*((double)(v1)))+((f2)*((double)(v2)))))
#endif

#ifndef rtRound
# define rtRound(v) ( ((v) >= 0) ? floor((v) + 0.5) : ceil((v) - 0.5) )
#endif

#include "dspfft_rt.h"                  /* Signal Processing Blockset run time support library */

/*********************************************************************
 * LSL_S32
 * Shift Left for signed integers.
 * Note there is no differenct between logical shift left and
 * arithmetic shift left.
 */
#define LSL_S32(nBits,C) (((long)(C))<<(nBits))

/* end macro LSL_S32
 *********************************************************************/

/*********************************************************************
 * ASR
 * Arithmetic Shift Right for signed integers.
 * Note: the C standard does not specify whether shift right >> 
 * on signed integers is Logical, Arithmetic, or even garbage.
 * This macro uses the implementation dependent behavior to
 * get desired Arithmetic Shift Right behavior.  This macro is
 * NOT portable.
 */
#define ASR(nBits,C) ( (C)>>(nBits) )

/* end macro ASR
 *********************************************************************/

/*********************************************************************
 * Fixed Point Multiplication Utility MUL_S32_S16_S16
 *   Values
 *      Vc = Va * Vb
 *   Stored Integer Formula
 *      C = A * B * 2^0
 *
 * overflow is impossible
 *   HiProd = 2^30 = (-1*2^15) * (-1*2^15) * (2^0)
 *   HiOut  = 2^31 - 1
 *   LoProd = -1 * 2^30 + 2^15
 *          = (-1*2^15) * (2^15-1) * (2^0)
 *   LoOut  = -1 * 2^31
 * so SATURATE verses WRAP is irrelevant
 *    no code specific to overflow management is required
 *
 * rounding irrelevant  2^0  NO shifts right
 *    no code specific to rounding is required
 */
#define MUL_S32_S16_S16(C,A,B) \
  { \
    \
    C = (((int)(A)) * ((int)(B))); \
  } \

/* end macro MUL_S32_S16_S16
 *********************************************************************/
#ifndef __RTWTYPES_H__
#error This file requires rtwtypes.h to be included
#else
#ifdef TMWTYPES_PREVIOUSLY_INCLUDED
#error This file requires rtwtypes.h to be included before tmwtypes.h
#else
/* Check for inclusion of an incorrect version of rtwtypes.h */
#ifndef RTWTYPES_ID_C08S16I32L32N32F1
#error This code was generated with a different "rtwtypes.h" than the file included
#endif                                  /* RTWTYPES_ID_C08S16I32L32N32F1 */
#endif                                  /* TMWTYPES_PREVIOUSLY_INCLUDED */
#endif                                  /* __RTWTYPES_H__ */

#endif                                  /* _RTW_HEADER_fi_mdl_radix2fft_withscaling_private_h_ */
