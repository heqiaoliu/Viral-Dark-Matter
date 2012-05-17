function d = eml_refblas_xdotx(op,n,x,ix0,incx,y,iy0,incy)
%Embedded MATLAB Private Function

%   Level 1 BLAS
%   1. op == 'U':
%       Level 1 BLAS  xDOT(N,X(IX0),INCX,Y(IY0),INCY)
%       Level 1 BLAS xDOTU(N,X(IX0),INCX,Y(IY0),INCY)
%   2. op == 'C':
%       Level 1 BLAS xDOTC(N,X(IX0),INCX,Y(IY0),INCY)

%   Copyright 2007-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin == 8, 'Not enough input arguments.');
eml_prefer_const(op,n,ix0,incx,iy0,incy);
eml_assert(ischar(op) && isequal(op,'U') || isequal(op,'C'), ...
    'OP must be ''U'' or ''C''.');
d = eml_scalar_eg(x,y);
if n < 1
    return
end
doconj = op == 'C';
if eml_is_const(ix0) && eml_is_const(iy0) && ix0 == iy0 && ...
        eml_is_const(incx) && eml_is_const(incy) && incx == incy
    % Streamlined code for using the same index.
    ix = cast(ix0,eml_index_class);
    ixinc = cast(incx,eml_index_class);
    ixlast = eml_index_plus(ix,eml_index_times(eml_index_minus(n,1),ixinc));
    for k = ix:ixinc:ixlast
        if doconj
            d = d + eml_conjtimes(x(k),y(k));
        else
            d = d + x(k).*y(k);
        end
    end
else
    ix = cast(ix0,eml_index_class);
    iy = cast(iy0,eml_index_class);
    for k = 1:n
        if doconj
            d = d + eml_conjtimes(x(ix),y(iy));
        else
            d = d + x(ix).*y(iy);
        end
        if incx < 0
            ix = eml_index_minus(ix,-incx);
        else
            ix = eml_index_plus(ix,incx);
        end
        if incy < 0
            iy = eml_index_minus(iy,-incy);
        else
            iy = eml_index_plus(iy,incy);
        end
    end
end