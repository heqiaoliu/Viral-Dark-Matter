function y = eml_refblas_xgemv(trans,m,n,alpha1,A,ia0,lda,x,ix0,incx,beta1,y,iy0,incy)
%Embedded MATLAB Private Function

%   Level 2 BLAS
%   xGEMV(TRANS,M,N,ALPHA1,A(IA0),LDA,X(IX0),INCX,BETA,Y(IY0),INCY)
%
%   Compute y = alpha1*op(A)*x + beta1*y.
%   Note that nonfinites in A and B are ignored if alpha1 == 0, and
%   nonfinites in C are ignored if beta1 == 0.
%   To avoid copies, pass [] for A and/or X when they are parts of Y.

%   Copyright 2006-2010 The MathWorks, Inc.
%#eml

eml_assert(nargin == 14, 'Not enough input arguments.');
eml_prefer_const(trans,alpha1,m,n,ia0,lda,ix0,incx,beta1,iy0,incy);
eml_assert(~isreal(y) || (isreal(A) && isreal(x) && isreal(alpha1) && isreal(beta1)), ...
    'EML_REFBLAS_XGEMV:  if any of the inputs are complex, Y must be complex.');
if m == 0 || n == 0
    % Quick return for no-op case.
    return
end
mm1 = eml_index_minus(m,1);
nm1 = eml_index_minus(n,1);
iystart = cast(iy0,eml_index_class);
if trans == 'N'
    iyend = eml_index_plus(iystart,eml_index_times(incy,mm1));
else
    iyend = eml_index_plus(iystart,eml_index_times(incy,nm1));
end
% Initialize Y.
if beta1 ~= 1
    if beta1 == 0
        for iy = iystart:incy:iyend
            y(iy) = 0;
        end
    else
        for iy = iystart:incy:iyend
            y(iy) = beta1.*y(iy);
        end
    end
end
% Peform the matrix-vector multiplication and vector addition.
if alpha1 == 0
    % Nothing to do.
elseif trans == 'N'
    ix = cast(ix0,eml_index_class);
    for iac = cast(ia0,eml_index_class):lda:eml_index_plus(ia0,eml_index_times(lda,nm1))
        if eml_is_const(size(x)) && isempty(x)
            c = alpha1.*y(ix);
        else
            c = alpha1.*x(ix);
        end
        iy = iystart;
        for ia = iac:eml_index_plus(iac,mm1)
            if eml_is_const(size(A)) && isempty(A)
                y(iy) = y(iy) + y(ia).*c;
            else
                y(iy) = y(iy) + A(ia).*c;
            end
            iy = eml_index_plus(iy,incy);
        end
        ix = eml_index_plus(ix,incx);
    end
else
    CONJA = trans == 'C';
    iy = iystart;
    for iac = cast(ia0,eml_index_class):lda:eml_index_plus(ia0,eml_index_times(lda,nm1))
        ix = cast(ix0,eml_index_class);
        c = eml_scalar_eg(y);
        for ia = iac:eml_index_plus(iac,mm1)
            if CONJA
                if eml_is_const(size(A)) && isempty(A) && ...
                        eml_is_const(size(x)) && isempty(x)
                    c = c + eml_conjtimes(y(ia),y(ix));
                elseif eml_is_const(size(A)) && isempty(A)
                    c = c + eml_conjtimes(y(ia),x(ix));
                elseif eml_is_const(size(x)) && isempty(x)
                    c = c + eml_conjtimes(A(ia),y(ix));
                else
                    c = c + eml_conjtimes(A(ia),x(ix));
                end
            else
                if eml_is_const(size(A)) && isempty(A) && ...
                        eml_is_const(size(x)) && isempty(x)
                    c = c + y(ia).*y(ix);
                elseif eml_is_const(size(A)) && isempty(A)
                    c = c + y(ia).*x(ix);
                elseif eml_is_const(size(x)) && isempty(x)
                    c = c + A(ia).*y(ix);
                else
                    c = c + A(ia).*x(ix);
                end
            end
            ix = eml_index_plus(ix,incx);
        end
        y(iy) = y(iy) + alpha1.*c;
        iy = eml_index_plus(iy,incy);
    end
end
