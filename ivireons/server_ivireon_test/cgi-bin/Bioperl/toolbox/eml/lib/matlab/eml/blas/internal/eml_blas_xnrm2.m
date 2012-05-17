function y = eml_blas_xnrm2(n,x,ix0,incx)
%Embedded MATLAB Private Function

%   Level 1 BLAS
%   xNRM2(N,X(IX0),INCX)

%   Copyright 2007 The MathWorks, Inc.
%#eml

y = eml_refblas_xnrm2(n,x,ix0,incx);