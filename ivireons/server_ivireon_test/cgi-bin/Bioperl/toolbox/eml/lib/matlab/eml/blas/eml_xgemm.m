function C = eml_xgemm(TRANSA,TRANSB,m,n,k,alpha1,A,ia0,lda,B,ib0,ldb,beta1,C,ic0,ldc)
%Embedded MATLAB Private Function

%   Level 3 BLAS
%   xGEMM(TRANSA,TRANSB,M,N,K,ALPHA11,A(IA0),LDA,B(IB0),LDB,BETA1,C(IC0),LDC)

%   C := alpha*op(A)*op(B) + beta*C,
%   where op(A) is MxK and op(B) is KxN.
%   Note that nonfinites in A and B are ignored if alpha1 == 0, and
%   nonfinites in C are ignored if beta1 == 0.

%   Mixed type support:
%   1. ~isreal(C) && (isreal(alpha1) || isreal(A) || isreal(beta1) ||
%   isreal(B)).
%   2. isa(C,'single') && (isa(alpha1,'double') || isa(A,'double') ||
%   isa(beta1,'double') || isa(B,'double')).
%   3. m, n, k, ia0, lda, ib0, ldb, ic0, ldc from combinable numeric
%   classes, i.e., all float (single or double) or all double or from the
%   same integer class.

%   Copyright 2007-2008 The MathWorks, Inc.
%#eml

if eml_option('Developer')
    eml_assert(nargin == 16, 'Not enough input arguments.');
    eml_assert(ischar(TRANSA) && ~isempty(TRANSA) && ...
        (TRANSA(1) == 'N' || TRANSA(1) == 'C' || TRANSA(1) == 'T'), ...
        'TRANSA(1) must be ''N'', ''C'', or ''T''.');
    eml_assert(ischar(TRANSB) && ~isempty(TRANSB) && ...
        (TRANSB(1) == 'N' || TRANSB(1) == 'C' || TRANSB(1) == 'T'), ...
        'TRANSB(1) must be ''N'', ''C'', or ''T''.');
    eml_assert(isa(alpha1,'float'), 'ALPHA1 must be ''double'' or ''single''.');
    eml_assert(isa(beta1,'float'), 'BETA1 must be ''double'' or ''single''.');
    eml_assert(isa(A,'float'), 'A must be ''double'' or ''single''.');
    eml_assert(isa(B,'float'), 'B must be ''double'' or ''single''.');
    eml_assert(isa(C,'float'), 'C must be ''double'' or ''single''.');
    eml_assert(isscalar(m) && isa(m,'numeric') && isreal(m), 'M must be real, scalar, and numeric.');
    eml_assert(isscalar(n) && isa(n,'numeric') && isreal(n), 'N must be real, scalar, and numeric.');
    eml_assert(isscalar(k) && isa(k,'numeric') && isreal(k), 'K must be real, scalar, and numeric.');
    eml_assert(isscalar(ia0) && isa(ia0,'numeric') && isreal(ia0), 'IA0 must be real, scalar, and numeric.');
    eml_assert(isscalar(lda) && isa(lda,'numeric') && isreal(lda), 'LDA must be real, scalar, and numeric.');
    eml_assert(isscalar(ib0) && isa(ib0,'numeric') && isreal(ib0), 'IB0 must be real, scalar, and numeric.');
    eml_assert(isscalar(ldb) && isa(ldb,'numeric') && isreal(ldb), 'LDB must be real, scalar, and numeric.');
    eml_assert(isscalar(ic0) && isa(ic0,'numeric') && isreal(ic0), 'IC0 must be real, scalar, and numeric.');
    eml_assert(isscalar(ldc) && isa(ldc,'numeric') && isreal(ldc), 'LDC must be real, scalar, and numeric.');
    eml_assert(~isreal(C) || (isreal(alpha1) && isreal(A) && isreal(beta1) && isreal(B)), ...
        'C must be complex if ALPHA1, A, BETA1, or B is complex.');
    eml_assert(isa(C,'single') || ...
        (isa(alpha1,'double') && isa(A,'double') && isa(beta1,'double') && isa(B,'double')), ...
        'C must be ''single'' if ALPHA1, A, BETA1, or B is ''single''.');
end
eml_prefer_const(TRANSA,TRANSB,m,n,k,alpha1,beta1,ia0,lda,ib0,ldb,ic0,ldc);
C = eml_blas_xgemm(TRANSA,TRANSB,m,n,k,alpha1,A,ia0,lda,B,ib0,ldb,beta1,C,ic0,ldc);
