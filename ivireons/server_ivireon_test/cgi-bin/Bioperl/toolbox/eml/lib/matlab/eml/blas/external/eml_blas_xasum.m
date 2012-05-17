function y = eml_blas_xasum(n,x,ix0,incx)
%Embedded MATLAB Private Function

%   Level 1 BLAS
%   xASUM(N,X(IX0),INCX)

%   This function should be called only by eml_xasum.
%   See that function for requirements.

%   Copyright 2007-2009 The MathWorks, Inc.
%#eml

if eml_use_refblas
    y = eml_refblas_xasum( ...
        cast(n,eml_blas_int), ...
        x, ix0, cast(incx,eml_blas_int));
else
    y = ceval_xasum( ...
        cast(n,eml_blas_int), ...
        x, ix0, cast(incx,eml_blas_int));
end

%--------------------------------------------------------------------------

function y = ceval_xasum(n,x,ix0,incx)
eml_must_not_inline; % Helps limit creation of scalar temporaries.
% Select BLAS function.
if isreal(x)
    if isa(x,'single')
        fun = 'sasum32';
    else
        fun = 'dasum32';
    end
else
    if isa(x,'single')
        fun = 'scasum32';
    else
        fun = 'dzasum32';
    end
end
% Declare the output type.
y = zeros(class(x)); %#ok<NASGU>
% Call the BLAS function.
y = eml.ceval(fun,eml.rref(n),eml.rref(x(ix0)),eml.rref(incx));

%--------------------------------------------------------------------------
