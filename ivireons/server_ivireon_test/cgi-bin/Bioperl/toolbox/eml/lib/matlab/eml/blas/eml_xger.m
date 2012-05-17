function A = eml_xger(m,n,alpha1,x,ix0,incx,y,iy0,incy,A,ia0,lda)
%Embedded MATLAB Private Function

%   Level 2 BLAS xGER(M,N,ALPHA,X(IX0),INCX,Y(IY0),INCY,A(IA0),LDA)

%   A = alpha*x*y.' + A

%   Mixed type support:
%   1. ALPHA1, X, or Y may be 'double' when A is 'single'.
%   2. m, n, ix0, incx, iy0, incy, ia0, lda from any numeric class.
%   3. To avoid copies, pass in [] for x or y when they represent
%   non-overlapping parts of A.

%   Copyright 2007-2008 The MathWorks, Inc.
%#eml

if eml_option('Developer')
    eml_assert(nargin >= 12, 'Not enough input arguments.');
    eml_assert(isscalar(alpha1) && isa(alpha1,'float') && isreal(alpha1), ...
        'ALPHA1 must be real, scalar, and ''double'' or ''single''.');
    eml_assert(isa(x,'float') && isreal(x), 'X must be real and ''double'' or ''single''.');
    eml_assert(isa(y,'float') && isreal(y), 'Y must be real and ''double'' or ''single''.');
    eml_assert(isa(A,'float') && isreal(A), 'A must be real and ''double'' or ''single''.');
    eml_assert(isscalar(m) && isa(m,'numeric') && isreal(m), 'M must be real, scalar, and numeric.');
    eml_assert(isscalar(n) && isa(n,'numeric') && isreal(n), 'N must be real, scalar, and numeric.');
    eml_assert(isscalar(ix0) && isa(ix0,'numeric') && isreal(ix0), 'IX0 must be real, scalar, and numeric.');
    eml_assert(isscalar(incx) && isa(incx,'numeric') && isreal(incx), 'INCX must be real, scalar, and numeric.');
    eml_assert(isscalar(iy0) && isa(iy0,'numeric') && isreal(iy0), 'IY0 must be real, scalar, and numeric.');
    eml_assert(isscalar(incy) && isa(incy,'numeric') && isreal(incy), 'INCY must be real, scalar, and numeric.');
    eml_assert(isscalar(ia0) && isa(ia0,'numeric') && isreal(ia0), 'IA0 must be real, scalar, and numeric.');
    eml_assert(isscalar(lda) && isa(lda,'numeric') && isreal(lda), 'LDA must be real, scalar, and numeric.');
    eml_assert(isa(A,'single') || (isa(alpha1,'double') && isa(x,'double') && isa(y,'double')), ...
        'A must be ''single'' if ALPHA1, X, or Y is ''single''.');
end
eml_prefer_const(m,n,ix0,incx,iy0,incy,ia0,lda);
A = eml_blas_xger(m,n,alpha1,x,ix0,incx,y,iy0,incy,A,ia0,lda);

