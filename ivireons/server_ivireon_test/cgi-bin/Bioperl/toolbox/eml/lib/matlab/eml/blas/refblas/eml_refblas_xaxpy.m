function y = eml_refblas_xaxpy(n,a,x,ix0,incx,y,iy0,incy)
%Embedded MATLAB Private Function

%   Level 1 BLAS
%   xAXPY(N,A,X(IX0),INCX,Y(IY0),INCY)

%   Copyright 2007-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin == 8, 'Not enough input arguments.');
eml_prefer_const(n,ix0,incx,iy0,incy);
if n < 1 || a == 0
    return
end
if eml_is_const(ix0) && eml_is_const(iy0) && ix0 == iy0 && ...
        eml_is_const(incx) && eml_is_const(incy) && incx == incy && ...
        ~(eml_is_const(size(x)) && isempty(x))
    % Streamlined code for using the same index.
    ix = cast(ix0,eml_index_class);
    ixinc = cast(incx,eml_index_class);
    ixlast = eml_index_plus(ix,eml_index_times(eml_index_minus(n,1),ixinc));
    for k = ix:ixinc:ixlast
        y(k) = y(k) + a.*x(k);
    end
else
    % General case.
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
            y(iy) = y(iy) + a.*y(ix);
        else
            y(iy) = y(iy) + a.*x(ix);
        end
        iy = nextiy(iy,iyinc);
        ix = nextix(ix,ixinc);
    end
end