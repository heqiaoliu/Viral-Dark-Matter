#include <stdio.h>
#include <stdlib.h>
#include "c_sort.h"

static int my_cmp(void *A, void *B)
{
    real_T A1 = *((real_T *)A);
    real_T B1 = *((real_T *)B);

    if (A1 < B1) return -1;
    if (A1 > B1) return 1;
    return 0;
}

boolean_T c_sort_impl(real_T *U, real_T *Y, int32_T n)
{
    boolean_T sorted = 1;
    int i;
    for (i = 0; i < n-1; i++) {
        if (U[i] > U[i+1]) sorted = 0;
    }
    
    for (i = 0; i < n; i++) {
        Y[i] = U[i];
    }
    
    if (~sorted) {
        qsort(Y, n, sizeof(real_T), my_cmp);
    }

    return sorted;
}
