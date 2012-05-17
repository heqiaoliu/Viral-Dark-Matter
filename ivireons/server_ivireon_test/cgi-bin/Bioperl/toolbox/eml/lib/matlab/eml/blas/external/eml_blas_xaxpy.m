function y = eml_blas_xaxpy(n,a,x,ix0,incx,y,iy0,incy)
%Embedded MATLAB Private Function

%   Level 1 BLAS
%   xAXPY(N,A,X(IX0),INCX,Y(IY0),INCY)

%   This function should be called only by eml_xaxpy.
%   See that function for requirements.

%   Copyright 2007-2009 The MathWorks, Inc.
%#eml

if eml_use_refblas || ...
        ~(isa(x,class(y)) && (isreal(x) == isreal(y))) 
    y = eml_refblas_xaxpy( ...
        cast(n,eml_blas_int), ...
        a+eml_scalar_eg(y), ...
        x, ix0, cast(incx,eml_blas_int), ...
        y, iy0, cast(incy,eml_blas_int));
else
    y = ceval_xaxpy( ...
        cast(n,eml_blas_int), ...
        a+eml_scalar_eg(y), ...
        x, ix0, cast(incx,eml_blas_int), ...
        y, iy0, cast(incy,eml_blas_int));
end

%--------------------------------------------------------------------------

function y = ceval_xaxpy(n,a,x,ix0,incx,y,iy0,incy)
eml_must_not_inline; % Helps limit creation of scalar temporaries.
% Select BLAS function.
if isreal(y)
    if isa(y,'single')
        fun = 'saxpy32';
    else
        fun = 'daxpy32';
    end
else
    if isa(y,'single')
        fun = 'caxpy32';
    else
        fun = 'zaxpy32';
    end
end
% Convert scalar inputs to the appropriate classes and types.
% Call the BLAS function.
if eml_is_const(size(x)) && isempty(x)
    eml.ceval(fun,eml.rref(n),eml.rref(a),eml.rref(y(ix0)), ...
        eml.rref(incx),eml.ref(y(iy0)),eml.rref(incy));
else
    eml.ceval(fun,eml.rref(n),eml.rref(a),eml.rref(x(ix0)), ...
        eml.rref(incx),eml.ref(y(iy0)),eml.rref(incy));
end

%--------------------------------------------------------------------------
