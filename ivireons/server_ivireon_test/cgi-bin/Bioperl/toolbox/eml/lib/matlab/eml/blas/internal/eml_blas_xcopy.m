function y = eml_blas_xcopy(n,x,ix0,incx,y,iy0,incy)
%Embedded MATLAB Private Function

%   Level 1 BLAS
%   xCOPY(N,X(IX0),INCX,Y(IY0),INCY)

%   Copyright 2007 The MathWorks, Inc.
%#eml

y = eml_refblas_xcopy(n,x,ix0,incx,y,iy0,incy);