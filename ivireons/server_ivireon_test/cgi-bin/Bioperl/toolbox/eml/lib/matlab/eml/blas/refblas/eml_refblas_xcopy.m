function y = eml_refblas_xcopy(n,x,ix0,incx,y,iy0,incy)
%Embedded MATLAB Private Function

%   Level 1 BLAS
%   xCOPY(N,X(IX0),INCX,Y(IY0),INCY)

%   Supports x = [] to avoid copies when isequal(x,y).

%   Copyright 2007-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin == 7, 'Not enough input arguments.');
eml_prefer_const(n,ix0,incx,iy0,incy);
if n < 1
    return
end
ix = cast(ix0,eml_index_class);
if incx < 0
    ixinc = cast(-incx,eml_index_class);
    nextix = @eml_index_minus;
else
    ixinc = cast(incx,eml_index_class);    
    nextix = @eml_index_plus;
end
iy = cast(iy0,eml_index_class);
if incy < 0
    iyinc = cast(-incy,eml_index_class);
    nextiy = @eml_index_minus;
else
    iyinc = cast(incy,eml_index_class);    
    nextiy = @eml_index_plus;
end
for k = 1:n
    if eml_is_const(size(x)) && isempty(x)
        y(iy) = y(ix);
    else
        y(iy) = x(ix);
    end
    iy = nextiy(iy,iyinc);
    ix = nextix(ix,ixinc);
end
