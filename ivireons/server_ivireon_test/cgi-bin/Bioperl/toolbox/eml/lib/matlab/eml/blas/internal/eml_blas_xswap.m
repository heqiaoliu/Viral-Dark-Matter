function [x,y] = eml_blas_xswap(n,x,ix0,incx,y,iy0,incy)
%Embedded MATLAB Private Function

%   Level 1 BLAS
%   xSWAP(N,X(IX0),INCX,Y(IY0),INCY)

%   Copyright 2007 The MathWorks, Inc.
%#eml

[x,y] = eml_refblas_xswap(n,x,ix0,incx,y,iy0,incy);
