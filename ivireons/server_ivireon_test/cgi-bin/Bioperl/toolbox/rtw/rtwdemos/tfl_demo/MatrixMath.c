/* Copyright 2008-2009 The MathWorks, Inc. */
#include "MatrixMath.h"

#define DO_ADD_2X2(A,B,C)     (C)[0] = ((A)[0] + (B)[0]);\
                              (C)[1] = ((A)[1] + (B)[1]);\
                              (C)[2] = ((A)[2] + (B)[2]);\
                              (C)[3] = ((A)[3] + (B)[3]);
                              
#define DO_ADD_3X3(A,B,C)     (C)[0] = ((A)[0] + (B)[0]);\
                              (C)[1] = ((A)[1] + (B)[1]);\
                              (C)[2] = ((A)[2] + (B)[2]);\
                              (C)[3] = ((A)[3] + (B)[3]);\
                              (C)[4] = ((A)[4] + (B)[4]);\
                              (C)[5] = ((A)[5] + (B)[5]);\
                              (C)[6] = ((A)[6] + (B)[6]);\
                              (C)[7] = ((A)[7] + (B)[7]);\
                              (C)[8] = ((A)[8] + (B)[8]);
                              
#define DO_ADD_4X4(A,B,C)     (C)[0] = ((A)[0] + (B)[0]);\
                              (C)[1] = ((A)[1] + (B)[1]);\
                              (C)[2] = ((A)[2] + (B)[2]);\
                              (C)[3] = ((A)[3] + (B)[3]);\
                              (C)[4] = ((A)[4] + (B)[4]);\
                              (C)[5] = ((A)[5] + (B)[5]);\
                              (C)[6] = ((A)[6] + (B)[6]);\
                              (C)[7] = ((A)[7] + (B)[7]);\
                              (C)[8] = ((A)[8] + (B)[8]);\
                              (C)[9] = ((A)[9] + (B)[9]);\
                              (C)[10] = ((A)[10] + (B)[10]);\
                              (C)[11] = ((A)[11] + (B)[11]);\
                              (C)[12] = ((A)[12] + (B)[12]);\
                              (C)[13] = ((A)[13] + (B)[13]);\
                              (C)[14] = ((A)[14] + (B)[14]);\
                              (C)[15] = ((A)[15] + (B)[15]);
                              
#define DO_CADD_2X2(A,B,C)    (C)[0].re = ((A)[0].re + (B)[0].re);\
                              (C)[1].re = ((A)[1].re + (B)[1].re);\
                              (C)[2].re = ((A)[2].re + (B)[2].re);\
                              (C)[3].re = ((A)[3].re + (B)[3].re);\
                              (C)[0].im = ((A)[0].im + (B)[0].im);\
                              (C)[1].im = ((A)[1].im + (B)[1].im);\
                              (C)[2].im = ((A)[2].im + (B)[2].im);\
                              (C)[3].im = ((A)[3].im + (B)[3].im);
                              
#define DO_CADD_3X3(A,B,C)    DO_CADD_2X2(A,B,C);\
                              (C)[4].re = ((A)[4].re + (B)[4].re);   \
                              (C)[5].re = ((A)[5].re + (B)[5].re);   \
                              (C)[6].re = ((A)[6].re + (B)[6].re);   \
                              (C)[7].re = ((A)[7].re + (B)[7].re);   \
                              (C)[8].re = ((A)[8].re + (B)[8].re);   \
                              (C)[4].im = ((A)[4].im + (B)[4].im);   \
                              (C)[5].im = ((A)[5].im + (B)[5].im);   \
                              (C)[6].im = ((A)[6].im + (B)[6].im);   \
                              (C)[7].im = ((A)[7].im + (B)[7].im);   \
                              (C)[8].im = ((A)[8].im + (B)[8].im);

#define DO_CADD_4X4(A,B,C)    DO_CADD_3X3(A,B,C);                    \
                              (C)[9].re = ((A)[9].re + (B)[9].re);   \
                              (C)[10].re = ((A)[10].re + (B)[10].re);\
                              (C)[11].re = ((A)[11].re + (B)[11].re);\
                              (C)[12].re = ((A)[12].re + (B)[12].re);\
                              (C)[13].re = ((A)[13].re + (B)[13].re);\
                              (C)[14].re = ((A)[14].re + (B)[14].re);\
                              (C)[15].re = ((A)[15].re + (B)[15].re);\
                              (C)[9].im = ((A)[9].im + (B)[9].im);   \
                              (C)[10].im = ((A)[10].im + (B)[10].im);\
                              (C)[11].im = ((A)[11].im + (B)[11].im);\
                              (C)[12].im = ((A)[12].im + (B)[12].im);\
                              (C)[13].im = ((A)[13].im + (B)[13].im);\
                              (C)[14].im = ((A)[14].im + (B)[14].im);\
                              (C)[15].im = ((A)[15].im + (B)[15].im);

#define DO_SUB_2X2(A,B,C)     (C)[0] = ((A)[0] - (B)[0]);\
                              (C)[1] = ((A)[1] - (B)[1]);\
                              (C)[2] = ((A)[2] - (B)[2]);\
                              (C)[3] = ((A)[3] - (B)[3]);
                              
