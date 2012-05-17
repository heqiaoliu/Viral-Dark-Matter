#include <tmwtypes.h>

#define c_sort(U,Y,N) c_sort_impl((real_T *)U,(real_T *)Y,N)

boolean_T c_sort_impl(real_T *U, real_T *Y, int32_T n);
