function x = eml_xtrsv(UPLO,TRANS,DIAGA,n,A,ia0,lda,x,ix0,incx)
%Embedded MATLAB Private Function

%   Wrapper
%   Level 2 BLAS
%   xTRSV(UPLO,TRANS,DIAGA,N,A(IA0),LDA,X(IX0),INCX)
%
%   Solve a linear system with a triangular coefficient matrix.
%
%   UPLO  = 'U' for upper triangular
%           'L' for lower triangular
%   TRANS = 'N' for no transpose
%           'T' for inv(A).'*x
%           'C' for inv(A)'*x
%   DIAGA = 'N' for arbitrary diagonal elements.
%         = 'U' to assume unit diagonal.
%
%   Mixed type support:
%   1. isreal(A) && ~isreal(X)
%   2. isa(A,'double') && isa(X,'single')
%   3. n, ia0, lda, ix0, and incx from combinable numeric classes, i.e.,
%   all float (single or double) or all double or from the same integer
%   class.

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml

if eml_option('Developer')
    eml_assert(nargin == 10, 'Not enough input arguments.');
    eml_assert(ischar(UPLO) &&  ~isempty(UPLO) && ...
        (UPLO(1) == 'U' || UPLO(1) == 'L'), ...
        'UPLO(1) must be ''U'' for upper or ''L'' for LOWER');
    eml_assert(ischar(TRANS) &&  ~isempty(TRANS) && ...
        (TRANS(1) == 'T' || TRANS(1) == 'N' || TRANS(1) == 'C'), ...
        'TRANS(1) must be ''T'' for transpose, ''C'' for conjugate-transpose, or ''N'' for non-transpose.');
    eml_assert(ischar(DIAGA) &&  ~isempty(DIAGA) && ...
        (DIAGA(1) == 'U' || DIAGA(1) == 'N'), ...
        'DIAGA(1) must be ''U'' for unit-diagonal or ''N'', otherwise.');
    eml_assert(isreal(A) || ~isreal(x), 'X must be complex if A is complex.');
    eml_assert(isa(A,'float') && isa(x,'float'), 'A and X must be ''double'' or ''single''.');
    eml_assert(isa(x,'single') || isa(A,'double'), 'X must be ''single'' if A is ''single''.');
    eml_assert(isscalar(ia0) && isa(ia0,'numeric') && isreal(ia0), 'IA0 must be real, scalar, and numeric.');
    eml_assert(isscalar(lda) && isa(lda,'numeric') && isreal(lda), 'LDA must be real, scalar, and numeric.');
    eml_assert(isscalar(n) && isa(n,'numeric') && isreal(n), 'N must be real, scalar, and numeric.');
    eml_assert(isscalar(ix0) && isa(ix0,'numeric') && isreal(ix0), 'IX0 must be real, scalar, and numeric.');
    eml_assert(isscalar(incx) && isa(incx,'numeric') && isreal(incx), 'INCX must be real, scalar, and numeric.');
end
eml_prefer_const(UPLO,TRANS,DIAGA,n,ia0,lda,ix0,incx);
x = eml_blas_xtrsv(UPLO(1),TRANS(1),DIAGA(1),n,A,ia0,lda,x,ix0,incx);
