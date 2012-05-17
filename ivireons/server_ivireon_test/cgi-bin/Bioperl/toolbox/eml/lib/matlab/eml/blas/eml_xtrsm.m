function B = eml_xtrsm(SIDE,UPLO,TRANSA,DIAGA,m,n,alpha1,A,ia0,lda,B,ib0,ldb)
%Embedded MATLAB Private Function

%   Wrapper
%   Level 3 BLAS
%   xTRSM(SIDE,UPLO,TRANSA,DIAGA,M,N,ALPHA1,A(IA0),LDA,B(IB0),LDB)
%
%   op(A)*X = alpha1*B  or  X*op(A) = alpha1*B,
%
%   Where B is overwritten with X on return.
%
%   SIDE = 'L' op(A)*X = alpha1*B.
%   SIDE = 'R' X*op(A) = alpha1*B.
%   UPLO = 'U' A is an upper triangular matrix.
%   UPLO = 'L' A is a lower triangular matrix.
%   TRANSA = 'N' op(A) = A.
%   TRANSA = 'T' op(A) = A'.
%   TRANSA = 'C' op(A) = conjg(A').
%   DIAGA = 'U' A is assumed to be unit triangular.
%   DIAGA = 'N' A is not assumed to be unit triangular.
%
%   Mixed type support:
%   1. (isreal(A) || isreal(ALPHA1)) && ~isreal(B)
%      For eml.ceval:  use complex(A), complex(ALPHA1).
%   2. (isa(A,'double') || isa(ALPHA1,'double')) && isa(B,'single')
%      For eml.ceval:  use single(A), single(ALPHA1).

%   Copyright 2007-2008 The MathWorks, Inc.
%#eml

if eml_option('Developer')
    eml_assert(nargin == 13, 'Not enough input arguments.');
    eml_assert(ischar(SIDE) &&  ~isempty(SIDE) && ...
        (SIDE(1) == 'L' || SIDE(1) == 'R'), ...
        'SIDE(1) must be ''L'' for Left or ''R'' for Right.');
    eml_assert(ischar(UPLO) &&  ~isempty(UPLO) && ...
        (UPLO(1) == 'U' || UPLO(1) == 'L'), ...
        'UPLO(1) must be ''U'' for upper or ''L'' for LOWER');
    eml_assert(ischar(TRANSA) &&  ~isempty(TRANSA) && ...
        (TRANSA(1) == 'T' || TRANSA(1) == 'N' || TRANSA(1) == 'C'), ...
        'TRANSA(1) must be ''T'' for transpose, ''C'' for conjugate-transpose, or ''N'' for non-transpose.');
    eml_assert(ischar(DIAGA) &&  ~isempty(DIAGA) && ...
        (DIAGA(1) == 'U' || DIAGA(1) == 'N'), ...
        'DIAGA(1) must be ''U'' for unit-diagonal or ''N'', otherwise.');
    eml_assert(isa(alpha1,'float') && isa(A,'float') && isa(B,'float'), ...
        'ALPHA1, A, and B must be ''double'' or ''single''.');
    eml_assert(~isreal(B) || (isreal(A) && isreal(alpha1)), ...
        'B must be complex if A or ALPHA1 is complex.');
    eml_assert(isa(B,'single') || (isa(A,'double') && isa(alpha1,'double')), ...
        'B must be ''single'' if A or ALPHA1 is ''single''.');
end
eml_prefer_const(SIDE,UPLO,TRANSA,DIAGA,m,n,alpha1,ia0,lda,ib0,ldb);
B = eml_blas_xtrsm(SIDE(1),UPLO(1),TRANSA(1),DIAGA(1),m,n,alpha1,A,ia0,lda,B,ib0,ldb);