#define DO_SUB_3X3(A,B,C)     (C)[0] = ((A)[0] - (B)[0]);\
                              (C)[1] = ((A)[1] - (B)[1]);\
                              (C)[2] = ((A)[2] - (B)[2]);\
                              (C)[3] = ((A)[3] - (B)[3]);\
                              (C)[4] = ((A)[4] - (B)[4]);\
                              (C)[5] = ((A)[5] - (B)[5]);\
                              (C)[6] = ((A)[6] - (B)[6]);\
                              (C)[7] = ((A)[7] - (B)[7]);\
                              (C)[8] = ((A)[8] - (B)[8]);
                              
#define DO_SUB_4X4(A,B,C)     (C)[0] = ((A)[0] - (B)[0]);\
                              (C)[1] = ((A)[1] - (B)[1]);\
                              (C)[2] = ((A)[2] - (B)[2]);\
                              (C)[3] = ((A)[3] - (B)[3]);\
                              (C)[4] = ((A)[4] - (B)[4]);\
                              (C)[5] = ((A)[5] - (B)[5]);\
                              (C)[6] = ((A)[6] - (B)[6]);\
                              (C)[7] = ((A)[7] - (B)[7]);\
                              (C)[8] = ((A)[8] - (B)[8]);\
                              (C)[9] = ((A)[9] - (B)[9]);\
                              (C)[10] = ((A)[10] - (B)[10]);\
                              (C)[11] = ((A)[11] - (B)[11]);\
                              (C)[12] = ((A)[12] - (B)[12]);\
                              (C)[13] = ((A)[13] - (B)[13]);\
                              (C)[14] = ((A)[14] - (B)[14]);\
                              (C)[15] = ((A)[15] - (B)[15]);
                                      
#define DO_CSUB_2X2(A,B,C)    (C)[0].re = ((A)[0].re - (B)[0].re);\
                              (C)[1].re = ((A)[1].re - (B)[1].re);\
                              (C)[2].re = ((A)[2].re - (B)[2].re);\
                              (C)[3].re = ((A)[3].re - (B)[3].re);\
                              (C)[0].im = ((A)[0].im - (B)[0].im);\
                              (C)[1].im = ((A)[1].im - (B)[1].im);\
                              (C)[2].im = ((A)[2].im - (B)[2].im);\
                              (C)[3].im = ((A)[3].im - (B)[3].im);
                              
#define DO_CSUB_3X3(A,B,C)    DO_CSUB_2X2(A,B,C);                    \
                              (C)[4].re = ((A)[4].re - (B)[4].re);   \
                              (C)[5].re = ((A)[5].re - (B)[5].re);   \
                              (C)[6].re = ((A)[6].re - (B)[6].re);   \
                              (C)[7].re = ((A)[7].re - (B)[7].re);   \
                              (C)[8].re = ((A)[8].re - (B)[8].re);   \
                              (C)[4].im = ((A)[4].im - (B)[4].im);   \
                              (C)[5].im = ((A)[5].im - (B)[5].im);   \
                              (C)[6].im = ((A)[6].im - (B)[6].im);   \
                              (C)[7].im = ((A)[7].im - (B)[7].im);   \
                              (C)[8].im = ((A)[8].im - (B)[8].im);

#define DO_CSUB_4X4(A,B,C)    DO_CSUB_3X3(A,B,C);                    \
                              (C)[9].re = ((A)[9].re - (B)[9].re);   \
                              (C)[10].re = ((A)[10].re - (B)[10].re);\
                              (C)[11].re = ((A)[11].re - (B)[11].re);\
                              (C)[12].re = ((A)[12].re - (B)[12].re);\
                              (C)[13].re = ((A)[13].re - (B)[13].re);\
                              (C)[14].re = ((A)[14].re - (B)[14].re);\
                              (C)[15].re = ((A)[15].re - (B)[15].re);\
                              (C)[9].im = ((A)[9].im - (B)[9].im);   \
                              (C)[10].im = ((A)[10].im - (B)[10].im);\
                              (C)[11].im = ((A)[11].im - (B)[11].im);\
                              (C)[12].im = ((A)[12].im - (B)[12].im);\
                              (C)[13].im = ((A)[13].im - (B)[13].im);\
                              (C)[14].im = ((A)[14].im - (B)[14].im);\
                              (C)[15].im = ((A)[15].im - (B)[15].im);

#define DO_TRANS_3X3(A,B,T)     {\
    (B)[0] = (A)[0];\
    (T)    = (A)[1];\
    (B)[1] = (A)[3];\
    (B)[3] = (T);   \
    (T)    = (A)[2];\
    (B)[2] = (A)[6];\
    (B)[6] = (T);   \
    (B)[4] = (A)[4];\
    (T)    = (A)[5];\
    (B)[5] = (A)[7];\
    (B)[7] = (T);   \
    (B)[8] = (A)[8];\
    }
                              
#define DO_TRANS_2X2(A,B,T)     {\
    (B)[0] = (A)[0];\
    (T)    = (A)[1];\
    (B)[1] = (A)[2];\
    (B)[2] = (T);   \
    (B)[3] = (A)[3];\
    }

#define DO_TRANS(A,B,R,C)  {\
      uint32_T count = 0;\
      uint32_T row;\
      uint32_T col;\
      for (row= 0; row < (R); row++) {\
        for (col= 0; col < (C); col++) {\
          (B)[row + (R) * col] = (A)[count];\
          count++;\
        }\
      }\
    }

