function y = eml_xgemv(trans,m,n,alpha1,A,ia0,lda,x,ix0,incx,beta1,y,iy0,incy)
%Embedded MATLAB Private Function

%   Level 2 BLAS
%   xGEMV(TRANS,M,N,ALPHA1,A(IA0),LDA,X(IX0),INCX,BETA,Y(IY0),INCY)
%
%   Compute y = alpha1*op(A)*x + beta1*y.
%   Note that nonfinites in A and B are ignored if alpha1 == 0, and
%   nonfinites in C are ignored if beta1 == 0.

%   Mixed type support:
%   1. ~isreal(y) && (isreal(alpha1) || isreal(A) || isreal(x) ||
%   isreal(beta1)).
%   2. isa(y,'single') && (isa(alpha1,'double') || isa(A,'double') ||
%   isa(x,'double') || isa(beta1,'double')).
%   3. m, n, ia0, lda, ix0, incx, iy0, incy from combinable numeric
%   classes, i.e., all float (single or double) or all double or from the
%   same integer class.
%   4. To avoid copies, pass in [] for A or x if they represent
%   non-overlapping parts of y.

%   Copyright 2007-2008 The MathWorks, Inc.
%#eml

if eml_option('Developer')
    eml_assert(nargin >= 11, 'Not enough input arguments.');
    eml_assert(~isreal(y) || (isreal(A) && isreal(x) && isreal(alpha1) && isreal(beta1)), ...
        'EML_XGEMV:  if any of the inputs are complex, Y must be complex.');
    eml_assert(ischar(trans) && (trans == 'N' || trans == 'C' || trans == 'T'), ...
        'TRANS argument must be ''N'', ''C'', or ''T''.');
    eml_assert(isa(alpha1,'float'), 'ALPHA1 must be ''double'' or ''single''.');
    eml_assert(isa(beta1,'float'), 'BETA1 must be ''double'' or ''single''.');
    eml_assert(isa(A,'float'), 'A must be ''double'' or ''single''.');
    eml_assert(isa(x,'float'), 'X must be ''double'' or ''single''.');
    eml_assert(isa(y,'float'), 'Y must be ''double'' or ''single''.');
    eml_assert(isscalar(m) && isa(m,'numeric') && isreal(m), 'M must be real, scalar, and numeric.');
    eml_assert(isscalar(n) && isa(n,'numeric') && isreal(n), 'N must be real, scalar, and numeric.');
    eml_assert(isscalar(ia0) && isa(ia0,'numeric') && isreal(ia0), 'IA0 must be real, scalar, and numeric.');
    eml_assert(isscalar(lda) && isa(lda,'numeric') && isreal(lda), 'LDA must be real, scalar, and numeric.');
    eml_assert(isscalar(ix0) && isa(ix0,'numeric') && isreal(ix0), 'IX0 must be real, scalar, and numeric.');
    eml_assert(isscalar(incx) && isa(incx,'numeric') && isreal(incx), 'INCX must be real, scalar, and numeric.');
    eml_assert(isscalar(iy0) && isa(iy0,'numeric') && isreal(iy0), 'IY0 must be real, scalar, and numeric.');
    eml_assert(isscalar(incy) && isa(incy,'numeric') && isreal(incy), 'INCY must be real, scalar, and numeric.');
    eml_assert(~isreal(y) || (isreal(alpha1) && isreal(beta1) && isreal(A) && isreal(x)), ...
        'Y must be complex if ALPHA1, A, X, or BETA1 is complex.');
    eml_assert(isa(y,'single') || ...
        (isa(alpha1,'double') && isa(A,'double') && isa(x,'double') && isa(beta1,'double')), ...
        'Y must be ''single'' if ALPHA1, A, X, or BETA1 is single.');
end
eml_prefer_const(trans,m,n,alpha1,ia0,lda,ix0,incx,beta1,iy0,incy);
y = eml_blas_xgemv(trans,m,n,alpha1,A,ia0,lda,x,ix0,incx,beta1,y,iy0,incy);
