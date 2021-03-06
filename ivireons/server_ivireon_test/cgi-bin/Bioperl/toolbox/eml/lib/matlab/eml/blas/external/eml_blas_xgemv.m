function y = eml_blas_xgemv(TRANSA,m,n,alpha1,A,ia0,lda,x,ix0,incx,beta1,y,iy0,incy)
%Embedded MATLAB Private Function

%   Level 2 BLAS
%   xGEMV(TRANS,M,N,ALPHA1,A(IA0),LDA,X(IX0),INCX,BETA,Y(IY0),INCY)

%   This function should be called only by eml_xgemv.
%   See that function for requirements.

%   Copyright 2006-2009 The MathWorks, Inc.
%#eml

if eml_use_refblas || ...
        ~isa(A,class(x)) || (isreal(A) ~= isreal(x)) || ...
        itcount(m,n,A) < 16
    y = eml_refblas_xgemv( ...
        TRANSA, ...
        cast(m,eml_blas_int), cast(n,eml_blas_int), ...
        alpha1+eml_scalar_eg(y), ...
        A, ia0, cast(lda,eml_blas_int), ...
        x, ix0, cast(incx,eml_blas_int), ...
        beta1+eml_scalar_eg(y), ...
        y, iy0, cast(incy,eml_blas_int));
else
    y = ceval_xgemv( ...
        TRANSA, ...
        cast(m,eml_blas_int), cast(n,eml_blas_int), ...
        alpha1+eml_scalar_eg(y), ...
        A, ia0, cast(lda,eml_blas_int), ...
        x, ix0, cast(incx,eml_blas_int), ...
        beta1+eml_scalar_eg(y), ...
        y, iy0, cast(incy,eml_blas_int));
end

%--------------------------------------------------------------------------

function ic = itcount(m,n,A)
% Loop iteration count.
% Returns an upper bound if m and n are not constant.
if eml_is_const(m) && eml_is_const(n)
    ic = double(m)*double(n);
else
    ic = eml_numel(A);
end

%--------------------------------------------------------------------------

function y = ceval_xgemv(TRANSA,m,n,alpha1,A,ia0,lda,x,ix0,incx,beta1,y,iy0,incy)
eml_must_not_inline; % Helps limit creation of scalar temporaries.
% Select BLAS function.
if isreal(y)
    if isa(y,'single')
        fun = 'sgemv32';
    else
        fun = 'dgemv32';
    end
else
    if isa(y,'single')
        fun = 'cgemv32';
    else
        fun = 'zgemv32';
    end
end
% Call the BLAS function.
if eml_is_const(size(A)) && isempty(A) && ...
        eml_is_const(size(x)) && isempty(x)
    eml.ceval(fun,eml.rref(TRANSA),eml.rref(m),eml.rref(n), ...
        eml.rref(alpha1),eml.rref(y(ia0)),eml.rref(lda), ...
        eml.rref(y(ix0)),eml.rref(incx), ...
        eml.rref(beta1),eml.ref(y(iy0)),eml.rref(incy));
elseif eml_is_const(size(A)) && isempty(A)
    eml.ceval(fun,eml.rref(TRANSA),eml.rref(m),eml.rref(n), ...
        eml.rref(alpha1),eml.rref(y(ia0)),eml.rref(lda), ...
        eml.rref(x(ix0)),eml.rref(incx), ...
        eml.rref(beta1),eml.ref(y(iy0)),eml.rref(incy));
elseif eml_is_const(size(x)) && isempty(x)
    eml.ceval(fun,eml.rref(TRANSA),eml.rref(m),eml.rref(n), ...
        eml.rref(alpha1),eml.rref(A(ia0)),eml.rref(lda), ...
        eml.rref(y(ix0)),eml.rref(incx), ...
        eml.rref(beta1),eml.ref(y(iy0)),eml.rref(incy));
else
    eml.ceval(fun,eml.rref(TRANSA),eml.rref(m),eml.rref(n), ...
        eml.rref(alpha1),eml.rref(A(ia0)),eml.rref(lda), ...
        eml.rref(x(ix0)),eml.rref(incx), ...
        eml.rref(beta1),eml.ref(y(iy0)),eml.rref(incy));
end

%--------------------------------------------------------------------------