#define DO_CCONJ_2X2(A,C)    (C)[0].re = (A)[0].re ;\
                             (C)[1].re = (A)[1].re ;\
                             (C)[2].re = (A)[2].re ;\
                             (C)[3].re = (A)[3].re ;\
                             (C)[0].im = -(A)[0].im;\
                             (C)[1].im = -(A)[1].im;\
                             (C)[2].im = -(A)[2].im;\
                             (C)[3].im = -(A)[3].im;
                              
#define DO_CCONJ_3X3(A,C)    DO_CCONJ_2X2(A,C);     \
                             (C)[4].re = (A)[4].re; \
                             (C)[5].re = (A)[5].re; \
                             (C)[6].re = (A)[6].re; \
                             (C)[7].re = (A)[7].re; \
                             (C)[8].re = (A)[8].re; \
                             (C)[4].im = -(A)[4].im;\
                             (C)[5].im = -(A)[5].im;\
                             (C)[6].im = -(A)[6].im;\
                             (C)[7].im = -(A)[7].im;\
                             (C)[8].im = -(A)[8].im;

#define DO_CCONJ_4X4(A,C)    DO_CCONJ_3X3(A,C);     \
                             (C)[9].re = (A)[9].re; \
                             (C)[10].re = (A)[10].re;\
                             (C)[11].re = (A)[11].re;\
                             (C)[12].re = (A)[12].re;\
                             (C)[13].re = (A)[13].re;\
                             (C)[14].re = (A)[14].re;\
                             (C)[15].re = (A)[15].re;\
                             (C)[9].im = -(A)[9].im; \
                             (C)[10].im = -(A)[10].im;\
                             (C)[11].im = -(A)[11].im;\
                             (C)[12].im = -(A)[12].im;\
                             (C)[13].im = -(A)[13].im;\
                             (C)[14].im = -(A)[14].im;\
                             (C)[15].im = -(A)[15].im;


#define DO_HERM_3X3(A,B,T)     {\
    (B)[0].re = (A)[0].re;\
    (T).re    = (A)[1].re;\
    (B)[1].re = (A)[3].re;\
    (B)[3].re = (T).re;   \
    (T).re    = (A)[2].re;\
    (B)[2].re = (A)[6].re;\
    (B)[6].re = (T).re;   \
    (B)[4].re = (A)[4].re;\
    (T).re   = (A)[5].re;\
    (B)[5].re = (A)[7].re;\
    (B)[7].re = (T).re;   \
    (B)[8].re = (A)[8].re;\
    (B)[0].im = -(A)[0].im;\
    (T).im    = -(A)[1].im;\
    (B)[1].im = -(A)[3].im;\
    (B)[3].im = (T).im;   \
    (T).im   = -(A)[2].im;\
    (B)[2].im = -(A)[6].im;\
    (B)[6].im = (T).im;   \
    (B)[4].im = -(A)[4].im;\
    (T).im    = -(A)[5].im;\
    (B)[5].im = -(A)[7].im;\
    (B)[7].im = (T).im;   \
    (B)[8].im = -(A)[8].im;\
   }
                              
#define DO_HERM_2X2(A,B,T)     {\
    (B)[0].re = (A)[0].re;\
    (T).re    = (A)[1].re;\
    (B)[1].re = (A)[2].re;\
    (B)[2].re = (T).re;   \
    (B)[3].re = (A)[3].re;\
    (B)[0].im = -(A)[0].im;\
    (T).im    = -(A)[1].im;\
    (B)[1].im = -(A)[2].im;\
    (B)[2].im = (T).im;   \
    (B)[3].im = -(A)[3].im;\
    }

#define DO_HERM(A,B,R,C)  {\
      uint32_T count = 0;\
      uint32_T row;\
      uint32_T col;\
      for (row= 0; row < (R); row++) {\
        for (col= 0; col < (C); col++) {\
          (B)[row + (R) * col].re = (A)[count].re;\
          (B)[row + (R) * col].im = -(A)[count].im;\
          count++;\
        }\
      }\
    }




/* Definitions for ... */
void matrix_sum_2x2_single( const real32_T* A, const real32_T* B, real32_T* C)
{DO_ADD_2X2(A,B,C);}

void matrix_sum_2x2_double( const real_T* A, const real_T* B, real_T* C)
{DO_ADD_2X2(A,B,C);}

void matrix_sum_2x2_int8( const int8_T* A, const int8_T* B, int8_T* C)
{DO_ADD_2X2(A,B,C);}

void matrix_sum_2x2_int16( const int16_T* A, const int16_T* B, int16_T* C)
{DO_ADD_2X2(A,B,C);}

void matrix_sum_2x2_int32( const int32_T* A, const int32_T* B, int32_T* C)
{DO_ADD_2X2(A,B,C);}

void matrix_sum_2x2_uint8( const uint8_T* A, const uint8_T* B, uint8_T* C)
{DO_ADD_2X2(A,B,C);}

void matrix_sum_2x2_uint16( const uint16_T* A, const uint16_T* B, uint16_T* C)
{DO_ADD_2X2(A,B,C);}

void matrix_sum_2x2_uint32( const uint32_T* A, const uint32_T* B, uint32_T* C)
{DO_ADD_2X2(A,B,C);}

void matrix_sum_3x3_single( const real32_T* A, const real32_T* B, real32_T* C)
{DO_ADD_3X3(A,B,C);}

void matrix_sum_3x3_double( const real_T* A, const real_T* B, real_T* C)
{DO_ADD_3X3(A,B,C);}

void matrix_sum_3x3_int8( const int8_T* A, const int8_T* B, int8_T* C)
{DO_ADD_3X3(A,B,C);}

