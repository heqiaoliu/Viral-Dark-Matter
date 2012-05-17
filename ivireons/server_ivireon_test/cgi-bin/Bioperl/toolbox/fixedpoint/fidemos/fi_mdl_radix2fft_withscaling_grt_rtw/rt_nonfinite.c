/* Copyright 2004 The MathWorks, Inc. */

/*
 * rt_nonfinite.c
 *
 * Real-Time Workshop code generation for Simulink model "fi_mdl_radix2fft_withscaling.mdl".
 *
 * Model Version              : 1.12
 * Real-Time Workshop version : 6.1  (R14SP2)  01-Nov-2004
 * C source code generated on : Tue Dec  7 16:22:22 2004
 *
 */

/*
 * Abstract:
 *      Real-Time Workshop function to intialize non-finites,
 *      (Inf, NaN and -Inf).
 */
#include "rt_nonfinite.h"

real_T rtInf;
real_T rtMinusInf;
real_T rtNaN;

real32_T rtInfF;
real32_T rtMinusInfF;
real32_T rtNaNF;

/* Function: rt_InitInfAndNaN ==================================================
 * Abstract:
 *	Initialize the rtInf, rtMinusInf, and rtNaN needed by the
 *	generated code. NaN is initialized as non-signaling. Assumes IEEE.
 */
void rt_InitInfAndNaN(int_T realSize) {
  short one = 1;
  enum {
    LittleEndian,
    BigEndian
  } machByteOrder = (*((char *) &one) == 1) ? LittleEndian : BigEndian;

  switch (machByteOrder) {
    case LittleEndian: {
      typedef struct {
        uint32_T fraction : 23;
        uint32_T exponent : 8;
        uint32_T sign : 1;
      } LittleEndianIEEESingle;

      typedef struct {
        struct {
          uint32_T fraction2;
        } wordH;
        struct {
          uint32_T fraction1 : 20;
          uint32_T exponent : 11;
          uint32_T sign : 1;
        } wordL;
      } LittleEndianIEEEDouble;

      (*(LittleEndianIEEESingle*)&rtInfF).sign = 0;
      (*(LittleEndianIEEESingle*)&rtInfF).exponent = 0xFF;
      (*(LittleEndianIEEESingle*)&rtInfF).fraction = 0;
      rtMinusInfF = rtInfF;
      rtNaNF = rtInfF;
      (*(LittleEndianIEEESingle*)&rtMinusInfF).sign = 1;
      (*(LittleEndianIEEESingle*)&rtNaNF).fraction = 0x7FFFFF;

      if (realSize == 4) {
        (*(LittleEndianIEEESingle*)&rtInf).sign = 0;
        (*(LittleEndianIEEESingle*)&rtInf).exponent = 0xFF;
        (*(LittleEndianIEEESingle*)&rtInf).fraction = 0;
        rtMinusInf = rtInf;
        rtNaN = rtInf;
        (*(LittleEndianIEEESingle*)&rtMinusInf).sign = 1;
        (*(LittleEndianIEEESingle*)&rtNaN).fraction = 0x7FFFFF;
      } else {
        (*(LittleEndianIEEEDouble*)&rtInf).wordL.sign = 0;
        (*(LittleEndianIEEEDouble*)&rtInf).wordL.exponent = 0x7FF;
        (*(LittleEndianIEEEDouble*)&rtInf).wordL.fraction1 = 0;
        (*(LittleEndianIEEEDouble*)&rtInf).wordH.fraction2 = 0;

        rtMinusInf = rtInf;
        (*(LittleEndianIEEEDouble*)&rtMinusInf).wordL.sign = 1;
        (*(LittleEndianIEEEDouble*)&rtNaN).wordL.sign = 0;
        (*(LittleEndianIEEEDouble*)&rtNaN).wordL.exponent = 0x7FF;
        (*(LittleEndianIEEEDouble*)&rtNaN).wordL.fraction1 = 0xFFFFF;
        (*(LittleEndianIEEEDouble*)&rtNaN).wordH.fraction2 = 0xFFFFFFFF;
      }
    }
    break;
    case BigEndian: {
      typedef struct {
        uint32_T sign : 1;
        uint32_T exponent : 8;
        uint32_T fraction : 23;
      } BigEndianIEEESingle;

      typedef struct {
        struct {
          uint32_T sign : 1;
          uint32_T exponent : 11;
          uint32_T fraction1 : 20;
        } wordL;
        struct {
          uint32_T fraction2;
        } wordH;
      } BigEndianIEEEDouble;

      (*(BigEndianIEEESingle*)&rtInfF).sign = 0;
      (*(BigEndianIEEESingle*)&rtInfF).exponent = 0xFF;
      (*(BigEndianIEEESingle*)&rtInfF).fraction = 0;
      rtMinusInfF = rtInfF;
      rtNaNF = rtInfF;
      (*(BigEndianIEEESingle*)&rtMinusInfF).sign = 1;
      (*(BigEndianIEEESingle*)&rtNaNF).fraction = 0x7FFFFF;

      if (realSize == 4) {
        (*(BigEndianIEEESingle*)&rtInf).sign = 0;
        (*(BigEndianIEEESingle*)&rtInf).exponent = 0xFF;
        (*(BigEndianIEEESingle*)&rtInf).fraction = 0;
        rtMinusInf = rtInf;
        rtNaN = rtInf;
        (*(BigEndianIEEESingle*)&rtMinusInf).sign = 1;
        (*(BigEndianIEEESingle*)&rtNaN).fraction = 0x7FFFFF;
      } else {
        (*(BigEndianIEEEDouble*)&rtInf).wordL.sign = 0;
        (*(BigEndianIEEEDouble*)&rtInf).wordL.exponent = 0x7FF;
        (*(BigEndianIEEEDouble*)&rtInf).wordL.fraction1 = 0;
        (*(BigEndianIEEEDouble*)&rtInf).wordH.fraction2 = 0;

        rtMinusInf = rtInf;
        (*(BigEndianIEEEDouble*)&rtMinusInf).wordL.sign = 1;
        (*(BigEndianIEEEDouble*)&rtNaN).wordL.sign = 0;
        (*(BigEndianIEEEDouble*)&rtNaN).wordL.exponent = 0x7FF;
        (*(BigEndianIEEEDouble*)&rtNaN).wordL.fraction1 = 0xFFFFF;
        (*(BigEndianIEEEDouble*)&rtNaN).wordH.fraction2 = 0xFFFFFFFF;
      }
    }
    break;
  }
}

/* Function: rtIsInf ==================================================
 * Abstract:
 *	Test if value is infinite
 */
boolean_T rtIsInf(real_T value) {
  return(value==rtInf || value==rtMinusInf);
}

/* Function: rtIsInfF =================================================
 * Abstract:
 *	Test if single-precision value is infinite
 */
boolean_T rtIsInfF(real32_T value) {
  return((value)==rtInfF || (value)==rtMinusInfF);
}

/* Function: rtIsNaN ==================================================
 * Abstract:
 *	Test if value is not a number
 */
boolean_T rtIsNaN(real_T value) {
  return(value!=value);
}

/* Function: rtIsNaNF =================================================
 * Abstract:
 *	Test if single-precision value is not a number
 */
boolean_T rtIsNaNF(real32_T value) {
  return(value!=value);
}

/* end rt_nonfinite.c */
