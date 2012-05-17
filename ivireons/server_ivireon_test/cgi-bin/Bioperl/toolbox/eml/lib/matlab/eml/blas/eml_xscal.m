function x = eml_xscal(n,a,x,ix0,incx)
%Embedded MATLAB Private Function

%   Level 1 BLAS
%   xSCAL(N,A,X(IX0),INCX)

%   Mixed type support:
%   1. isa(a,'double') && isa(x,'single')
%   2. isreal(a) && ~isreal(x)
%   3. n, inx0, and incx from combinable numeric classes, i.e., all float
%   (single or double) or all double or from the same integer class.

%   Copyright 2007-2008 The MathWorks, Inc.
%#eml

if eml_option('Developer')
    eml_assert(nargin == 5, 'Not enough input arguments.');
    eml_assert(isa(a,'float'), 'A must be ''double'' or ''single''.');
    eml_assert(isa(x,'float'), 'X must be ''double'' or ''single''.');
    eml_assert(isa(x,'single') || isa(a,'double'), 'A must be ''double'' if X is ''double''.');
    eml_assert(~isreal(x) || isreal(a), 'A must be real if X is real.');
    eml_assert(isscalar(n) && isa(n,'numeric') && isreal(n), 'N must be real, scalar, and numeric.');
    eml_assert(isscalar(ix0) && isa(ix0,'numeric') && isreal(ix0), 'IX0 must be real, scalar, and numeric.');
    eml_assert(isscalar(incx) && isa(incx,'numeric') && isreal(incx), 'INCX must be real, scalar, and numeric.');
end
eml_prefer_const(n,ix0,incx);
x = eml_blas_xscal(n,a,x,ix0,incx);