void matrix_sum_3x3_int16( const int16_T* A, const int16_T* B, int16_T* C)
{DO_ADD_3X3(A,B,C);}

void matrix_sum_3x3_int32( const int32_T* A, const int32_T* B, int32_T* C)
{DO_ADD_3X3(A,B,C);}

void matrix_sum_3x3_uint8( const uint8_T* A, const uint8_T* B, uint8_T* C)
{DO_ADD_3X3(A,B,C);}

void matrix_sum_3x3_uint16( const uint16_T* A, const uint16_T* B, uint16_T* C)
{DO_ADD_3X3(A,B,C);}

void matrix_sum_3x3_uint32( const uint32_T* A, const uint32_T* B, uint32_T* C)
{DO_ADD_3X3(A,B,C);}

void matrix_sum_3x3_int8_int16(  const int8_T* A,   const int16_T* B,  int16_T* C)
{DO_ADD_3X3(A,B,C);}

void matrix_sum_3x3_int16_int8(  const int16_T* A,  const int8_T* B,   int16_T* C)
{DO_ADD_3X3(A,B,C);}

void matrix_sum_3x3_int8_int32(  const int8_T* A,   const int32_T* B,  int32_T* C)
{DO_ADD_3X3(A,B,C);}

void matrix_sum_3x3_int32_int8(  const int32_T* A,  const int8_T* B,   int32_T* C)
{DO_ADD_3X3(A,B,C);}

void matrix_sum_3x3_int16_int32( const int16_T* A,  const int32_T* B,  int32_T* C)
{DO_ADD_3X3(A,B,C);}

void matrix_sum_3x3_int32_int16( const int32_T* A,  const int16_T* B,  int32_T* C)
{DO_ADD_3X3(A,B,C);}

void matrix_sum_3x3_single_double(const real32_T* A, const real_T* B,   real_T* C)
{DO_ADD_3X3(A,B,C);}

void matrix_sum_3x3_double_single(const real_T* A,   const real32_T* B, real_T* C)
{DO_ADD_3X3(A,B,C);}

void matrix_sum_4x4_single( const real32_T* A, const real32_T* B, real32_T* C)
{DO_ADD_4X4(A,B,C);}

void matrix_sum_4x4_double( const real_T* A, const real_T* B, real_T* C)
{DO_ADD_4X4(A,B,C);}

void matrix_sum_4x4_int8( const int8_T* A, const int8_T* B, int8_T* C)
{DO_ADD_4X4(A,B,C);}

void matrix_sum_4x4_int16( const int16_T* A, const int16_T* B, int16_T* C)
{DO_ADD_4X4(A,B,C);}

void matrix_sum_4x4_int32( const int32_T* A, const int32_T* B, int32_T* C)
{DO_ADD_4X4(A,B,C);}

void matrix_sum_4x4_uint8( const uint8_T* A, const uint8_T* B, uint8_T* C)
{DO_ADD_4X4(A,B,C);}

void matrix_sum_4x4_uint16( const uint16_T* A, const uint16_T* B, uint16_T* C)
{DO_ADD_4X4(A,B,C);}

void matrix_sum_4x4_uint32( const uint32_T* A, const uint32_T* B, uint32_T* C)
{DO_ADD_4X4(A,B,C);}

void matrix_sub_2x2_single( const real32_T* A, const real32_T* B, real32_T* C)
{DO_SUB_2X2(A,B,C);}

void matrix_sub_2x2_double( const real_T* A, const real_T* B, real_T* C)
{DO_SUB_2X2(A,B,C);}

void matrix_sub_2x2_int8( const int8_T* A, const int8_T* B, int8_T* C)
{DO_SUB_2X2(A,B,C);}

void matrix_sub_2x2_int16( const int16_T* A, const int16_T* B, int16_T* C)
{DO_SUB_2X2(A,B,C);}

void matrix_sub_2x2_int32( const int32_T* A, const int32_T* B, int32_T* C)
{DO_SUB_2X2(A,B,C);}

void matrix_sub_2x2_uint8( const uint8_T* A, const uint8_T* B, uint8_T* C)
{DO_SUB_2X2(A,B,C);}

void matrix_sub_2x2_uint16( const uint16_T* A, const uint16_T* B, uint16_T* C)
{DO_SUB_2X2(A,B,C);}

void matrix_sub_2x2_uint32( const uint32_T* A, const uint32_T* B, uint32_T* C)
{DO_SUB_2X2(A,B,C);}

void matrix_sub_3x3_single( const real32_T* A, const real32_T* B, real32_T* C)
{DO_SUB_3X3(A,B,C);}

void matrix_sub_3x3_double( const real_T* A, const real_T* B, real_T* C)
{DO_SUB_3X3(A,B,C);}

void matrix_sub_3x3_int8( const int8_T* A, const int8_T* B, int8_T* C)
{DO_SUB_3X3(A,B,C);}

void matrix_sub_3x3_int16( const int16_T* A, const int16_T* B, int16_T* C)
{DO_SUB_3X3(A,B,C);}

void matrix_sub_3x3_int32( const int32_T* A, const int32_T* B, int32_T* C)
{DO_SUB_3X3(A,B,C);}

void matrix_sub_3x3_uint8( const uint8_T* A, const uint8_T* B, uint8_T* C)
{DO_SUB_3X3(A,B,C);}

void matrix_sub_3x3_uint16( const uint16_T* A, const uint16_T* B, uint16_T* C)
{DO_SUB_3X3(A,B,C);}

