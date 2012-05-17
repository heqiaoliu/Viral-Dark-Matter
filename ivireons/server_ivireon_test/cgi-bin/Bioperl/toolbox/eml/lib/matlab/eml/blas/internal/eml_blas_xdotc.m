function d = eml_blas_xdotc(n,x,ix0,incx,y,iy0,incy)
%Embedded MATLAB Private Function

%   Level 1 BLAS
%   xDOTC(N,X(IX0),INCX,Y(IY0),INCY)

%   Copyright 2007 The MathWorks, Inc.
%#eml

d = eml_refblas_xdotc(n,x,ix0,incx,y,iy0,incy);