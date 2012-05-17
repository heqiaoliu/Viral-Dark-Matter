function y = eml_blas_xcopy(n,x,ix0,incx,y,iy0,incy)
%Embedded MATLAB Private Function

%   Level 1 BLAS
%   xCOPY(N,X(IX0),INCX,Y(IY0),INCY)

%   This function should be called only by eml_xcopy.
%   See that function for requirements.

%   Copyright 2007-2009 The MathWorks, Inc.
%#eml

if eml_use_refblas || ...
        ~(isa(x,class(y)) && (isreal(x) == isreal(y)))
    y = eml_refblas_xcopy( ...
        cast(n,eml_blas_int), ...
        x, ix0, cast(incx,eml_blas_int), ...
        y, iy0, cast(incy,eml_blas_int));
else
    y = ceval_xcopy( ...
        cast(n,eml_blas_int), ...
        x, ix0, cast(incx,eml_blas_int), ...
        y, iy0, cast(incy,eml_blas_int));
end

%--------------------------------------------------------------------------

function y = ceval_xcopy(n,x,ix0,incx,y,iy0,incy)
eml_must_not_inline; % Helps limit creation of scalar temporaries.
% Select BLAS function.
if isreal(y)
    if isa(y,'single')
        fun = 'scopy32';
    else
        fun = 'dcopy32';
    end
else
    if isa(y,'single')
        fun = 'ccopy32';
    else
        fun = 'zcopy32';
    end
end
% Call the BLAS function.
if eml_is_const(size(x)) && isempty(x)
    eml.ceval(fun,eml.rref(n),eml.rref(y(ix0)),eml.rref(incx),...
        eml.ref(y(iy0)),eml.rref(incy));
else
    eml.ceval(fun,eml.rref(n),eml.rref(x(ix0)),eml.rref(incx),...
        eml.ref(y(iy0)),eml.rref(incy));
end

%--------------------------------------------------------------------------