void matrix_sub_3x3_uint32( const uint32_T* A, const uint32_T* B, uint32_T* C)
{DO_SUB_3X3(A,B,C);}

void matrix_sub_3x3_int8_int16(  const int8_T* A,   const int16_T* B,  int16_T* C)
{DO_SUB_3X3(A,B,C);}

void matrix_sub_3x3_int16_int8(  const int16_T* A,  const int8_T* B,   int16_T* C)
{DO_SUB_3X3(A,B,C);}

void matrix_sub_3x3_int8_int32(  const int8_T* A,   const int32_T* B,  int32_T* C)
{DO_SUB_3X3(A,B,C);}

void matrix_sub_3x3_int32_int8(  const int32_T* A,  const int8_T* B,   int32_T* C)
{DO_SUB_3X3(A,B,C);}

void matrix_sub_3x3_int16_int32( const int16_T* A,  const int32_T* B,  int32_T* C)
{DO_SUB_3X3(A,B,C);}

void matrix_sub_3x3_int32_int16( const int32_T* A,  const int16_T* B,  int32_T* C)
{DO_SUB_3X3(A,B,C);}

void matrix_sub_3x3_single_double(const real32_T* A, const real_T* B,   real_T* C)
{DO_SUB_3X3(A,B,C);}

void matrix_sub_3x3_double_single(const real_T* A,   const real32_T* B, real_T* C)
{DO_SUB_3X3(A,B,C);}


void matrix_sub_4x4_single( const real32_T* A, const real32_T* B, real32_T* C)
{DO_SUB_4X4(A,B,C);}

void matrix_sub_4x4_double( const real_T* A, const real_T* B, real_T* C)
{DO_SUB_4X4(A,B,C);}

void matrix_sub_4x4_int8( const int8_T* A, const int8_T* B, int8_T* C)
{DO_SUB_4X4(A,B,C);}

void matrix_sub_4x4_int16( const int16_T* A, const int16_T* B, int16_T* C)
{DO_SUB_4X4(A,B,C);}

void matrix_sub_4x4_int32( const int32_T* A, const int32_T* B, int32_T* C)
{DO_SUB_4X4(A,B,C);}

void matrix_sub_4x4_uint8( const uint8_T* A, const uint8_T* B, uint8_T* C)
{DO_SUB_4X4(A,B,C);}

void matrix_sub_4x4_uint16( const uint16_T* A, const uint16_T* B, uint16_T* C)
{DO_SUB_4X4(A,B,C);}

void matrix_sub_4x4_uint32( const uint32_T* A, const uint32_T* B, uint32_T* C)
{DO_SUB_4X4(A,B,C);}

void matrix_trans_2x2_single( const real32_T* A, real32_T* B)
{real32_T t; DO_TRANS_2X2(A, B, t);}

void matrix_trans_2x2_double( const real_T* A, real_T* B)
{real_T t; DO_TRANS_2X2(A, B, t);}

void matrix_trans_2x2_int8( const int8_T* A, int8_T* B)
{int8_T t; DO_TRANS_2X2(A, B, t);}

void matrix_trans_2x2_int16( const int16_T* A, int16_T* B)
{int16_T t; DO_TRANS_2X2(A, B, t);}

void matrix_trans_2x2_int32( const int32_T* A, int32_T* B)
{int32_T t; DO_TRANS_2X2(A, B, t);}

void matrix_trans_2x2_uint8( const uint8_T* A, uint8_T* B)
{uint8_T t; DO_TRANS_2X2(A, B, t);}

void matrix_trans_2x2_uint16( const uint16_T* A, uint16_T* B)
{uint16_T t; DO_TRANS_2X2(A, B, t);}

void matrix_trans_2x2_uint32( const uint32_T* A, uint32_T* B)
{uint32_T t; DO_TRANS_2X2(A, B, t);}

void matrix_trans_3x3_single( const real32_T* A, real32_T* B)
{real32_T t; DO_TRANS_3X3(A, B, t);}

void matrix_trans_3x3_double( const real_T* A, real_T* B)
{real_T t; DO_TRANS_3X3(A, B, t);}

void matrix_trans_3x3_int8( const int8_T* A, int8_T* B)
{int8_T t; DO_TRANS_3X3(A, B, t);}

void matrix_trans_3x3_int16( const int16_T* A, int16_T* B)
{int16_T t; DO_TRANS_3X3(A, B, t);}

void matrix_trans_3x3_int32( const int32_T* A, int32_T* B)
{int32_T t; DO_TRANS_3X3(A, B, t);}

void matrix_trans_3x3_uint8( const uint8_T* A, uint8_T* B)
{uint8_T t; DO_TRANS_3X3(A, B, t);}

void matrix_trans_3x3_uint16( const uint16_T* A, uint16_T* B)
{uint16_T t; DO_TRANS_3X3(A, B, t);}

void matrix_trans_3x3_uint32( const uint32_T* A, uint32_T* B)
{uint32_T t; DO_TRANS_3X3(A, B, t);}

void matrix_trans_4x4_single( const real32_T* A, real32_T* B)
{DO_TRANS(A, B, 4, 4);}

void matrix_trans_4x4_double( const real_T* A, real_T* B)
{DO_TRANS(A, B, 4, 4);}

void matrix_trans_4x4_int8( const int8_T* A, int8_T* B)
{DO_TRANS(A, B, 4, 4);}

