function d = eml_blas_xdot(n,x,ix0,incx,y,iy0,incy)
%Embedded MATLAB Private Function

%   Level 1 BLAS
%   xDOT(N,X(IX0),INCX,Y(IY0),INCY)

%   This function should be called only by eml_xdot.
%   See that function for requirements.

%   Copyright 2007-2009 The MathWorks, Inc.
%#eml

if eml_use_refblas || ... 
        ~isa(x,class(y)) || ~isreal(x) || ~isreal(y)
    d = eml_refblas_xdot( ...
        cast(n,eml_blas_int), ...
        x, ix0, cast(incx,eml_blas_int), ...
        y, iy0, cast(incy,eml_blas_int));
else
    d = ceval_xdot( ...
        cast(n,eml_blas_int), ...
        x, ix0, cast(incx,eml_blas_int), ...
        y, iy0, cast(incy,eml_blas_int));
end

%--------------------------------------------------------------------------

function d = ceval_xdot(n,x,ix0,incx,y,iy0,incy)
eml_must_not_inline; % Helps limit creation of scalar temporaries.
% Select BLAS function.
if isa(x,'single')
    fun = 'sdot32';
else
    fun = 'ddot32';
end
% Declare the output type.
d = eml_scalar_eg(x);
if n > 0
% Call the BLAS function.
d = eml.ceval(fun,eml.rref(n),eml.rref(x(ix0)),eml.rref(incx), ...
    eml.rref(y(iy0)),eml.rref(incy));
end

%--------------------------------------------------------------------------
