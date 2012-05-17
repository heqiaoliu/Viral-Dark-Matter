function d = eml_refblas_xdotc(n,x,ix0,incx,y,iy0,incy)
%Embedded MATLAB Private Function

%   Level 1 BLAS 
%   xDOTC(N,X(IX0),INCX,Y(IY0),INCY)

%   Copyright 2007-2008 The MathWorks, Inc.
%#eml

eml_assert(nargin == 7, 'Not enough input arguments.');
eml_prefer_const(n,ix0,incx,iy0,incy);
d = eml_refblas_xdotx('C',n,x,ix0,incx,y,iy0,incy);
