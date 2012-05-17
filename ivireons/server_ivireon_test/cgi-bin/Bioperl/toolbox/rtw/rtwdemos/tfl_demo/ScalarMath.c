/* Copyright 2008-2009 The MathWorks, Inc. */
#include "ScalarMath.h"

#define DO_ADD(A,B,C)           *(C) = ((A) + (B));

#define DO_CADD(A,B,C)          (*(C)).re = ((A).re + (B).re);\
                                (*(C)).im = ((A).im + (B).im);                                 

#define DO_MINUS(A,B,C)         *(C) = ((A) - (B));

#define DO_CMINUS(A,B,C)        (*(C)).re = ((A).re - (B).re);\
                                (*(C)).im = ((A).im - (B).im);

#define DO_DIV(A,B,C)           *(C) = ((A) / (B));

#define DO_CDIV(A,B,C)          (*(C)).re = ((((A).re * (B).re) + ((A).im * (B).im))/\
                                          (((B).re * (B).re) + ((B).im * (B).im)));\
                                (*(C)).im = ((((A).im * (B).re) - ((A).re * (B).im))/\
                                          (((B).re * (B).re) + ((B).im * (B).im)));\

#define DO_CONJ(A,C)            (*(C)).re = (A).re;\
                                (*(C)).im = -(A).im;

#define DO_MULT(A,B,C)          *(C) = ((A) * (B));

#define DO_CMULT(A,B,C)         (*(C)).re = (((A).re * (B).re) - ((A).im * (B).im));\
                                (*(C)).im = (((A).re * (B).im) + ((A).im * (B).re));

#define DO_CAST(A,C)            *(C) = (A);

#define DO_SRA(A,B,C)           *(C) = (A)>>(B);

#define DO_SL(A,B,C)            *(C) = (A)<<(B);


void scalar_sum_single(   real32_T A,   real32_T B, real32_T* C)
{ DO_ADD(A,B,C); }

void scalar_sum_double(     real_T A,     real_T B,   real_T* C)
{ DO_ADD(A,B,C); }

void scalar_sum_int8(       int8_T A,     int8_T B,   int8_T* C)
{ DO_ADD(A,B,C); }

void scalar_sum_int16(     int16_T A,    int16_T B,  int16_T* C)
{ DO_ADD(A,B,C); }

void scalar_sum_int32(     int32_T A,    int32_T B,  int32_T* C)
{ DO_ADD(A,B,C); }

void scalar_sum_uint8(     uint8_T A,    uint8_T B,  uint8_T* C)
{ DO_ADD(A,B,C); }

void scalar_sum_uint16(   uint16_T A,   uint16_T B, uint16_T* C)
{ DO_ADD(A,B,C); }

void scalar_sum_uint32(   uint32_T A,   uint32_T B, uint32_T* C)
{ DO_ADD(A,B,C); }



void scalar_minus_single(   real32_T A,   real32_T B, real32_T* C)
{ DO_MINUS(A,B,C); }

void scalar_minus_double(     real_T A,     real_T B,   real_T* C)
{ DO_MINUS(A,B,C); }

void scalar_minus_int8(       int8_T A,     int8_T B,   int8_T* C)
{ DO_MINUS(A,B,C); }

void scalar_minus_int16(     int16_T A,    int16_T B,  int16_T* C)
{ DO_MINUS(A,B,C); }

void scalar_minus_int32(     int32_T A,    int32_T B,  int32_T* C)
{ DO_MINUS(A,B,C); }

void scalar_minus_uint8(     uint8_T A,    uint8_T B,  uint8_T* C)
{ DO_MINUS(A,B,C); }

void scalar_minus_uint16(   uint16_T A,   uint16_T B, uint16_T* C)
{ DO_MINUS(A,B,C); }

void scalar_minus_uint32(   uint32_T A,   uint32_T B, uint32_T* C)
{ DO_MINUS(A,B,C); }


void scalar_div_single(   real32_T A,   real32_T B, real32_T* C)
{ DO_DIV(A,B,C); }
void scalar_div_double(     real_T A,     real_T B,   real_T* C)
{ DO_DIV(A,B,C); }

void scalar_div_int8(       int8_T A,     int8_T B,   int8_T* C)
{ DO_DIV(A,B,C); }

void scalar_div_int16(     int16_T A,    int16_T B,  int16_T* C)
{ DO_DIV(A,B,C); }

void scalar_div_int32(     int32_T A,    int32_T B,  int32_T* C)
{ DO_DIV(A,B,C); }

void scalar_div_uint8(     uint8_T A,    uint8_T B,  uint8_T* C)
{ DO_DIV(A,B,C); }

void scalar_div_uint16(   uint16_T A,   uint16_T B, uint16_T* C)
{ DO_DIV(A,B,C); }

void scalar_div_uint32(   uint32_T A,   uint32_T B, uint32_T* C)
{ DO_DIV(A,B,C); }




void scalar_mult_single(   real32_T A,   real32_T B,   real32_T* C)
{ DO_MULT(A,B,C); }
void scalar_mult_double(     real_T A,     real_T B,   real_T* C)
{ DO_MULT(A,B,C); }

void scalar_mult_int8(       int8_T A,     int8_T B,  int16_T* C)
{ DO_MULT(A,B,C); }

void scalar_mult_int16(     int16_T A,    int16_T B,  int32_T* C)
{ DO_MULT(A,B,C); }

void scalar_mult_int32(     int32_T A,    int32_T B,  int32_T* C)
{ DO_MULT(A,B,C); }

void scalar_mult_uint8(     uint8_T A,    uint8_T B, uint16_T* C)
{ DO_MULT(A,B,C); }