void matrix_trans_4x4_int16( const int16_T* A, int16_T* B)
{DO_TRANS(A, B, 4, 4);}

void matrix_trans_4x4_int32( const int32_T* A, int32_T* B)
{DO_TRANS(A, B, 4, 4);}

void matrix_trans_4x4_uint8( const uint8_T* A, uint8_T* B)
{DO_TRANS(A, B, 4, 4);}

void matrix_trans_4x4_uint16( const uint16_T* A, uint16_T* B)
{DO_TRANS(A, B, 4, 4);}

void matrix_trans_4x4_uint32( const uint32_T* A, uint32_T* B)
{DO_TRANS(A, B, 4, 4);}


#ifdef CREAL_T
void matrix_trans_2x2_csingle( const creal32_T* A, creal32_T* B)
{creal32_T t; DO_TRANS_2X2(A, B, t);}

void matrix_trans_2x2_cdouble( const creal_T* A, creal_T* B)
{creal_T t; DO_TRANS_2X2(A, B, t);}

void matrix_trans_2x2_cint8( const cint8_T* A, cint8_T* B)
{cint8_T t; DO_TRANS_2X2(A, B, t);}

void matrix_trans_2x2_cint16( const cint16_T* A, cint16_T* B)
{cint16_T t; DO_TRANS_2X2(A, B, t);}

void matrix_trans_2x2_cint32( const cint32_T* A, cint32_T* B)
{cint32_T t; DO_TRANS_2X2(A, B, t);}

void matrix_trans_2x2_cuint8( const cuint8_T* A, cuint8_T* B)
{cuint8_T t; DO_TRANS_2X2(A, B, t);}

void matrix_trans_2x2_cuint16( const cuint16_T* A, cuint16_T* B)
{cuint16_T t; DO_TRANS_2X2(A, B, t);}

void matrix_trans_2x2_cuint32( const cuint32_T* A, cuint32_T* B)
{cuint32_T t; DO_TRANS_2X2(A, B, t);}

void matrix_trans_3x3_csingle( const creal32_T* A, creal32_T* B)
{creal32_T t; DO_TRANS_3X3(A, B, t);}

void matrix_trans_3x3_cdouble( const creal_T* A, creal_T* B)
{creal_T t; DO_TRANS_3X3(A, B, t);}

void matrix_trans_3x3_cint8( const cint8_T* A, cint8_T* B)
{cint8_T t; DO_TRANS_3X3(A, B, t);}

void matrix_trans_3x3_cint16( const cint16_T* A, cint16_T* B)
{cint16_T t; DO_TRANS_3X3(A, B, t);}

void matrix_trans_3x3_cint32( const cint32_T* A, cint32_T* B)
{cint32_T t; DO_TRANS_3X3(A, B, t);}

void matrix_trans_3x3_cuint8( const cuint8_T* A, cuint8_T* B)
{cuint8_T t; DO_TRANS_3X3(A, B, t);}

void matrix_trans_3x3_cuint16( const cuint16_T* A, cuint16_T* B)
{cuint16_T t; DO_TRANS_3X3(A, B, t);}

void matrix_trans_3x3_cuint32( const cuint32_T* A, cuint32_T* B)
{cuint32_T t; DO_TRANS_3X3(A, B, t);}

void matrix_trans_4x4_csingle( const creal32_T* A, creal32_T* B)
{DO_TRANS(A, B, 4, 4);}

void matrix_trans_4x4_cdouble( const creal_T* A, creal_T* B)
{DO_TRANS(A, B, 4, 4);}

void matrix_trans_4x4_cint8( const cint8_T* A, cint8_T* B)
{DO_TRANS(A, B, 4, 4);}

void matrix_trans_4x4_cint16( const cint16_T* A, cint16_T* B)
{DO_TRANS(A, B, 4, 4);}

void matrix_trans_4x4_cint32( const cint32_T* A, cint32_T* B)
{DO_TRANS(A, B, 4, 4);}

void matrix_trans_4x4_cuint8( const cuint8_T* A, cuint8_T* B)
{DO_TRANS(A, B, 4, 4);}

void matrix_trans_4x4_cuint16( const cuint16_T* A, cuint16_T* B)
{DO_TRANS(A, B, 4, 4);}

void matrix_trans_4x4_cuint32( const cuint32_T* A, cuint32_T* B)
{DO_TRANS(A, B, 4, 4);}

void matrix_sum_2x2_csingle( const creal32_T* A, const creal32_T* B, creal32_T* C)
{DO_CADD_2X2(A,B,C);}

void matrix_sum_2x2_cdouble(const creal_T* A, const creal_T* B, creal_T* C)
{DO_CADD_2X2(A, B, C);}

void matrix_sum_2x2_cint8( const cint8_T* A, const cint8_T* B, cint8_T* C)
{DO_CADD_2X2(A,B,C);}

void matrix_sum_2x2_cint16( const cint16_T* A, const cint16_T* B, cint16_T* C)
{DO_CADD_2X2(A,B,C);}

void matrix_sum_2x2_cint32( const cint32_T* A, const cint32_T* B, cint32_T* C)
{DO_CADD_2X2(A,B,C);}

void matrix_sum_2x2_cuint8( const cuint8_T* A, const cuint8_T* B, cuint8_T* C)
{DO_CADD_2X2(A,B,C);}

void matrix_sum_2x2_cuint16( const cuint16_T* A, const cuint16_T* B, cuint16_T* C)
{DO_CADD_2X2(A,B,C);}

