function x = eml_blas_xscal(n,a,x,ix0,incx)
%Embedded MATLAB Private Function

%   Level 1 BLAS
%   xSCAL(N,A,X(IX0),INCX)

%   Copyright 2007-2009 The MathWorks, Inc.
%#eml

if eml_use_refblas
    x = eml_refblas_xscal( ...
        cast(n,eml_blas_int), ...
        a+eml_scalar_eg(x), ...
        x, ix0, cast(incx,eml_blas_int));
else
    x = ceval_xscal( ...
        cast(n,eml_blas_int), ...
        a+eml_scalar_eg(x), ...
        x, ix0, cast(incx,eml_blas_int));
end

%--------------------------------------------------------------------------

function x = ceval_xscal(n,a,x,ix0,incx)
eml_must_not_inline; % Helps limit creation of scalar temporaries.
% Select BLAS function.
if isreal(x)
    if isa(x,'single')
        fun = 'sscal32';
    else
        fun = 'dscal32';
    end
else
    if isa(x,'single')
        fun = 'cscal32';
    else
        fun = 'zscal32';
    end
end
% Call the BLAS function.
eml.ceval(fun,eml.rref(n),eml.rref(a),eml.ref(x(ix0)),eml.rref(incx));

%--------------------------------------------------------------------------
