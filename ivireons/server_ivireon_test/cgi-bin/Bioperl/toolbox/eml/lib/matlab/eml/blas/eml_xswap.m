function [x,y] = eml_xswap(n,x,ix0,incx,y,iy0,incy)
%Embedded MATLAB Private Function

%   Level 1 BLAS
%   xSWAP(N,X(IX0),INCX,Y(IY0),INCY)

%   When swapping subvectors from the same array, you must use Y = [] and
%   one output, as in X = EML_XSWAP(N,X,IX0,INCX,[],IY0,INCY);

%   Copyright 2007-2008 The MathWorks, Inc.
%#eml

if eml_option('Developer')
    eml_assert(nargin == 7, 'Not enough input arguments.');
    eml_assert(isa(x,'float'), 'X must be ''double'' or ''single''.');
    eml_assert(isa(y,'float'), 'Y must be ''double'' or ''single''.');
    eml_assert(isempty(y) || (isa(x,class(y)) && isreal(x) == isreal(y)), 'X and Y must have the same class and complexness.');
    eml_assert(isscalar(n) && isa(n,'numeric') && isreal(n), 'N must be real, scalar, and numeric.');
    eml_assert(isscalar(ix0) && isa(ix0,'numeric') && isreal(ix0), 'IX0 must be real, scalar, and numeric.');
    eml_assert(isscalar(incx) && isa(incx,'numeric') && isreal(incx), 'INCX must be real, scalar, and numeric.');
    eml_assert(isscalar(iy0) && isa(iy0,'numeric') && isreal(iy0), 'IY0 must be real, scalar, and numeric.');
    eml_assert(isscalar(incy) && isa(incy,'numeric') && isreal(incy), 'INCY must be real, scalar, and numeric.');
end
eml_prefer_const(n,ix0,incx,iy0,incy);
[x,y] = eml_blas_xswap(n,x,ix0,incx,y,iy0,incy);