void matrix_sum_2x2_cuint32( const cuint32_T* A, const cuint32_T* B, cuint32_T* C)
{DO_CADD_2X2(A,B,C);}

void matrix_sum_3x3_csingle( const creal32_T* A, const creal32_T* B, creal32_T* C)
{DO_CADD_3X3(A,B,C);}

void matrix_sum_3x3_cdouble(const creal_T* A, const creal_T* B, creal_T* C)
{DO_CADD_3X3(A, B, C);}

void matrix_sum_3x3_cint8( const cint8_T* A, const cint8_T* B, cint8_T* C)
{DO_CADD_3X3(A,B,C);}

void matrix_sum_3x3_cint16( const cint16_T* A, const cint16_T* B, cint16_T* C)
{DO_CADD_3X3(A,B,C);}

void matrix_sum_3x3_cint32( const cint32_T* A, const cint32_T* B, cint32_T* C)
{DO_CADD_3X3(A,B,C);}

void matrix_sum_3x3_cuint8( const cuint8_T* A, const cuint8_T* B, cuint8_T* C)
{DO_CADD_3X3(A,B,C);}

void matrix_sum_3x3_cuint16( const cuint16_T* A, const cuint16_T* B, cuint16_T* C)
{DO_CADD_3X3(A,B,C);}

void matrix_sum_3x3_cuint32( const cuint32_T* A, const cuint32_T* B, cuint32_T* C)
{DO_CADD_3X3(A,B,C);}

void matrix_sum_4x4_csingle( const creal32_T* A, const creal32_T* B, creal32_T* C)
{DO_CADD_4X4(A,B,C);}

void matrix_sum_4x4_cdouble(const creal_T* A, const creal_T* B, creal_T* C)
{DO_CADD_4X4(A, B, C);}

void matrix_sum_4x4_cint8( const cint8_T* A, const cint8_T* B, cint8_T* C)
{DO_CADD_4X4(A,B,C);}

void matrix_sum_4x4_cint16( const cint16_T* A, const cint16_T* B, cint16_T* C)
{DO_CADD_4X4(A,B,C);}

void matrix_sum_4x4_cint32( const cint32_T* A, const cint32_T* B, cint32_T* C)
{DO_CADD_4X4(A,B,C);}

void matrix_sum_4x4_cuint8( const cuint8_T* A, const cuint8_T* B, cuint8_T* C)
{DO_CADD_4X4(A,B,C);}

void matrix_sum_4x4_cuint16( const cuint16_T* A, const cuint16_T* B, cuint16_T* C)
{DO_CADD_4X4(A,B,C);}

void matrix_sum_4x4_cuint32( const cuint32_T* A, const cuint32_T* B, cuint32_T* C)
{DO_CADD_4X4(A,B,C);}

void matrix_sub_2x2_csingle( const creal32_T* A, const creal32_T* B, creal32_T* C)
{DO_CSUB_2X2(A,B,C);}

void matrix_sub_2x2_cdouble( const creal_T* A,  const creal_T* B,  creal_T* C)
{DO_CSUB_2X2(A, B, C);}

void matrix_sub_2x2_cint8( const cint8_T* A, const cint8_T* B, cint8_T* C)
{DO_CSUB_2X2(A,B,C);}

void matrix_sub_2x2_cint16( const cint16_T* A, const cint16_T* B, cint16_T* C)
{DO_CSUB_2X2(A,B,C);}

void matrix_sub_2x2_cint32( const cint32_T* A, const cint32_T* B, cint32_T* C)
{DO_CSUB_2X2(A,B,C);}

void matrix_sub_2x2_cuint8( const cuint8_T* A, const cuint8_T* B, cuint8_T* C)
{DO_CSUB_2X2(A,B,C);}

void matrix_sub_2x2_cuint16( const cuint16_T* A, const cuint16_T* B, cuint16_T* C)
{DO_CSUB_2X2(A,B,C);}

void matrix_sub_2x2_cuint32( const cuint32_T* A, const cuint32_T* B, cuint32_T* C)
{DO_CSUB_2X2(A,B,C);}

void matrix_sub_3x3_csingle( const creal32_T* A, const creal32_T* B, creal32_T* C)
{DO_CSUB_3X3(A,B,C);}

void matrix_sub_3x3_cdouble( const creal_T* A,  const creal_T* B,  creal_T* C)
{DO_CSUB_3X3(A, B, C);}

void matrix_sub_3x3_cint8( const cint8_T* A, const cint8_T* B, cint8_T* C)
{DO_CSUB_3X3(A,B,C);}

void matrix_sub_3x3_cint16( const cint16_T* A, const cint16_T* B, cint16_T* C)
{DO_CSUB_3X3(A,B,C);}

void matrix_sub_3x3_cint32( const cint32_T* A, const cint32_T* B, cint32_T* C)
{DO_CSUB_3X3(A,B,C);}

void matrix_sub_3x3_cuint8( const cuint8_T* A, const cuint8_T* B, cuint8_T* C)
{DO_CSUB_3X3(A,B,C);}

void matrix_sub_3x3_cuint16( const cuint16_T* A, const cuint16_T* B, cuint16_T* C)
{DO_CSUB_3X3(A,B,C);}

void matrix_sub_3x3_cuint32( const cuint32_T* A, const cuint32_T* B, cuint32_T* C)
{DO_CSUB_3X3(A,B,C);}

void matrix_sub_4x4_csingle( const creal32_T* A, const creal32_T* B, creal32_T* C)
{DO_CSUB_4X4(A,B,C);}

