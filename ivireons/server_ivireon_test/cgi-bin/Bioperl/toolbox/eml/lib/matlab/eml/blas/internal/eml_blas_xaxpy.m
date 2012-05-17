function y = eml_blas_xaxpy(n,a,x,ix0,incx,y,iy0,incy)
%Embedded MATLAB Private Function

%   Level 1 BLAS 
%   xAXPY(N,A,X(IX0),INCX,Y(IY0),INCY)

%   Copyright 2007 The MathWorks, Inc.
%#eml

y = eml_refblas_xaxpy(n,a,x,ix0,incx,y,iy0,incy);