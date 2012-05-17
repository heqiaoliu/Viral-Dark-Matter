function C = eml_blas_xgemm(TRANSA,TRANSB,m,n,k,alpha1,A,ia0,lda,B,ib0,ldb,beta1,C,ic0,ldc)
%Embedded MATLAB Private Function

%   Level 3 BLAS
%   xGEMM(TRANSA,TRANSB,M,N,K,ALPHA11,A(IA0),LDA,B(IB0),LDB,BETA1,C(IC0),LDC)

%   Copyright 2007-2009 The MathWorks, Inc.
%#eml

if k < 1
    return
end
if eml_use_refblas || ...
        ~(isreal(C) == isreal(A) && isreal(C) == isreal(B)) || ...
        ~(isa(A,class(C)) && isa(B,class(C))) || ... 
        itcount(m,n,k,A,B,C) < threshold(isreal(C))
    C = eml_refblas_xgemm( ...
        TRANSA, TRANSB, ...
        cast(m,eml_blas_int), cast(n,eml_blas_int), cast(k,eml_blas_int), ...
        alpha1+eml_scalar_eg(C), ...
        A, ia0, cast(lda,eml_blas_int), ...
        B, ib0, cast(ldb,eml_blas_int), ...
        beta1+eml_scalar_eg(C), ...
        C, ic0, cast(ldc,eml_blas_int));
else
    C = ceval_xgemm( ...
        TRANSA, TRANSB, ...
        cast(m,eml_blas_int), cast(n,eml_blas_int), cast(k,eml_blas_int), ...
        alpha1+eml_scalar_eg(C), ...
        A, ia0, cast(lda,eml_blas_int), ...
        B, ib0, cast(ldb,eml_blas_int), ...
        beta1+eml_scalar_eg(C), ...
        C, ic0, cast(ldc,eml_blas_int));
end

%--------------------------------------------------------------------------

function t = threshold(isr)
% Crossover itcount threshold from using refblas to external blas.
if isr
    t = 216; % 6*6*6
else
    t = 27;  % 3*3*3
end

%--------------------------------------------------------------------------

function ic = itcount(m,n,k,A,B,C)
% Loop iteration count.
% Returns an upper bound if m, n, and k are not constant.
if eml_is_const(m) && eml_is_const(n) && eml_is_const(k)
    ic = double(m)*double(n)*double(k);
else
    ic = min(length(A),length(B))*eml_numel(C);
end

%--------------------------------------------------------------------------

function C = ceval_xgemm(TRANSA,TRANSB,m,n,k,alpha1,A,ia0,lda,B,ib0,ldb,beta1,C,ic0,ldc)
eml_must_not_inline; % Helps limit creation of scalar temporaries.
% Select BLAS function.
if isreal(C)
    if isa(C,'single')
        fun = 'sgemm32';
    else
        fun = 'dgemm32';
    end
else
    if isa(C,'single')
        fun = 'cgemm32';
    else
        fun = 'zgemm32';
    end
end
% Call the BLAS function.
eml.ceval(fun,eml.rref(TRANSA),eml.rref(TRANSB), ...
    eml.rref(m),eml.rref(n),eml.rref(k), ...
    eml.rref(alpha1),eml.rref(A(ia0)),eml.rref(lda), ...
    eml.rref(B(ib0)),eml.rref(ldb), ...
    eml.rref(beta1),eml.ref(C(ic0)),eml.rref(ldc));

%--------------------------------------------------------------------------
