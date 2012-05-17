function [x,y] = eml_refblas_xrot(n,x,ix0,incx,y,iy0,incy,c,s)
%Embedded MATLAB Private Function

%   Level 1 BLAS
%   xROT(N,X(IX0),INCX,Y(IY0),INCY,C,S)

%   Supports y = [] to avoid copies when isequal(x,y).
%   May not work correctly with negative increments if eml_index_class is
%   an unsigned class.

%   Copyright 2007-2010 The MathWorks, Inc.
%#eml

eml_assert(nargin == 9, 'Not enough input arguments.');
eml_prefer_const(n,ix0,incx,iy0,incy);
if n < 1
    return
end
ix = cast(ix0,eml_index_class);
iy = cast(iy0,eml_index_class);
for k = ones(eml_index_class):n
    if eml_is_const(size(y)) && isempty(y)
        temp = c*x(ix) + s*x(iy);
        x(iy) = c*x(iy) - s*x(ix);
    else
        temp = c*x(ix) + s*y(iy);
        y(iy) = c*y(iy) - s*x(ix);
    end
    x(ix) = temp;
    iy = eml_index_plus(iy,incx);
    ix = eml_index_plus(ix,incy);
end

