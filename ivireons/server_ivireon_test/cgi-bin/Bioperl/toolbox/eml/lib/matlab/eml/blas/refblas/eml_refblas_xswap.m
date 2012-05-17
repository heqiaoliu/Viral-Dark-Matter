function [x,y] = eml_refblas_xswap(n,x,ix0,incx,y,iy0,incy)
%Embedded MATLAB Private Function

%   Level 1 BLAS
%   xSWAP(N,X(IX0),INCX,Y(IY0),INCY)
%   Supports y = [] to avoid copies when isequal(x,y).

%   Copyright 2007-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin == 7, 'Not enough input arguments.');
eml_prefer_const(n,ix0,incx,iy0,incy);
ix = cast(ix0,eml_index_class);
iy = cast(iy0,eml_index_class);
ixinc = cast(abs(incx),eml_index_class);
iyinc = cast(abs(incy),eml_index_class);
for k = 1:n
    temp = x(ix);
    if eml_is_const(size(y)) && isempty(y)
        x(ix) = x(iy);
        x(iy) = temp;
    else
        x(ix) = y(iy);
        y(iy) = temp;
    end
    if incx < 0
        ix = eml_index_minus(ix,ixinc);
    else
        ix = eml_index_plus(ix,ixinc);
    end
    if incy < 0
        iy = eml_index_minus(iy,iyinc);
    else
        iy = eml_index_plus(iy,iyinc);
    end
end
