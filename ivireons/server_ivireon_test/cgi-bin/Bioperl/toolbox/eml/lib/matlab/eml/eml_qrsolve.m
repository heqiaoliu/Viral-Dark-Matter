function [Y,rankR,R] = eml_qrsolve(A,B,ignoreRankDeficiency)
%Embedded MATLAB Private Function

%   Least squares via QR decomposition.
%   Second output is the estimated rank of the R matrix.
%   In the rank deficient case, part of Y is normally zeroed.
%   If ignoreRankDeficiency == true, however, the results are equivalent to
%   [Q,R] = qr(A,0);
%   Y = B \ Q'*R;
%   with no rank deficiency warning.
%   The default is ignoreRankDeficiency = false;

%   Copyright 2005-2010 The MathWorks, Inc.
%#eml

if eml_option('Developer')
    eml_lib_assert(isa(A,'float') && isa(B,'float') && ...
        size(B,1) == size(A,1) && ndims(A) == 2 && ndims(B) == 2, ...
        'EmbeddedMATLAB:eml_qrsolve:sizeClassMismatch', ...
        'Internal error in eml_qrsolve.');
end
if nargin < 3
    ignoreRankDeficiency = false;
end
m = size(A,1);
n = size(A,2);
nb = size(B,2);
mn = min(m,n);
[A,tau,jpvt] = eml_xgeqp3(A);
% rankR = rank(R)
tol = max(m,n) * (abs(real(A(1)))+abs(imag(A(1)))) * eps(class(A));
rankR = 0;
for k = 1:mn
    if abs(real(A(k,k))) + abs(imag(A(k,k))) <= tol
        if ~ignoreRankDeficiency
            eml_warning('MATLAB:rankDeficientMatrix', ...
                ('Rank deficient, rank = %d,  tol = %13.4e.'),rankR,tol);
        end
        break
    end
    rankR = rankR + 1;
end
% Allocate Y
Y = eml_expand(eml_scalar_eg(A,B),[n,nb]);
% B = Q'*B
useComplexCopyB = isreal(B) && ~isreal(A);
if useComplexCopyB
    CB = complex(cast(B,class(Y)));
    for j = 1:mn
        tauj = conj(tau(j));
        if tauj ~= 0
            for k = 1:nb
                wj = CB(j,k);
                for i = j+1:m
                    wj = wj + eml_conjtimes(A(i,j),CB(i,k));
                end
                wj = tauj*wj;
                if wj ~= 0
                    CB(j,k) = CB(j,k) - wj;
                    for i = j+1:m
                        CB(i,k) = CB(i,k) - A(i,j)*wj;
                    end
                end
            end
        end
    end
else
    for j = 1:mn
        tauj = conj(tau(j));
        if tauj ~= 0
            for k = 1:nb
                wj = cast(B(j,k),class(Y));
                for i = j+1:m
                    wj = wj + eml_conjtimes(A(i,j),B(i,k));
                end
                wj = tauj*wj;
                if wj ~= 0
                    B(j,k) = B(j,k) - wj;
                    for i = j+1:m
                        B(i,k) = B(i,k) - A(i,j)*wj;
                    end
                end
            end
        end
    end
end
% B(1:rankR,:) = R(1:rankR,1:rankR)\B(1:rankR,:);
% Y(jpvt,:) = [B; zeros(mb-rankR,nb)];
% We jump around a little bit here to avoid a temporary.
if ignoreRankDeficiency
    rr = mn;
else
    rr = rankR;
end
for k = 1:nb
    for i = 1:rr
        if useComplexCopyB
            Y(jpvt(i),k) = CB(i,k);
        else
            Y(jpvt(i),k) = B(i,k);
        end
    end
    for j = rr:-1:1
        pj = jpvt(j);
        Y(pj,k) = eml_div(Y(pj,k),A(j,j));
        for i = 1:j-1
            Y(jpvt(i),k) = Y(jpvt(i),k) - Y(pj,k)*A(i,j);
        end
    end
end
if nargout == 3
    R = eml.nullcopy(eml_expand(eml_scalar_eg(A),[mn,n]));
    for j = 1:n
        for i = 1:min(j,mn)
            R(i,j) = A(i,j);
        end
        for i = j+1:mn
            R(i,j) = 0;
        end
    end
end
