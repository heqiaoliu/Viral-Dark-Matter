function [x,y] = eml_blas_xrot(n,x,ix0,incx,y,iy0,incy,c,s)
%Embedded MATLAB Private Function

%   Level 1 BLAS
%   xROT(N,X(IX0),INCX,Y(IY0),INCY,C,S)

%   This function should be called only by eml_xrot.
%   See that function for requirements.

%   Copyright 2007-2009 The MathWorks, Inc.
%#eml

if eml_use_refblas
    [x,y] = eml_refblas_xrot(...
        cast(n,eml_blas_int), ...
        x, ix0, cast(incx,eml_blas_int), ...
        y, iy0, cast(incy,eml_blas_int), ...
        cast(c,class(x)), s+eml_scalar_eg(x));
else
    [x,y] = ceval_xrot( ...
        cast(n,eml_blas_int), ...
        x, ix0, cast(incx,eml_blas_int), ...
        y, iy0, cast(incy,eml_blas_int), ...
        cast(c,class(x)), s+eml_scalar_eg(x));
end

%--------------------------------------------------------------------------

function [x,y] = ceval_xrot(n,x,ix0,incx,y,iy0,incy,c,s)
eml_must_not_inline; % Helps limit creation of scalar temporaries.
% Select BLAS function.
if isreal(x)
    if isa(x,'single')
        fun = 'srot32';
    else
        fun = 'drot32';
    end
else
    if isa(x,'single')
        fun = 'csrot32';
    else
        fun = 'zdrot32';
    end
end
% Call the BLAS function.
if eml_is_const(size(y)) && isempty(y)
    eml.ceval(fun,eml.rref(n),eml.ref(x(ix0)),eml.rref(incx), ...
        eml.ref(x(iy0)),eml.rref(incy), ...
        eml.rref(c),eml.rref(s));
else
    eml.ceval(fun,eml.rref(n),eml.ref(x(ix0)),eml.rref(incx), ...
        eml.ref(y(iy0)),eml.rref(incy), ...
        eml.rref(c),eml.rref(s));
end

%--------------------------------------------------------------------------
