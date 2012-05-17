/* Copyright 2008-2009 The MathWorks, Inc. */
#ifndef _MatrixMath_h
#define _MatrixMath_h

#include "rtwtypes.h"

#ifdef __cplusplus
"C" {
#endif

void matrix_sum_2x2_single( const real32_T* A, const real32_T* B, real32_T* C);
void matrix_sum_2x2_double(   const real_T* A,   const real_T* B,   real_T* C);
void matrix_sum_2x2_int8(     const int8_T* A,   const int8_T* B,   int8_T* C);
void matrix_sum_2x2_int16(   const int16_T* A,  const int16_T* B,  int16_T* C);
void matrix_sum_2x2_int32(   const int32_T* A,  const int32_T* B,  int32_T* C);
void matrix_sum_2x2_uint8(   const uint8_T* A,  const uint8_T* B,  uint8_T* C);
void matrix_sum_2x2_uint16( const uint16_T* A, const uint16_T* B, uint16_T* C);
void matrix_sum_2x2_uint32( const uint32_T* A, const uint32_T* B, uint32_T* C);

#ifdef CREAL_T
void matrix_sum_2x2_csingle( const creal32_T* A, const creal32_T* B, creal32_T* C);
void matrix_sum_2x2_cdouble(   const creal_T* A,   const creal_T* B,   creal_T* C);
void matrix_sum_2x2_cint8(     const cint8_T* A,   const cint8_T* B,   cint8_T* C);
void matrix_sum_2x2_cint16(   const cint16_T* A,  const cint16_T* B,  cint16_T* C);
void matrix_sum_2x2_cint32(   const cint32_T* A,  const cint32_T* B,  cint32_T* C);
void matrix_sum_2x2_cuint8(   const cuint8_T* A,  const cuint8_T* B,  cuint8_T* C);
void matrix_sum_2x2_cuint16( const cuint16_T* A, const cuint16_T* B, cuint16_T* C);
void matrix_sum_2x2_cuint32( const cuint32_T* A, const cuint32_T* B, cuint32_T* C);
#endif

void matrix_sum_3x3_single( const real32_T* A, const real32_T* B, real32_T* C);
void matrix_sum_3x3_double(   const real_T* A,   const real_T* B,   real_T* C);
void matrix_sum_3x3_int8(     const int8_T* A,   const int8_T* B,   int8_T* C);
void matrix_sum_3x3_int16(   const int16_T* A,  const int16_T* B,  int16_T* C);
void matrix_sum_3x3_int32(   const int32_T* A,  const int32_T* B,  int32_T* C);
void matrix_sum_3x3_uint8(   const uint8_T* A,  const uint8_T* B,  uint8_T* C);
void matrix_sum_3x3_uint16( const uint16_T* A, const uint16_T* B, uint16_T* C);
void matrix_sum_3x3_uint32( const uint32_T* A, const uint32_T* B, uint32_T* C);

void matrix_sum_3x3_int8_int16(  const int8_T* A,   const int16_T* B,  int16_T* C);
void matrix_sum_3x3_int16_int8(  const int16_T* A,  const int8_T* B,   int16_T* C);
void matrix_sum_3x3_int8_int32(  const int8_T* A,   const int32_T* B,  int32_T* C);
void matrix_sum_3x3_int32_int8(  const int32_T* A,  const int8_T* B,   int32_T* C);
void matrix_sum_3x3_int16_int32( const int16_T* A,  const int32_T* B,  int32_T* C);
void matrix_sum_3x3_int32_int16( const int32_T* A,  const int16_T* B,  int32_T* C);
void matrix_sum_3x3_single_double(const real32_T* A, const real_T* B,   real_T* C);
void matrix_sum_3x3_double_single(const real_T* A,   const real32_T* B, real_T* C);

#ifdef CREAL_T
void matrix_sum_3x3_csingle( const creal32_T* A, const creal32_T* B, creal32_T* C);
void matrix_sum_3x3_cdouble(   const creal_T* A,   const creal_T* B,   creal_T* C);
void matrix_sum_3x3_cint8(     const cint8_T* A,   const cint8_T* B,   cint8_T* C);
void matrix_sum_3x3_cint16(   const cint16_T* A,  const cint16_T* B,  cint16_T* C);
void matrix_sum_3x3_cint32(   const cint32_T* A,  const cint32_T* B,  cint32_T* C);
void matrix_sum_3x3_cuint8(   const cuint8_T* A,  const cuint8_T* B,  cuint8_T* C);
void matrix_sum_3x3_cuint16( const cuint16_T* A, const cuint16_T* B, cuint16_T* C);
void matrix_sum_3x3_cuint32( const cuint32_T* A, const cuint32_T* B, cuint32_T* C);
#endif

void matrix_sum_4x4_single( const real32_T* A, const real32_T* B, real32_T* C);
void matrix_sum_4x4_double(   const real_T* A,   const real_T* B,   real_T* C);
void matrix_sum_4x4_int8(     const int8_T* A,   const int8_T* B,   int8_T* C);
void matrix_sum_4x4_int16(   const int16_T* A,  const int16_T* B,  int16_T* C);
void matrix_sum_4x4_int32(   const int32_T* A,  const int32_T* B,  int32_T* C);
void matrix_sum_4x4_uint8(   const uint8_T* A,  const uint8_T* B,  uint8_T* C);
void matrix_sum_4x4_uint16( const uint16_T* A, const uint16_T* B, uint16_T* C);
void matrix_sum_4x4_uint32( const uint32_T* A, const uint32_T* B, uint32_T* C);

#ifdef CREAL_T
void matrix_sum_4x4_csingle( const creal32_T* A, const creal32_T* B, creal32_T* C);
void matrix_sum_4x4_cdouble(   const creal_T* A,   const creal_T* B,   creal_T* C);
void matrix_sum_4x4_cint8(     const cint8_T* A,   const cint8_T* B,   cint8_T* C);
void matrix_sum_4x4_cint16(   const cint16_T* A,  const cint16_T* B,  cint16_T* C);
void matrix_sum_4x4_cint32(   const cint32_T* A,  const cint32_T* B,  cint32_T* C);
void matrix_sum_4x4_cuint8(   const cuint8_T* A,  const cuint8_T* B,  cuint8_T* C);
void matrix_sum_4x4_cuint16( const cuint16_T* A, const cuint16_T* B, cuint16_T* C);
void matrix_sum_4x4_cuint32( const cuint32_T* A, const cuint32_T* B, cuint32_T* C);
#endif

void matrix_sub_2x2_single( const real32_T* A, const real32_T* B, real32_T* C);
void matrix_sub_2x2_double(   const real_T* A,   const real_T* B,   real_T* C);
void matrix_sub_2x2_int8(     const int8_T* A,   const int8_T* B,   int8_T* C);
void matrix_sub_2x2_int16(   const int16_T* A,  const int16_T* B,  int16_T* C);
void matrix_sub_2x2_int32(   const int32_T* A,  const int32_T* B,  int32_T* C);
void matrix_sub_2x2_uint8(   const uint8_T* A,  const uint8_T* B,  uint8_T* C);
void matrix_sub_2x2_uint16( const uint16_T* A, const uint16_T* B, uint16_T* C);
void matrix_sub_2x2_uint32( const uint32_T* A, const uint32_T* B, uint32_T* C);

#ifdef CREAL_T
void matrix_sub_2x2_csingle( const creal32_T* A, const creal32_T* B, creal32_T* C);
void matrix_sub_2x2_cdouble(   const creal_T* A,   const creal_T* B,   creal_T* C);
void matrix_sub_2x2_cint8(     const cint8_T* A,   const cint8_T* B,   cint8_T* C);
void matrix_sub_2x2_cint16(   const cint16_T* A,  const cint16_T* B,  cint16_T* C);
void matrix_sub_2x2_cint32(   const cint32_T* A,  const cint32_T* B,  cint32_T* C);
void matrix_sub_2x2_cuint8(   const cuint8_T* A,  const cuint8_T* B,  cuint8_T* C);
void matrix_sub_2x2_cuint16( const cuint16_T* A, const cuint16_T* B, cuint16_T* C);
void matrix_sub_2x2_cuint32( const cuint32_T* A, const cuint32_T* B, cuint32_T* C);
#endif

void matrix_sub_3x3_single( const real32_T* A, const real32_T* B, real32_T* C);
void matrix_sub_3x3_double(   const real_T* A,   const real_T* B,   real_T* C);
void matrix_sub_3x3_int8(     const int8_T* A,   const int8_T* B,   int8_T* C);
void matrix_sub_3x3_int16(   const int16_T* A,  const int16_T* B,  int16_T* C);
void matrix_sub_3x3_int32(   const int32_T* A,  const int32_T* B,  int32_T* C);
void matrix_sub_3x3_uint8(   const uint8_T* A,  const uint8_T* B,  uint8_T* C);
void matrix_sub_3x3_uint16( const uint16_T* A, const uint16_T* B, uint16_T* C);
void matrix_sub_3x3_uint32( const uint32_T* A, const uint32_T* B, uint32_T* C);

void matrix_sub_3x3_int8_int16(  const int8_T* A,   const int16_T* B,  int16_T* C);
void matrix_sub_3x3_int16_int8(  const int16_T* A,  const int8_T* B,   int16_T* C);
void matrix_sub_3x3_int8_int32(  const int8_T* A,   const int32_T* B,  int32_T* C);
void matrix_sub_3x3_int32_int8(  const int32_T* A,  const int8_T* B,   int32_T* C);
void matrix_sub_3x3_int16_int32( const int16_T* A,  const int32_T* B,  int32_T* C);
void matrix_sub_3x3_int32_int16( const int32_T* A,  const int16_T* B,  int32_T* C);
void matrix_sub_3x3_single_double(const real32_T* A, const real_T* B,   real_T* C);
void matrix_sub_3x3_double_single(const real_T* A,   const real32_T* B, real_T* C);

#ifdef CREAL_T
void matrix_sub_3x3_csingle( const creal32_T* A, const creal32_T* B, creal32_T* C);
void matrix_sub_3x3_cdouble(   const creal_T* A,   const creal_T* B,   creal_T* C);
void matrix_sub_3x3_cint8(     const cint8_T* A,   const cint8_T* B,   cint8_T* C);
void matrix_sub_3x3_cint16(   const cint16_T* A,  const cint16_T* B,  cint16_T* C);
void matrix_sub_3x3_cint32(   const cint32_T* A,  const cint32_T* B,  cint32_T* C);
void matrix_sub_3x3_cuint8(   const cuint8_T* A,  const cuint8_T* B,  cuint8_T* C);
void matrix_sub_3x3_cuint16( const cuint16_T* A, const cuint16_T* B, cuint16_T* C);
void matrix_sub_3x3_cuint32( const cuint32_T* A, const cuint32_T* B, cuint32_T* C);
#endif

void matrix_sub_4x4_single( const real32_T* A, const real32_T* B, real32_T* C);
void matrix_sub_4x4_double(   const real_T* A,   const real_T* B,   real_T* C);
void matrix_sub_4x4_int8(     const int8_T* A,   const int8_T* B,   int8_T* C);
void matrix_sub_4x4_int16(   const int16_T* A,  const int16_T* B,  int16_T* C);
void matrix_sub_4x4_int32(   const int32_T* A,  const int32_T* B,  int32_T* C);
void matrix_sub_4x4_uint8(   const uint8_T* A,  const uint8_T* B,  uint8_T* C);
void matrix_sub_4x4_uint16( const uint16_T* A, const uint16_T* B, uint16_T* C);
void matrix_sub_4x4_uint32( const uint32_T* A, const uint32_T* B, uint32_T* C);

#ifdef CREAL_T
void matrix_sub_4x4_csingle( const creal32_T* A, const creal32_T* B, creal32_T* C);
void matrix_sub_4x4_cdouble(   const creal_T* A,   const creal_T* B,   creal_T* C);
void matrix_sub_4x4_cint8(     const cint8_T* A,   const cint8_T* B,   cint8_T* C);
void matrix_sub_4x4_cint16(   const cint16_T* A,  const cint16_T* B,  cint16_T* C);
void matrix_sub_4x4_cint32(   const cint32_T* A,  const cint32_T* B,  cint32_T* C);
void matrix_sub_4x4_cuint8(   const cuint8_T* A,  const cuint8_T* B,  cuint8_T* C);
void matrix_sub_4x4_cuint16( const cuint16_T* A, const cuint16_T* B, cuint16_T* C);
void matrix_sub_4x4_cuint32( const cuint32_T* A, const cuint32_T* B, cuint32_T* C);
#endif

void matrix_trans_2x2_single( const real32_T* A, real32_T* B);
void matrix_trans_2x2_double(   const real_T* A,   real_T* B);
void matrix_trans_2x2_int8(     const int8_T* A,   int8_T* B);
void matrix_trans_2x2_int16(   const int16_T* A,  int16_T* B);
void matrix_trans_2x2_int32(   const int32_T* A,  int32_T* B);
void matrix_trans_2x2_uint8(   const uint8_T* A,  uint8_T* B);
void matrix_trans_2x2_uint16( const uint16_T* A, uint16_T* B);
void matrix_trans_2x2_uint32( const uint32_T* A, uint32_T* B);

void matrix_trans_3x3_single( const real32_T* A, real32_T* B);
void matrix_trans_3x3_double(   const real_T* A,   real_T* B);
void matrix_trans_3x3_int8(     const int8_T* A,   int8_T* B);
void matrix_trans_3x3_int16(   const int16_T* A,  int16_T* B);
void matrix_trans_3x3_int32(   const int32_T* A,  int32_T* B);
void matrix_trans_3x3_uint8(   const uint8_T* A,  uint8_T* B);
void matrix_trans_3x3_uint16( const uint16_T* A, uint16_T* B);
void matrix_trans_3x3_uint32( const uint32_T* A, uint32_T* B);

void matrix_trans_4x4_single( const real32_T* A, real32_T* B);
void matrix_trans_4x4_double(   const real_T* A,   real_T* B);
void matrix_trans_4x4_int8(     const int8_T* A,   int8_T* B);
void matrix_trans_4x4_int16(   const int16_T* A,  int16_T* B);
void matrix_trans_4x4_int32(   const int32_T* A,  int32_T* B);
void matrix_trans_4x4_uint8(   const uint8_T* A,  uint8_T* B);
void matrix_trans_4x4_uint16( const uint16_T* A, uint16_T* B);
void matrix_trans_4x4_uint32( const uint32_T* A, uint32_T* B);

#ifdef CREAL_T

void matrix_trans_2x2_csingle( const creal32_T* A, creal32_T* B);
void matrix_trans_2x2_cdouble(   const creal_T* A,   creal_T* B);
void matrix_trans_2x2_cint8(     const cint8_T* A,   cint8_T* B);
void matrix_trans_2x2_cint16(   const cint16_T* A,  cint16_T* B);
void matrix_trans_2x2_cint32(   const cint32_T* A,  cint32_T* B);
void matrix_trans_2x2_cuint8(   const cuint8_T* A,  cuint8_T* B);
void matrix_trans_2x2_cuint16( const cuint16_T* A, cuint16_T* B);
void matrix_trans_2x2_cuint32( const cuint32_T* A, cuint32_T* B);

void matrix_trans_3x3_csingle( const creal32_T* A, creal32_T* B);
void matrix_trans_3x3_cdouble(   const creal_T* A,   creal_T* B);
void matrix_trans_3x3_cint8(     const cint8_T* A,   cint8_T* B);
void matrix_trans_3x3_cint16(   const cint16_T* A,  cint16_T* B);
void matrix_trans_3x3_cint32(   const cint32_T* A,  cint32_T* B);
void matrix_trans_3x3_cuint8(   const cuint8_T* A,  cuint8_T* B);
void matrix_trans_3x3_cuint16( const cuint16_T* A, cuint16_T* B);
void matrix_trans_3x3_cuint32( const cuint32_T* A, cuint32_T* B);

void matrix_trans_4x4_csingle( const creal32_T* A, creal32_T* B);
void matrix_trans_4x4_cdouble(   const creal_T* A,   creal_T* B);
void matrix_trans_4x4_cint8(     const cint8_T* A,   cint8_T* B);
void matrix_trans_4x4_cint16(   const cint16_T* A,  cint16_T* B);
void matrix_trans_4x4_cint32(   const cint32_T* A,  cint32_T* B);
void matrix_trans_4x4_cuint8(   const cuint8_T* A,  cuint8_T* B);
void matrix_trans_4x4_cuint16( const cuint16_T* A, cuint16_T* B);
void matrix_trans_4x4_cuint32( const cuint32_T* A, cuint32_T* B);

#endif

#ifdef CREAL_T

void matrix_conj_2x2_csingle( const creal32_T* A, creal32_T* B);
void matrix_conj_2x2_cdouble(   const creal_T* A,   creal_T* B);
void matrix_conj_2x2_cint8(     const cint8_T* A,   cint8_T* B);
void matrix_conj_2x2_cint16(   const cint16_T* A,  cint16_T* B);
void matrix_conj_2x2_cint32(   const cint32_T* A,  cint32_T* B);

void matrix_conj_3x3_csingle( const creal32_T* A, creal32_T* B);
void matrix_conj_3x3_cdouble(   const creal_T* A,   creal_T* B);
void matrix_conj_3x3_cint8(     const cint8_T* A,   cint8_T* B);
void matrix_conj_3x3_cint16(   const cint16_T* A,  cint16_T* B);
void matrix_conj_3x3_cint32(   const cint32_T* A,  cint32_T* B);


void matrix_conj_4x4_csingle( const creal32_T* A, creal32_T* B);
void matrix_conj_4x4_cdouble(   const creal_T* A,   creal_T* B);
void matrix_conj_4x4_cint8(     const cint8_T* A,   cint8_T* B);
void matrix_conj_4x4_cint16(   const cint16_T* A,  cint16_T* B);
void matrix_conj_4x4_cint32(   const cint32_T* A,  cint32_T* B);


#endif

#ifdef CREAL_T

void matrix_herm_2x2_csingle( const creal32_T* A, creal32_T* B);
void matrix_herm_2x2_cdouble(   const creal_T* A,   creal_T* B);
void matrix_herm_2x2_cint8(     const cint8_T* A,   cint8_T* B);
void matrix_herm_2x2_cint16(   const cint16_T* A,  cint16_T* B);
void matrix_herm_2x2_cint32(   const cint32_T* A,  cint32_T* B);


void matrix_herm_3x3_csingle( const creal32_T* A, creal32_T* B);
void matrix_herm_3x3_cdouble(   const creal_T* A,   creal_T* B);
void matrix_herm_3x3_cint8(     const cint8_T* A,   cint8_T* B);
void matrix_herm_3x3_cint16(   const cint16_T* A,  cint16_T* B);
void matrix_herm_3x3_cint32(   const cint32_T* A,  cint32_T* B);


void matrix_herm_4x4_csingle( const creal32_T* A, creal32_T* B);
void matrix_herm_4x4_cdouble(   const creal_T* A,   creal_T* B);
void matrix_herm_4x4_cint8(     const cint8_T* A,   cint8_T* B);
void matrix_herm_4x4_cint16(   const cint16_T* A,  cint16_T* B);
void matrix_herm_4x4_cint32(   const cint32_T* A,  cint32_T* B);


#endif


#ifdef __cplusplus
}
#endif

#endif
