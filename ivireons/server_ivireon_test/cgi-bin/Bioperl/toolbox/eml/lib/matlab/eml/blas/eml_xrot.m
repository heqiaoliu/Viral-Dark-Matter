function [x,y] = eml_xrot(n,x,ix0,incx,y,iy0,incy,c,s)
%Embedded MATLAB Private Function

%   Level 1 BLAS
%   xROT(N,X(IX0),INCX,Y(IY0),INCY,C,S)

%   When rotating subvectors from the same array, you must use Y = [] and
%   one output, as in X = EML_XROT(N,X,IX0,INCX,[],IY0,INCY,C,S);

%   Copyright 2007-2008 The MathWorks, Inc.
%#eml

if eml_option('Developer')
    eml_assert(nargin == 9, 'Not enough input arguments.');
    eml_assert(isscalar(n) && isa(n,'numeric') && isreal(n), 'N must be real, scalar, and numeric.');
    eml_assert(isscalar(ix0) && isa(ix0,'numeric') && isreal(ix0), 'IX0 must be real, scalar, and numeric.');
    eml_assert(isscalar(incx) && isa(incx,'numeric') && isreal(incx), 'INCX must be real, scalar, and numeric.');
    eml_assert(isscalar(iy0) && isa(iy0,'numeric') && isreal(iy0), 'IY0 must be real, scalar, and numeric.');
    eml_assert(isscalar(incy) && isa(incy,'numeric') && isreal(incy), 'INCY must be real, scalar, and numeric.');
    eml_assert(isreal(c) && isscalar(c) && isa(c,'float'), 'C must be real, scalar, and ''double'' or ''single''.');
    eml_assert(isscalar(s) && isa(s,'float'), 'S must be scalar and ''double'' or ''single''.');
    eml_assert(isempty(y) || (isa(x,class(y)) && isreal(x) == isreal(y)), 'X and Y must have the same class and complexness.');
    eml_assert(isa(x,'single') || isa(c,'double'), 'C must be ''double'' if X and Y are ''double''.');
    eml_assert(isa(x,'single') || isa(s,'double'), 'S must be ''double'' if X and Y are ''double''.');
end
eml_prefer_const(n,ix0,incx,iy0,incy);
[x,y] = eml_blas_xrot(n,x,ix0,incx,y,iy0,incy,c,s);
