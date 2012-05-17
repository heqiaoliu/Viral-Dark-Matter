function y = eml_blas_xasum(n,x,ix0,incx)
%Embedded MATLAB Private Function

%   Level 1 BLAS 
%   xASUM(N,X(IX0),INCX)

%   Copyright 2007 The MathWorks, Inc.
%#eml

y = eml_refblas_xasum(n,x,ix0,incx);