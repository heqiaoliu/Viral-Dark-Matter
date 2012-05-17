/* Copyright 2006 The MathWorks, Inc. */

/* $Revision: 1.1.6.1 $ */

#include "ndarray_ops.h"

void array3d_add(real_T *y1, real_T *u1, real_T *u2, int32_T nbRows, int32_T nbCols, int32_T nbPages) {
    int32_T i;
    int32_T nb = nbRows*nbCols*nbPages;

    for (i=0; i<nb; i++)
            /* SL matrix are column major order */
            *y1++ = *u1++ + *u2++;
}
