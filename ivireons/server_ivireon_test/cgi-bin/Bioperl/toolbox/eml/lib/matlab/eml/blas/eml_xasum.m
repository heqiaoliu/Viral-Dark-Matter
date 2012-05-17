function y = eml_xasum(n,x,ix0,incx)
%Embedded MATLAB Private Function

%   Level 1 BLAS
%   xASUM(N,X(IX0),INCX)

%   Copyright 2007-2008 The MathWorks, Inc.
%#eml

if eml_option('Developer')
    eml_assert(nargin == 4, 'Not enough input arguments.');
    eml_assert(isscalar(n) && isa(n,'numeric') && isreal(n), 'N must be real, scalar, and numeric.');
    eml_assert(isscalar(ix0) && isa(ix0,'numeric') && isreal(ix0), 'IX0 must be real, scalar, and numeric.');
    eml_assert(isscalar(incx) && isa(incx,'numeric') && isreal(incx), 'INCX must be real, scalar, and numeric.');
    eml_assert(isa(x,'float'), 'X must be ''double'' or ''single''.');
end
eml_prefer_const(n,ix0,incx);
y = eml_blas_xasum(n,x,ix0,incx);
