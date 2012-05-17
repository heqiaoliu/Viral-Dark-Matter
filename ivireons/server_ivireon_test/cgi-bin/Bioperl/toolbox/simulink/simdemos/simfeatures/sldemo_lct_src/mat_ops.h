/* Copyright 2005-2006 The MathWorks, Inc. */

/* $Revision: 1.1.6.1 $ */

#ifndef _MAT_OPS_H_
#define _MAT_OPS_H_

#include "tmwtypes.h"

extern void mat_add(real_T *u1, real_T *u2, int32_T nbRows, int32_T nbCols, real_T *y1);
extern void mat_mult(real_T *u1, real_T *u2, int32_T nbRows1, int32_T nbCols1, int32_T nbCols2, real_T *y1);

#endif