void scalar_mult_uint16(   uint16_T A,   uint16_T B, uint32_T* C)
{ DO_MULT(A,B,C); }


#ifdef CREAL_T

void scalar_sum_csingle(   creal32_T A,   creal32_T B, creal32_T* C)
{ DO_CADD(A,B,C); }

void scalar_sum_cdouble(     creal_T A,     creal_T B,   creal_T* C)
{ DO_CADD(A,B,C); }

void scalar_sum_cint8(       cint8_T A,     cint8_T B,   cint8_T* C)
{ DO_CADD(A,B,C); }

void scalar_sum_cint16(     cint16_T A,    cint16_T B,  cint16_T* C)
{ DO_CADD(A,B,C); }

void scalar_sum_cint32(     cint32_T A,    cint32_T B,  cint32_T* C)
{ DO_CADD(A,B,C); }

void scalar_sum_cuint8(     cuint8_T A,    cuint8_T B,  cuint8_T* C)
{ DO_CADD(A,B,C); }

void scalar_sum_cuint16(   cuint16_T A,   cuint16_T B, cuint16_T* C)
{ DO_CADD(A,B,C); }

void scalar_sum_cuint32(   cuint32_T A,   cuint32_T B, cuint32_T* C)
{ DO_CADD(A,B,C); }


void scalar_minus_csingle(   creal32_T A,   creal32_T B, creal32_T* C)
{ DO_CMINUS(A,B,C); }

void scalar_minus_cdouble(     creal_T A,     creal_T B,   creal_T* C)
{ DO_CMINUS(A,B,C); }

void scalar_minus_cint8(       cint8_T A,     cint8_T B,   cint8_T* C)
{ DO_CMINUS(A,B,C); }

void scalar_minus_cint16(     cint16_T A,    cint16_T B,  cint16_T* C)
{ DO_CMINUS(A,B,C); }

void scalar_minus_cint32(     cint32_T A,    cint32_T B,  cint32_T* C)
{ DO_CMINUS(A,B,C); }

void scalar_minus_cuint8(     cuint8_T A,    cuint8_T B,  cuint8_T* C)
{ DO_CMINUS(A,B,C); }

void scalar_minus_cuint16(   cuint16_T A,   cuint16_T B, cuint16_T* C)
{ DO_CMINUS(A,B,C); }

void scalar_minus_cuint32(   cuint32_T A,   cuint32_T B, cuint32_T* C)
{ DO_CMINUS(A,B,C); }


void scalar_div_csingle(   creal32_T A,   creal32_T B, creal32_T* C)
{ DO_CDIV(A,B,C); }

void scalar_div_cdouble(     creal_T A,     creal_T B,   creal_T* C)
{ DO_CDIV(A,B,C); }

void scalar_div_cint8(       cint8_T A,     cint8_T B,   cint8_T* C)
{ DO_CDIV(A,B,C); }

void scalar_div_cint16(     cint16_T A,    cint16_T B,  cint16_T* C)
{ DO_CDIV(A,B,C); }

void scalar_div_cint32(     cint32_T A,    cint32_T B,  cint32_T* C)
{ DO_CDIV(A,B,C); }

void scalar_div_cuint8(     cuint8_T A,    cuint8_T B,  cuint8_T* C)
{ DO_CDIV(A,B,C); }

void scalar_div_cuint16(   cuint16_T A,   cuint16_T B, cuint16_T* C)
{ DO_CDIV(A,B,C); }

void scalar_div_cuint32(   cuint32_T A,   cuint32_T B, cuint32_T* C)
{ DO_CDIV(A,B,C); }


void scalar_conj_csingle(   creal32_T A, creal32_T* C)
{ DO_CONJ(A,C); }

void scalar_conj_cdouble(     creal_T A,   creal_T* C)
{ DO_CONJ(A,C); }

void scalar_conj_cint8(       cint8_T A,   cint8_T* C)
{ DO_CONJ(A,C); }

void scalar_conj_cint16(     cint16_T A,  cint16_T* C)
{ DO_CONJ(A,C); }

void scalar_conj_cint32(     cint32_T A,  cint32_T* C)
{ DO_CONJ(A,C); }

void scalar_conj_cuint8(     cuint8_T A,  cuint8_T* C)
{ DO_CONJ(A,C); }

void scalar_conj_cuint16(   cuint16_T A, cuint16_T* C)
{ DO_CONJ(A,C); }

void scalar_conj_cuint32(   cuint32_T A, cuint32_T* C)
{ DO_CONJ(A,C); }


void scalar_mult_csingle(   creal32_T A,   creal32_T B,   creal32_T* C)
{ DO_CMULT(A,B,C); }

void scalar_mult_cdouble(     creal_T A,     creal_T B,   creal_T* C)
{ DO_CMULT(A,B,C); }

void scalar_mult_cint8(       cint8_T A,     cint8_T B,  cint16_T* C)
{ DO_CMULT(A,B,C); }

void scalar_mult_cint16(     cint16_T A,    cint16_T B,  cint32_T* C)
{ DO_CMULT(A,B,C); }


#endif


void scalar_cast_double( real_T A, real32_T* C)
{ DO_CAST(A,C);   }

void scalar_sra_int16( int16_T A, uint8_T B, int16_T* C)
{ DO_SRA(A,B,C); }

void scalar_sl_int16(  int16_T A, uint8_T B, int16_T* C)
{ DO_SL(A,B,C); }

void scalar_srl_uint32(uint32_T A, uint8_T B, uint32_T* C)
{ DO_SRA(A,B,C); }


