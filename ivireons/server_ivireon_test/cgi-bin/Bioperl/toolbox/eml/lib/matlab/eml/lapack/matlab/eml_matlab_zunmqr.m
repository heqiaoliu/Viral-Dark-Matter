function A = eml_matlab_zunmqr(B,tau,A,ilo,ihi,lastcol)
%Embedded MATLAB Private Function

%   Applies orthogonal transformation in B(ilo:ihi,ilo:ihi) and tau (these
%   are outputs from eml_zgeqrf) to A(ilo:ihi,ilo:lastcol).

%   Copyright 2005-2010 The MathWorks, Inc.
%#eml

i = ilo;
while i <= ihi %for i = ilo : ihi
    ip1 = eml_index_plus(i,1);
    taui = conj(tau(eml_index_minus(ip1,ilo)));
    for j = ilo : lastcol
        wj = conj(A(i,j));
        for k = ip1 : ihi
            wj = wj + eml_conjtimes(A(k,j),B(k,i));
        end
        wj = taui*conj(wj);
        A(i,j) = A(i,j) - wj;
        for k = ip1 : ihi
            A(k,j) = A(k,j) - B(k,i)*wj;
        end
    end
    i = ip1;
end
