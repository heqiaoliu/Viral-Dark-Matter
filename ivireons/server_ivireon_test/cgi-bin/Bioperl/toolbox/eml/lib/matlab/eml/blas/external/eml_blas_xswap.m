function [x,y] = eml_blas_xswap(n,x,ix0,incx,y,iy0,incy)
%Embedded MATLAB Private Function

%   This function should be called only by eml_xswap.
%   See that function for requirements.

%   Copyright 2007-2009 The MathWorks, Inc.
%#eml

if eml_use_refblas
    [x,y] = eml_refblas_xswap( ...
        cast(n,eml_blas_int), ...
        x, ix0, cast(incx,eml_blas_int), ...
        y, iy0, cast(incy,eml_blas_int));
else
    [x,y] = ceval_xswap( ...
        cast(n,eml_blas_int), ...
        x, ix0, cast(incx,eml_blas_int), ...
        y, iy0, cast(incy,eml_blas_int));
end

%--------------------------------------------------------------------------

function [x,y] = ceval_xswap(n,x,ix0,incx,y,iy0,incy)
eml_must_not_inline; % Helps limit creation of scalar temporaries.
% Select BLAS function.
if isreal(x)
    if isa(x,'single')
        fun = 'sswap32';
    else
        fun = 'dswap32';
    end
else
    if isa(x,'single')
        fun = 'cswap32';
    else
        fun = 'zswap32';
    end
end
% Call the BLAS function.
if eml_is_const(size(y)) && isempty(y)
    eml.ceval(fun,eml.rref(n),eml.ref(x(ix0)),eml.rref(incx),...
        eml.ref(x(iy0)),eml.rref(incy));
else
    eml.ceval(fun,eml.rref(n),eml.ref(x(ix0)),eml.rref(incx),...
        eml.ref(y(iy0)),eml.rref(incy));
end

%--------------------------------------------------------------------------
