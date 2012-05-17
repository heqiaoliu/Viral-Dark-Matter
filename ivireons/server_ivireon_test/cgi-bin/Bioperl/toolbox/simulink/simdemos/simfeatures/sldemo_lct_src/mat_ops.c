/* Copyright 2005-2006 The MathWorks, Inc. */

/* $Revision: 1.1.6.1 $ */

#include "mat_ops.h"

void mat_add(real_T *u1, real_T *u2, int32_T nbRows, int32_T nbCols, real_T *y1) {
    int32_T i, j;

    for (i=0; i<nbRows; i++)
        for(j=0; j<nbCols; j++)
            /* SL matrix are column major order */
            y1[i+nbRows*j] = u1[i+nbRows*j] + u2[i+nbRows*j];
}


void mat_mult(real_T *u1, real_T *u2, int32_T nbRows1, int32_T nbCols1, int32_T nbCols2, real_T *y1) {
    int32_T i, j, k;
    real_T sum;
    
    for (i=0; i<nbRows1; i++)
        for(j=0; j<nbCols2; j++) {
            sum = 0.0;
            for(k=0; k<nbCols1; k++)
                /* SL matrix are column major order */
                sum += u1[i+nbRows1*k] * u2[k+nbCols1*j];

            y1[i+nbRows1*j] = sum;
        }
}
