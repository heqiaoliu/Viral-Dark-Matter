function idxmax = eml_refblas_ixamax(n,x,ix0,incx)
%Embedded MATLAB Private Function

%   Level 1 BLAS
%   IxAMAX(N,X(IX0),INCX)

%   Copyright 2007 The MathWorks, Inc.
%#eml

eml_assert(nargin == 4, 'Not enough input arguments.');
eml_prefer_const(n,ix0,incx);
ONE = ones(eml_index_class);
if n < 1 || incx < 1
    idxmax = zeros(eml_index_class);
else
    idxmax = ONE;
    if n > 1
        ix = cast(ix0,eml_index_class);
        ixinc = cast(incx,eml_index_class);
        smax = eml_xcabs1(x(ix));
        for k = cast(2,eml_index_class):n
            ix = eml_index_plus(ix,ixinc);
            s = eml_xcabs1(x(ix));
            if s > smax
                idxmax = k;
                smax = s;
            end
        end
    end
end