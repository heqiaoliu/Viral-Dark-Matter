function x = eml_blas_xscal(n,a,x,ix0,incx)
%Embedded MATLAB Private Function

%   Level 1 BLAS
%   xSCAL(N,A,X(IX0),INCX)

%   Copyright 2007 The MathWorks, Inc.
%#eml

x = eml_refblas_xscal(n,a,x,ix0,incx);
