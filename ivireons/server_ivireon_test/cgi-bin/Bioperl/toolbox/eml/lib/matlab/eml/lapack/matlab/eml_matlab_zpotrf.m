function [A,info] = eml_matlab_zpotrf(uplo,n,A,ia0,lda)
%Embedded MATLAB Private Function

%   This is unblocked code, translated from LAPACK functions
%   zpotf2.f/cpotf2.f/dpotf2.f/spotf2.f

%   Copyright 2002-2010 The MathWorks, Inc.
%#eml

eml_assert(nargin == 5, 'Not enough input arguments.');
eml_prefer_const(uplo,n,ia0,lda);
ONE = ones(eml_index_class);
n = cast(size(A,1),eml_index_class);
% We don't need the reference implementation to support every possible
% input, just the ones we use internally.
if eml_option('Developer')
    eml_assert(eml_is_const(uplo) && ...
        ischar(uplo) && eml_numel(uplo) >= 1 && ...
        (uplo(1) == 'U' || uplo(1) == 'L'), ...
        'Unsupported UPLO--must be a constant ''U'' or ''L''.');
    eml_assert(ia0 == ONE, 'Unsupported IA0--must be constant 1.');
    eml_lib_assert(lda == n, ...
        'EmbeddedMATLAB:eml_xpotrf:LDA', ...
        'Unsupported LDA--must equal size(A,1)');
end
info = zeros(eml_index_class);
if isempty(A)
    return
end
RZERO = zeros(class(A));
CZERO = eml_scalar_eg(A);
CONE = 1 + CZERO;
CNEGONE = CZERO - 1;
if uplo(1) == 'L'
    % Compute the Cholesky factorization A = L'*L.
    for j = 1:n
        % Compute L(J,J) and test for non-positive-definiteness.
        jm1 = eml_index_minus(j,1);
        jj = eml_index_plus(j,eml_index_times(jm1,lda)); % Index of A(j,j).
        % AJJ = DBLE( A( J, J ) ) - ZDOTC( J-1, A( J, 1 ), LDA, A( J, 1 ), LDA )
        ajj = real(A(jj)) - real(eml_xdotc(jm1,A,j,lda,A,j,lda));
        if imag(A(jj)) == RZERO && ajj > RZERO
        else
            A(jj) = ajj;
            info = j;
            return
        end
        ajj = eml_sqrt(ajj);
        A(jj) = ajj;
        % Compute elements J+1:N of column J.
        if j < n
            nmj = eml_index_minus(n,j);
            jp1 = eml_index_plus(j,1);
            jp1j = eml_index_plus(jj,1); % Index of A(j+1,j).
            % CALL ZLACGV(J-1,A(J,1),LDA)
            for k = 1:jm1
                A(j,k) = conj(A(j,k));
            end
            % CALL ZGEMV('N',N-J,J-1,-CONE,A(J+1,1),LDA,A(J,1),LDA,CONE,A(J+1,J),1)
            A = eml_xgemv('N',nmj,jm1, ...
                CNEGONE,[],jp1,lda, ...
                [],j,lda,CONE,A,jp1j,ONE);
            % CALL ZLACGV(J-1,A(J,1),LDA)
            for k = 1:jm1
                A(j,k) = conj(A(j,k));
            end
            % CALL ZDSCAL(N-J,ONE/AJJ,A(J+1,J),1)          
            A = eml_xscal(nmj,eml_div(CONE,ajj),A,jp1j,ONE);
        end
    end
else
    % Compute the Cholesky factorization A = U'*U.
    colj = ONE; % Index of A(1,j).
    for j = 1:n
        % Compute U(J,J) and test for non-positive-definiteness.
        jm1 = eml_index_minus(j,1);
        jj = eml_index_plus(colj,jm1); % Index of A(j,j).
        ajj = real(A(jj)) - real(eml_xdotc(jm1,A,colj,ONE,A,colj,ONE));
        if imag(A(jj)) == RZERO && ajj > RZERO
        else
            A(jj) = ajj;
            info = j;
            return
        end
        ajj = eml_sqrt(ajj);
        A(jj) = ajj;
        % Compute elements J+1:N of row J.
        if j < n
            nmj = eml_index_minus(n,j);
            jjp1 = eml_index_plus(jj,n); % Index of A(j,j+1).
            coljp1 = eml_index_plus(colj,n); %Index of A(1,j+1).
            % CALL ZLACGV(J-1,A(1,J),1)
            for k = 1:jm1
                A(k,j) = conj(A(k,j));
            end
            % CALL ZGEMV('T',J-1,N-J,-CONE,A(1,J+1),LDA,A(1,J),1,CONE,A(J,J+1),LDA)
            A = eml_xgemv('T',jm1,nmj, ...
                CNEGONE,[],coljp1,lda, ...
                [],colj,ONE,CONE,A,jjp1,lda);
            % CALL ZLACGV(J-1,A(1,J),1)
            for k = 1:jm1
                A(k,j) = conj(A(k,j));
            end
            % CALL ZDSCAL(N-J,ONE/AJJ,A(J,J+1),LDA)
            A = eml_xscal(nmj,eml_div(CONE,ajj),A,jjp1,n);
            colj = coljp1;
        end
    end
end
