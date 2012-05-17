function idxmax = eml_blas_ixamax(n,x,ix0,incx)
%Embedded MATLAB Private Function

%   Level 1 BLAS
%   IxAMAX(N,X(IX0),INCX)

%   This function should be called only by eml_ixamax.
%   See that function for requirements.

%   Copyright 2007-2009 The MathWorks, Inc.
%#eml

if eml_use_refblas
    idxmax = eml_refblas_ixamax( ...
        cast(n,eml_blas_int), ...
        x, ix0, cast(incx,eml_blas_int));
else
    idxmax = ceval_ixamax( ...
        cast(n,eml_blas_int), ...
        x, ix0, cast(incx,eml_blas_int));
end

%--------------------------------------------------------------------------

function idxmax = ceval_ixamax(n,x,ix0,incx)
eml_must_not_inline; % Helps limit creation of scalar temporaries.
% Select BLAS function.
if isreal(x)
    if isa(x,'single')
        fun = 'isamax32';
    else
        fun = 'idamax32';
    end
else
    if isa(x,'single')
        fun = 'icamax32';
    else
        fun = 'izamax32';
    end
end
% Declare the output type.
idxmax = ones(eml_blas_int); %#ok
% Call the BLAS function.
idxmax = eml.ceval(fun,eml.rref(n),eml.rref(x(ix0)),eml.rref(incx));

%--------------------------------------------------------------------------
