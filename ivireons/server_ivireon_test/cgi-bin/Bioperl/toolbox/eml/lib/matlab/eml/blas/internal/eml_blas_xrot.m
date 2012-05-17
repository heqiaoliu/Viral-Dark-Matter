function [x,y] = eml_blas_xrot(n,x,ix0,incx,y,iy0,incy,c,s)
%Embedded MATLAB Private Function

%   Level 1 BLAS
%   xROT(N,X(IX0),INCX,Y(IY0),INCY,C,S)

%   Copyright 2007 The MathWorks, Inc.
%#eml

[x,y] = eml_refblas_xrot(n,x,ix0,incx,y,iy0,incy,c,s);