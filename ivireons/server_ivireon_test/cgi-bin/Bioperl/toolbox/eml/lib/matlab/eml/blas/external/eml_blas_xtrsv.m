function x = eml_blas_xtrsv(UPLO,TRANSA,DIAGA,n,A,ia0,lda,x,ix0,incx)
%Embedded MATLAB Private Function

%   Level 2 BLAS
%   xTRSV(UPLO,TRANS,DIAGA,N,A(IA0),LDA,X(IX0),INCX)

%   This function should be called only by eml_xtrsv.
%   See that function for requirements.

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

if eml_use_refblas || ...
        ~isa(A,class(x)) || (isreal(A) ~= isreal(x)) || ...
        itcount(n,A,x) < threshold(isreal(x))
    x = eml_refblas_xtrsv( ...
        UPLO, TRANSA, DIAGA, ...
        cast(n,eml_blas_int), ...
        A, ia0, cast(lda,eml_blas_int), ...
        x, ix0, cast(incx,eml_blas_int));
else
    x = ceval_xtrsv( ...
        UPLO, TRANSA, DIAGA, ...
        cast(n,eml_blas_int), ...
        A, ia0, cast(lda,eml_blas_int), ...
        x, ix0, cast(incx,eml_blas_int));
end

%--------------------------------------------------------------------------

function t = threshold(isr)
% Crossover itcount threshold from using refblas to external blas.
if isr
    t = 21; % 6*7/2
else
    t = 6;  % 3*4/2
end

%--------------------------------------------------------------------------

function ic = itcount(n,A,x)
% Loop iteration count.
% Returns an upper bound if n is not constant.
if eml_is_const(n)
    dn = double(n);
else
    dn = min(length(A),length(x));
end
ic = dn*(dn+1)/2;

%--------------------------------------------------------------------------

function x = ceval_xtrsv(UPLO,TRANSA,DIAGA,n,A,ia0,lda,x,ix0,incx)
eml_must_not_inline; % Helps limit creation of scalar temporaries.
% Select BLAS function.
if isreal(x)
    if isa(x,'single')
        fun = 'strsv32';
    else
        fun = 'dtrsv32';
    end
else
    if isa(x,'single')
        fun = 'ctrsv32';
    else
        fun = 'ztrsv32';
    end
end
% Call the BLAS function.
eml.ceval(fun,eml.rref(UPLO),eml.rref(TRANSA),eml.rref(DIAGA),eml.rref(n), ...
    eml.rref(A(ia0)),eml.rref(lda),eml.ref(x(ix0)),eml.rref(incx));

%--------------------------------------------------------------------------
