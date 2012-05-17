function B = eml_blas_xtrsm(SIDE,UPLO,TRANSA,DIAGA,m,n,alpha1,A,ia0,lda,B,ib0,ldb)
%Embedded MATLAB Private Function

%   Level 3 BLAS
%   xTRSM(SIDE,UPLO,TRANSA,DIAGA,M,N,ALPHA1,A(IA0),LDA,B(IB0),LDB)

%   This function should be called only by eml_xtrsm.
%   See that function for requirements.

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

if eml_use_refblas || ...
        ~isa(A,class(B)) || (isreal(A) ~= isreal(B)) || ...
        itcount(SIDE,m,n,A,B) < threshold(isreal(B))
    B = eml_refblas_xtrsm( ...
        SIDE, UPLO, TRANSA, DIAGA, ...
        cast(m,eml_blas_int), cast(n,eml_blas_int), ...
        alpha1+eml_scalar_eg(B), ...
        A, ia0, cast(lda,eml_blas_int), ...
        B, ib0, cast(ldb,eml_blas_int));
else
    B = ceval_xtrsm( ...
        SIDE, UPLO, TRANSA, DIAGA, ...
        cast(m,eml_blas_int), cast(n,eml_blas_int), ...
        alpha1+eml_scalar_eg(B), ...
        A, ia0, cast(lda,eml_blas_int), ...
        B, ib0, cast(ldb,eml_blas_int));
end

%--------------------------------------------------------------------------

function t = threshold(isr)
% Crossover itcount threshold from using refblas to external blas.
if isr
    t = 126; % 6*6*7/2
else
    t = 40;  % 4*4*5/2
end

%--------------------------------------------------------------------------

function ic = itcount(SIDE,m,n,A,B)
% Loop iteration count.
% Returns an upper bound if n is not constant.
if eml_is_const(n)
    if eml_is_const(SIDE)
        if SIDE(1) == 'L'
            k = double(m);
        else
            k = double(n);
        end
    else
        k = max(double(m),double(n));
    end
    ic = double(n)*k*(k+1)/2;
else
    k = length(A);
    ic = length(B)*k*(k+1)/2;
end

%--------------------------------------------------------------------------

function B = ceval_xtrsm(SIDE,UPLO,TRANSA,DIAGA,m,n,alpha1,A,ia0,lda,B,ib0,ldb)
% Don't inline this function--minimize the clutter from unshared
% temporaries created for constants that need local variables created for
% the FORTRAN-style BLAS call.
eml_must_not_inline;
% Select BLAS function.
if isreal(B)
    if isa(B,'single')
        fun = 'strsm32';
    else
        fun = 'dtrsm32';
    end
else
    if isa(B,'single')
        fun = 'ctrsm32';
    else
        fun = 'ztrsm32';
    end
end
% Call the BLAS function.
eml.ceval(fun,eml.rref(SIDE),eml.rref(UPLO),eml.rref(TRANSA), ...
    eml.rref(DIAGA),eml.rref(m),eml.rref(n),eml.rref(alpha1), ...
    eml.rref(A(ia0)),eml.rref(lda),eml.ref(B(ib0)),eml.rref(ldb));

%--------------------------------------------------------------------------
