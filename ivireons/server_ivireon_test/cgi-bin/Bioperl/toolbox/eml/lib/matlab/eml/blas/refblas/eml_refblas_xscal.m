function x = eml_refblas_xscal(n,a,x,ix0,incx)
%Embedded MATLAB Private Function

%   Level 1 BLAS
%   xSCAL(N,A,X(IX0),INCX)

%   Copyright 2007 The MathWorks, Inc.
%#eml

eml_assert(nargin == 5, 'Not enough input arguments.');
eml_prefer_const(n,ix0,incx);
if incx < 1
    return
end
for k = cast(ix0,eml_index_class)  : ...
        cast(incx,eml_index_class) : ...
        eml_index_plus(ix0,eml_index_times(incx,eml_index_minus(n,1)))
    x(k) = a.*x(k);
end

