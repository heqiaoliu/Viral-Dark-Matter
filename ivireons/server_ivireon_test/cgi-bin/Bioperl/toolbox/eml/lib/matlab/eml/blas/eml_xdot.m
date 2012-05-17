function d = eml_xdot(n,x,ix0,incx,y,iy0,incy)
%Embedded MATLAB Private Function

%   Level 1 BLAS
%   xDOT(N,X(IX0),INCX,Y(IY0),INCY)

%   Required mixed type support:
%   1. isa(x,'single') ~= isa(y,'single')
%   2. n, ix0, incx, iy0, and incy from combinable numeric classes, i.e.,
%   all float (single or double) or all double or from the same integer
%   class.

%   Copyright 2007-2008 The MathWorks, Inc.
%#eml

if eml_option('Developer')
    eml_assert(nargin == 7, 'Not enough input arguments.');
    eml_assert(isa(x,'float') && isreal(x), 'X must be real and ''double'' or ''single''.');
    eml_assert(isa(y,'float') && isreal(y), 'Y must be real and ''double'' or ''single''.');
    eml_assert(isscalar(n) && isa(n,'numeric') && isreal(n), 'N must be real, scalar, and numeric.');
    eml_assert(isscalar(ix0) && isa(ix0,'numeric') && isreal(ix0), 'IX0 must be real, scalar, and numeric.');
    eml_assert(isscalar(incx) && isa(incx,'numeric') && isreal(incx), 'INCX must be real, scalar, and numeric.');
    eml_assert(isscalar(iy0) && isa(iy0,'numeric') && isreal(iy0), 'IY0 must be real, scalar, and numeric.');
    eml_assert(isscalar(incy) && isa(incy,'numeric') && isreal(incy), 'INCY must be real, scalar, and numeric.');
end
eml_prefer_const(n,ix0,incx,iy0,incy);
d = eml_blas_xdot(n,x,ix0,incx,y,iy0,incy);
