function x = eml_refblas_xtrsv(UPLO,TRANS,DIAGA,n,A,ia0,lda,x,ix0,incx)
%Embedded MATLAB Private Function

%   Level 2 BLAS
%   xTRSV(UPLO,TRANS,DIAGA,N,A(IA0),LDA,X(IX0),INCX)

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin == 10, 'Not enough input arguments.');
eml_prefer_const(UPLO,TRANS,DIAGA,n,ia0,lda,ix0,incx);
if isempty(A) || isempty(x) || n == 0
    return
end
UPPER = UPLO(1) == 'U';
NONUNIT = DIAGA(1) == 'N';
NONTRANS = TRANS(1) == 'N';
NONCONJ = TRANS(1) == 'T';
ONE = ones(eml_index_class);
ia0m1 = eml_index_minus(ia0,1);
if NONTRANS
    % No Tranpose case: x = inv(A)*x
    if UPPER
        % Upper triangular
        for j = n:-1:ONE
            jjA = eml_index_plus( ...
                eml_index_plus(ia0m1,j), ...
                eml_index_times(eml_index_minus(j,1),lda));
            jx = eml_index_plus(ix0, ...
                eml_index_times(eml_index_minus(j,1),incx));
            if NONUNIT
                x(jx) = eml_div(x(jx),A(jjA));
            end
            for i = ONE:eml_index_minus(j,1)
                ix = eml_index_minus(jx,eml_index_times(i,incx));
                x(ix) = x(ix) - x(jx).*A(eml_index_minus(jjA,i));
            end
        end
    else
        % Lower triangular
        for j = ONE:n
            jjA = eml_index_plus( ...
                eml_index_plus(ia0m1,j), ...
                eml_index_times(eml_index_minus(j,1),lda));
            jx = eml_index_plus(ix0, ...
                eml_index_times(eml_index_minus(j,1),incx));
            if NONUNIT
                x(jx) = eml_div(x(jx),A(jjA));
            end
            for i = ONE:eml_index_minus(n,j)
                ix = eml_index_plus(jx,eml_index_times(i,incx));
                x(ix) = x(ix) - x(jx).*A(eml_index_plus(jjA,i));
            end
        end
    end
else
    % Transpose or Conjugate Transpose: x = inv(A.')*x OR x = inv(A')*x
    % The loop direction is reversed from the non-transposed case.
    % This performs the transpose operation implicitly.
    if UPPER
        % Upper triangular case
        for j = ONE:n
            jA = eml_index_plus(ia0m1, ...
                eml_index_times(eml_index_minus(j,1),lda));
            jx = eml_index_plus(j,eml_index_minus(ix0,1));
            temp = x(jx);
            if NONCONJ
                % Transpose only
                for i = ONE:eml_index_minus(j,1)
                    temp = temp - ...
                        A(eml_index_plus(jA,i)) .* ...
                        x(eml_index_plus(ix0,eml_index_times(eml_index_minus(i,1),incx)));
                end
                if NONUNIT
                    temp = eml_div(temp,A(eml_index_plus(jA,j)));
                end
            else
                % Conjugate transpose
                for i = ONE:eml_index_minus(j,1)
                    temp = temp - eml_conjtimes( ...
                        A(eml_index_plus(jA,i)), ...
                        x(eml_index_plus(ix0,eml_index_times(eml_index_minus(i,1),incx))));
                end
                if NONUNIT
                    temp = eml_div(temp,conj(A(eml_index_plus(jA,j))));
                end
            end
            x(jx) = temp;
        end
    else
        % Lower triangular case
        for j = n:-1:ONE
            jA = eml_index_plus(ia0m1, ...
                eml_index_times(eml_index_minus(j,1),lda));
            jx = eml_index_plus(j,eml_index_minus(ix0,1));
            temp = x(jx);
            if NONCONJ
                for i = n:-1:eml_index_plus(j,1)
                    temp = temp - ...
                        A(eml_index_plus(jA,i)) .* ...
                        x(eml_index_plus(ix0,eml_index_times(eml_index_minus(i,1),incx)));
                end
                if NONUNIT
                    temp = eml_div(temp,A(eml_index_plus(jA,j)));
                end
            else
                for i = n:-1:eml_index_plus(j,1)
                    temp = temp - eml_conjtimes( ...
                        A(eml_index_plus(jA,i)), ...
                        x(eml_index_plus(ix0,eml_index_times(eml_index_minus(i,1),incx))));
                end
                if NONUNIT
                    temp = eml_div(temp,conj(A(eml_index_plus(jA,j))));
                end
            end
            x(jx) = temp;
        end
    end
end
