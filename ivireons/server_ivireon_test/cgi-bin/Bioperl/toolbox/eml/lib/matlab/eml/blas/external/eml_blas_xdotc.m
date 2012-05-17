function d = eml_blas_xdotc(n,x,ix0,incx,y,iy0,incy)
%Embedded MATLAB Private Function

%   Level 1 BLAS
%   xDOTC(N,X(IX0),INCX,Y(IY0),INCY)

%   This function should be called only by eml_xdotc.
%   See that function for requirements.

%   Copyright 2007-2009 The MathWorks, Inc.
%#eml

if eml_use_refblas || ...
        ~isa(x,class(y)) || (isreal(x) ~= isreal(y)) || ...
        ~isreal(x) % cdotc/zdotc not supported yet.
    d = eml_refblas_xdotc( ...
        cast(n,eml_blas_int), ...
        x, ix0, cast(incx,eml_blas_int), ...
        y, iy0, cast(incy,eml_blas_int));
else
    d = ceval_xdotc( ...
        cast(n,eml_blas_int), ...
        x, ix0, cast(incx,eml_blas_int), ...
        y, iy0, cast(incy,eml_blas_int));
end

%--------------------------------------------------------------------------

function d = ceval_xdotc(n,x,ix0,incx,y,iy0,incy)
eml_must_not_inline; % Helps limit creation of scalar temporaries.
% Select BLAS function.
if isreal(x)
    if isa(x,'single')
        fun = 'sdot32';
    else
        fun = 'ddot32';
    end
else
    if isa(x,'single')
        fun = 'cdotc32';
    else
        fun = 'zdotc32';
    end
end
% Declare the output type.
d = eml_scalar_eg(x);
if n > 0
% Call the BLAS function.
d = eml.ceval(fun,eml.rref(n),eml.rref(x(ix0)),eml.rref(incx), ...
    eml.rref(y(iy0)),eml.rref(incy));
end

%--------------------------------------------------------------------------