void matrix_sub_4x4_cdouble( const creal_T* A,  const creal_T* B,  creal_T* C)
{DO_CSUB_4X4(A, B, C);}

void matrix_sub_4x4_cint8( const cint8_T* A, const cint8_T* B, cint8_T* C)
{DO_CSUB_4X4(A,B,C);}

void matrix_sub_4x4_cint16( const cint16_T* A, const cint16_T* B, cint16_T* C)
{DO_CSUB_4X4(A,B,C);}

void matrix_sub_4x4_cint32( const cint32_T* A, const cint32_T* B, cint32_T* C)
{DO_CSUB_4X4(A,B,C);}

void matrix_sub_4x4_cuint8( const cuint8_T* A, const cuint8_T* B, cuint8_T* C)
{DO_CSUB_4X4(A,B,C);}

void matrix_sub_4x4_cuint16( const cuint16_T* A, const cuint16_T* B, cuint16_T* C)
{DO_CSUB_4X4(A,B,C);}

void matrix_sub_4x4_cuint32( const cuint32_T* A, const cuint32_T* B, cuint32_T* C)
{DO_CSUB_4X4(A,B,C);}

void matrix_conj_2x2_csingle( const creal32_T* A, creal32_T* C)
{DO_CCONJ_2X2(A,C);}

void matrix_conj_2x2_cdouble( const creal_T* A,  creal_T* C)
{DO_CCONJ_2X2(A, C);}

void matrix_conj_2x2_cint8( const cint8_T* A, cint8_T* C)
{DO_CCONJ_2X2(A,C);}

void matrix_conj_2x2_cint16( const cint16_T* A, cint16_T* C)
{DO_CCONJ_2X2(A,C);}

void matrix_conj_2x2_cint32( const cint32_T* A, cint32_T* C)
{DO_CCONJ_2X2(A,C);}

void matrix_conj_3x3_csingle( const creal32_T* A, creal32_T* C)
{DO_CCONJ_3X3(A,C);}

void matrix_conj_3x3_cdouble( const creal_T* A,  creal_T* C)
{DO_CCONJ_3X3(A, C);}

void matrix_conj_3x3_cint8( const cint8_T* A, cint8_T* C)
{DO_CCONJ_3X3(A,C);}

void matrix_conj_3x3_cint16( const cint16_T* A, cint16_T* C)
{DO_CCONJ_3X3(A,C);}

void matrix_conj_3x3_cint32( const cint32_T* A, cint32_T* C)
{DO_CCONJ_3X3(A,C);}

void matrix_conj_4x4_csingle( const creal32_T* A, creal32_T* C)
{DO_CCONJ_4X4(A,C);}

void matrix_conj_4x4_cdouble( const creal_T* A,  creal_T* C)
{DO_CCONJ_4X4(A, C);}

void matrix_conj_4x4_cint8( const cint8_T* A, cint8_T* C)
{DO_CCONJ_4X4(A,C);}

void matrix_conj_4x4_cint16( const cint16_T* A, cint16_T* C)
{DO_CCONJ_4X4(A,C);}

void matrix_conj_4x4_cint32( const cint32_T* A, cint32_T* C)
{DO_CCONJ_4X4(A,C);}

void matrix_herm_2x2_csingle( const creal32_T* A, creal32_T* B)
{creal32_T t; DO_HERM_2X2(A, B, t);}

void matrix_herm_2x2_cdouble( const creal_T* A, creal_T* B)
{creal_T t; DO_HERM_2X2(A, B, t);}

void matrix_herm_2x2_cint8( const cint8_T* A, cint8_T* B)
{cint8_T t; DO_HERM_2X2(A, B, t);}

void matrix_herm_2x2_cint16( const cint16_T* A, cint16_T* B)
{cint16_T t; DO_HERM_2X2(A, B, t);}

void matrix_herm_2x2_cint32( const cint32_T* A, cint32_T* B)
{cint32_T t; DO_HERM_2X2(A, B, t);}

void matrix_herm_3x3_csingle( const creal32_T* A, creal32_T* B)
{creal32_T t; DO_HERM_3X3(A, B, t);}

void matrix_herm_3x3_cdouble( const creal_T* A, creal_T* B)
{creal_T t; DO_HERM_3X3(A, B, t);}

void matrix_herm_3x3_cint8( const cint8_T* A, cint8_T* B)
{cint8_T t; DO_HERM_3X3(A, B, t);}

void matrix_herm_3x3_cint16( const cint16_T* A, cint16_T* B)
{cint16_T t; DO_HERM_3X3(A, B, t);}

void matrix_herm_3x3_cint32( const cint32_T* A, cint32_T* B)
{cint32_T t; DO_HERM_3X3(A, B, t);}

void matrix_herm_4x4_csingle( const creal32_T* A, creal32_T* B)
{DO_HERM(A, B, 4, 4);}

void matrix_herm_4x4_cdouble( const creal_T* A, creal_T* B)
{DO_HERM(A, B, 4, 4);}

void matrix_herm_4x4_cint8( const cint8_T* A, cint8_T* B)
{DO_HERM(A, B, 4, 4);}

void matrix_herm_4x4_cint16( const cint16_T* A, cint16_T* B)
{DO_HERM(A, B, 4, 4);}

void matrix_herm_4x4_cint32( const cint32_T* A, cint32_T* B)
{DO_HERM(A, B, 4, 4);}

#endif
