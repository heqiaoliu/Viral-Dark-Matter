function A = eml_matlab_zungqr(m,n,k,A,ia0,lda,tau,itau0)
%Embedded MATLAB Private Function

%   ZUNGQR( M, N, K, A, LDA, TAU, WORK, LWORK, INFO )
%   The WORK vector is managed automatically.

%   Copyright 2002-2010 The MathWorks, Inc.
%#eml
ONE = ones(eml_index_class);
ZERO = zeros(eml_index_class);
if n < 1
    return
end
% Initialise columns k+1:n to columns of the unit matrix
for j = k:eml_index_minus(n,1)
    ia = eml_index_plus(ia0,eml_index_times(j,lda));
    for i = ZERO:eml_index_minus(m,1)
        A(eml_index_plus(ia,i)) = 0;
    end
    A(eml_index_plus(ia,j)) = 1;
end
itau = eml_index_plus(eml_index_minus(itau0,1),k);
work = eml_expand(eml_scalar_eg(A),[size(A,2),1]);
i = k;
while i >= ONE
    iaii = eml_index_plus( ...
        eml_index_plus(eml_index_minus(ia0,1),i), ...
        eml_index_times(eml_index_minus(i,1),lda));
    % Apply H(i) to A(i:m,i:n) from the left
    if i < n
        A(iaii) = 1;
        % ZLARF('L',M-I+1,N-I,A(I,I),1,TAU(I),A(I,I+1),LDA,WORK)
        [A,work] = eml_matlab_zlarf('L', ...
            eml_index_plus(eml_index_minus(m,i),1), ...
            eml_index_minus(n,i),[],iaii,ONE,tau(itau), ...
            A,eml_index_plus(iaii,lda),lda,work);
    end
    if i < m
        % ZSCAL(M-I,-TAU(I),A(I+1,I),1)
        A = eml_xscal(eml_index_minus(m,i),-tau(itau), ...
            A,eml_index_plus(iaii,1),ONE);
    end
    A(iaii) = 1 - tau(itau);
    % Set A(1:i-1,i) to zero    
    for j = ONE:eml_index_minus(i,1)
        A(eml_index_minus(iaii,j)) = 0;
    end
    itau = eml_index_minus(itau,1);
    i = eml_index_minus(i,1);
end
