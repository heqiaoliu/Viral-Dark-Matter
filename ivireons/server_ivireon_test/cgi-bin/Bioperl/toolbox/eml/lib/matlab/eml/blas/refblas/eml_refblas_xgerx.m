function A = eml_refblas_xgerx(op,m,n,alpha1,x,ix0,incx,y,iy0,incy,A,ia0,lda)
%Embedded MATLAB Private Function

%   Shared M implementation for 3 rank 1 update BLAS routines.
%   1. op == 'U'  
%       Level 2 BLAS  xGER(M,N,ALPHA,X(IX0),INCX,Y(IY0),INCY,A(IA0),LDA)
%       Level 2 BLAS xGERU(M,N,ALPHA,X(IX0),INCX,Y(IY0),INCY,A(IA0),LDA)
%       A = alpha*x*y' + A,
%   2. op == 'C'
%       Level 2 BLAS xGERC(M,N,ALPHA,X(IX0),INCX,Y(IY0),INCY,A(IA0),LDA)
%       A = alpha*x*y' + A,
%
%   where alpha is a scalar, x is an m element vector, y is an n element
%   vector and A is an m by n matrix.

%   Supports x = [] and/or y = [] to avoid copies when isequal(x,A) and/or
%   isequal(y,A), respectively.

%   Copyright 2007-2009 The MathWorks, Inc.
%#eml

% This routine should only be called by the official BLAS routines.
eml_assert(nargin == 13, 'Not enough input arguments.');
eml_prefer_const(op,m,n,ix0,incx,iy0,incy,ia0,lda);
eml_assert(ischar(op) && ~isempty(op) && (op(1) == 'U' || op(1) == 'C'), ...
    'First input must be ''U'' or ''C''.');
if alpha1 == 0
    return
end
doconj = op == 'C';
% Start the operations. In this version the elements of A are
% accessed sequentially with one pass through A.
ixstart = cast(ix0,eml_index_class);
ixinc = cast(abs(incx),eml_index_class);
jyinc = cast(abs(incy),eml_index_class);
jA = eml_index_minus(ia0,1);
jy = cast(iy0,eml_index_class);
for j = 1:n
    if eml_is_const(size(y)) && isempty(y)
        yjy = A(jy);
    else
        yjy = y(jy);
    end
    if yjy ~= 0
        if doconj
            temp = eml_conjtimes(yjy,alpha1);
        else
            temp = yjy.*alpha1;
        end
        ix = ixstart;
        for ijA = eml_index_plus(1,jA):eml_index_plus(m,jA)
            if eml_is_const(size(x)) && isempty(x)
                A(ijA) = A(ijA) + A(ix).*temp;
            else
                A(ijA) = A(ijA) + x(ix).*temp;
            end
            if incx < 0
                ix = eml_index_minus(ix,ixinc);
            else
                ix = eml_index_plus(ix,ixinc);
            end
        end
    end
    if incy < 0
        jy = eml_index_minus(jy,jyinc);
    else
        jy = eml_index_plus(jy,jyinc);
    end
    jA = eml_index_plus(jA,lda);
end
