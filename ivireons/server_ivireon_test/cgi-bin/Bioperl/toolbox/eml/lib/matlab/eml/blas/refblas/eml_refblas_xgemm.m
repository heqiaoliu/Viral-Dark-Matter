function C = eml_refblas_xgemm(TRANSA,TRANSB,m,n,k,alpha1,A,ia0,lda,B,ib0,ldb,beta1,C,ic0,ldc)
%Embedded MATLAB Private Function

%   Level 3 BLAS
%   xGEMM(TRANSA,TRANSB,M,N,K,ALPHA11,A(IA0),LDA,B(IB0),LDB,BETA1,C(IC0),LDC)

%   C := alpha*op(A)*op(B) + beta*C,
%   where op(A) is MxK and op(B) is KxN.
%   Note that nonfinites in A and B are ignored if alpha1 == 0, and
%   nonfinites in C are ignored if beta1 == 0.
%   Very little error checking.

%   Copyright 2006-2008 The MathWorks, Inc.
%#eml

eml_assert(nargin == 16, 'Not enough input arguments.');
eml_prefer_const(TRANSA,TRANSB,m,n,k,alpha1,beta1,ia0,lda,ib0,ldb,ic0,ldc);
NOTA = TRANSA(1) == 'N';
NOTB = TRANSB(1) == 'N';
CONJA = TRANSA(1) == 'C';
CONJB = TRANSB(1) == 'C';
% Quick return if possible.
if (m == 0) || (n == 0) || (((alpha1 == 0) || (k == 0)) && (beta1 == 1))
    return
end
% Perform the regular matrix multiply if applicable.  This opens the door
% to various optimizations in specialized code.
if eml_is_const(TRANSA) && NOTA && ...
        eml_is_const(TRANSB) && NOTB && ...
        eml_is_const(m) && eml_is_const(n) && eml_is_const(k) && ...
        m == size(A,1) && n == size(B,2) && ...
        k == size(A,2) && k == size(B,1) && ...
        m == size(C,1) && n == size(C,2) && ...
        eml_is_const(ia0) && eml_is_const(lda) && ...
        ia0 == 1 && lda == size(A,1) && ...
        eml_is_const(ib0) && eml_is_const(ldb) && ...
        ib0 == 1 && ldb == size(B,1) && ...
        eml_is_const(ic0) && eml_is_const(ldc) && ...
        ic0 == 1 && ldc == size(C,1) && ...
        eml_is_const(alpha1) && alpha1 == 1 && ...
        eml_is_const(beta1) && beta1 == 0 && ...
        isa(A,class(C)) && isa(B,class(C)) && isa(alpha1,class(C))
    C = eml_mtimes(A,B);
    return
end
% Perform the general calculation.
Coffset = eml_index_minus(ic0,1);
Aoffset = eml_index_minus(ia0,1);
Boffset = eml_index_minus(ib0,1);
lda1 = cast(lda,eml_index_class);
ldb1 = cast(ldb,eml_index_class);
ldc1 = cast(ldc,eml_index_class);
ONE = ones(eml_index_class);
CZERO = eml_scalar_eg(C);
nm1 = eml_index_minus(n,1);
km1 = eml_index_minus(k,1);
lastColC = eml_index_plus(Coffset,eml_index_times(ldc1,nm1));
% Initialize C
if beta1 == 0
    for cr = Coffset:ldc1:lastColC
        for ic = eml_index_plus(cr,1):eml_index_plus(cr,m)
            C(ic) = 0;
        end
    end
else
    for cr = Coffset:ldc1:lastColC
        for ic = eml_index_plus(cr,1):eml_index_plus(cr,m)
            C(ic) = C(ic).*beta1;
        end
    end
end
% And when alpha == 0.
if alpha1 == 0
    return
end
% Start the operations.
if NOTB
    if NOTA
        % Form  C := alpha*A*B + beta*C.
        br = Boffset;
        for cr = Coffset:ldc1:lastColC
            ar = Aoffset;
            for ib = eml_index_plus(br,1):eml_index_plus(br,k)
                if B(ib) ~= 0
                    temp = alpha1.*B(ib);
                    ia = ar;
                    for ic = eml_index_plus(cr,1):eml_index_plus(cr,m)
                        ia = eml_index_plus(ia,1);
                        C(ic) = C(ic) + temp.*A(ia);
                    end
                end
                ar = eml_index_plus(ar,lda1);
            end
            br = eml_index_plus(br,ldb1);
        end
    else
        % Form  C := alpha*A'*B  + beta*C.
        %  or   C := alpha*A.'*B + beta*C
        br = Boffset;
        for cr = Coffset:ldc1:lastColC
            ar = Aoffset;
            for ic = eml_index_plus(cr,1):eml_index_plus(cr,m)
                temp = CZERO;
                for w = ONE:k
                    if CONJA
                        temp = temp + eml_conjtimes(A(eml_index_plus(w,ar)),B(eml_index_plus(w,br)));
                    else
                        temp = temp + A(eml_index_plus(w,ar)).*B(eml_index_plus(w,br));
                    end
                end
                C(ic) = C(ic) + alpha1.*temp;
                ar = eml_index_plus(ar,lda1);
            end
            br = eml_index_plus(br,ldb1);
        end
    end
elseif NOTA
    % Form  C := alpha*A*B'  + beta*C
    %  or   C := alpha*A*B.' + beta*C
    br = Boffset;
    for cr = Coffset:ldc1:lastColC
        ar = Aoffset;
        br = eml_index_plus(br,1);
        for ib = br:ldb1:eml_index_plus(br,eml_index_times(ldb1,km1))
            if B(ib) ~= 0
                if CONJB
                    temp = alpha1.*conj(B(ib));
                else
                    temp = alpha1.*B(ib);
                end
                ia = ar;
                for ic = eml_index_plus(cr,1):eml_index_plus(cr,m)
                    ia = eml_index_plus(ia,1);
                    C(ic) = C(ic) + temp.*A(ia);
                end
            end
            ar = eml_index_plus(ar,lda1);
        end
    end
else
    % Form  C := alpha*A'*B'   + beta*C
    %  or   C := alpha*A'*B.'  + beta*C
    %  or   C := alpha*A.'*B'  + beta*C
    %  or   C := alpha*A.'*B.' + beta*C
    br = Boffset;
    for cr = Coffset:ldc1:lastColC
        ar = Aoffset;
        br = eml_index_plus(br,1);
        for ic = eml_index_plus(cr,1):eml_index_plus(cr,m)
            temp = CZERO;
            ib = br;
            for ia = eml_index_plus(ar,1):eml_index_plus(ar,k)
                if CONJA == CONJB
                    temp = temp + A(ia).*B(ib);
                elseif CONJA
                    temp = temp + eml_conjtimes(A(ia),B(ib));
                else
                    temp = temp + eml_conjtimes(B(ib),A(ia));
                end
                ib = eml_index_plus(ib,ldb1);
            end
            if CONJA && CONJB
                C(ic) = C(ic) + eml_conjtimes(temp,alpha1);
            else
                C(ic) = C(ic) + alpha1.*temp;
            end
            ar = eml_index_plus(ar,lda1);
        end
    end
end

