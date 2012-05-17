function y = eml_blas_xnrm2(n,x,ix0,incx)
%Embedded MATLAB Private Function

%   Level 1 BLAS
%   xNRM2(N,X(IX0),INCX)

%   This function should be called only by eml_xnrm2.
%   See that function for documentation on required mixed type support.

%   Copyright 2007-2009 The MathWorks, Inc.
%#eml

eml_prefer_const(n);
if n < 1
    y = zeros(class(x));
    return
end
if eml_use_refblas
    y = eml_refblas_xnrm2( ...
        cast(n,eml_blas_int), ...
        x, ix0, cast(incx,eml_blas_int));
else
    y = ceval_xnrm2( ...
        cast(n,eml_blas_int), ...
        x, ix0, cast(incx,eml_blas_int));
end

%--------------------------------------------------------------------------

function y = ceval_xnrm2(n,x,ix0,incx)
eml_must_not_inline; % Helps limit creation of scalar temporaries.
% Select BLAS function.
if isreal(x)
    if isa(x,'single')
        fun = 'snrm232';
    else
        fun = 'dnrm232';
    end
else
    if isa(x,'single')
        fun = 'scnrm232';
    else
        fun = 'dznrm232';
    end
end
% Call the BLAS function.
y = zeros(class(x)); %#ok<NASGU>
y = eml.ceval(fun,eml.rref(n),eml.rref(x(ix0)),eml.rref(incx));

%--------------------------------------------------------------------------
