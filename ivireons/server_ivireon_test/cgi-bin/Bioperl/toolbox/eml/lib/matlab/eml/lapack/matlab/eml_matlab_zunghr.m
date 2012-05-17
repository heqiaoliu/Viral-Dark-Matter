function A = eml_matlab_zunghr(n,ilo,ihi,A,ia0,lda,tau,itau0)
%Embedded MATLAB Private Function

%   Copyright 2010 The MathWorks, Inc.
%#eml

if n == 0
    return
end
ONE = ones(eml_index_class);
nh = eml_index_minus(ihi,ilo);
ia0m1 = eml_index_minus(ia0,1);
for j = ihi:-1:eml_index_plus(ilo,1)
    ia = eml_index_plus(ia0m1,eml_index_times(eml_index_minus(j,1),lda));
    for i = ONE:eml_index_minus(j,1)
        % A(i,j) = 0;
        A(eml_index_plus(ia,i)) = 0;
    end
    iajm1 = eml_index_minus(ia,lda);
    for i = eml_index_plus(j,1):ihi
        % A(i,j) = A(i,j-1);
        A(eml_index_plus(ia,i)) = A(eml_index_plus(iajm1,i));
    end
    for i = eml_index_plus(ihi,1):n
        % A(I,J) = 0;
        A(eml_index_plus(ia,i)) = 0;
    end
end
for j = ONE:ilo
    ia = eml_index_plus(ia0m1,eml_index_times(eml_index_minus(j,1),lda));
    for i = 1:n
        % A(i,j) = 0;
        A(eml_index_plus(ia,i)) = 0;
    end
    % A(j,j) = 1;
    A(eml_index_plus(ia,j)) = 1;
end
for j = eml_index_plus(ihi,1):n
    ia = eml_index_plus(ia0m1,eml_index_times(eml_index_minus(j,1),lda));
    for i = ONE:n
        % A(i,j) = 0;
        A(eml_index_plus(ia,i)) = 0;
    end
    % A(j,j) = 1;
    A(eml_index_plus(ia,j)) = 1;
end
% Generate Q(ilo+1:ihi,ilo+1:ihi)
% ZUNGQR(NH,NH,NH,A(ILO+1,ILO+1),LDA,TAU(ILO),WORK,LWORK,IINFO)
ia = eml_index_plus( ...
    eml_index_plus(ia0m1,eml_index_plus(ilo,1)), ...
    eml_index_times(ilo,lda));
itau = eml_index_plus(itau0,eml_index_minus(ilo,1));
A = eml_matlab_zungqr(nh,nh,nh,A,ia,lda,tau,itau);
