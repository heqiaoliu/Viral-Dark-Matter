function [A,tau] = eml_matlab_zgeqr2(A,ijmin,imax,jmax)
%Embedded MATLAB Private Function

%   QR factorization of A(ijmin:imax,ijmin:jmax).
%   tau(i) corresponds to column i + ijmin - 1.

%   Copyright 2005-2010 The MathWorks, Inc.
%#eml

FLT_RADIX = 2;
SAFMIN = eml_rdivide(FLT_RADIX * realmin(class(A)),eps(class(A)));
RSAFMN = eml_rdivide(1,SAFMIN);
IONE = ones(eml_index_class);
IZERO = zeros(eml_index_class);
m = cast(size(A,1),eml_index_class);
n = cast(size(A,2),eml_index_class);
mn = min2(min2(m,n),min2(imax,jmax));
tau = eml.nullcopy(eml_expand(eml_scalar_eg(A),[min2(m,n),1])); % g467063
tau(:) = 0;
for i = ijmin : mn
    itau = eml_index_plus(eml_index_minus(i,ijmin),IONE); % i - ijmin + 1;
    % Generate elementary reflector H(i).
    i2 = eml_index_times(i,m); % i * m;
    nx = eml_index_minus(imax,i);
    i1 = eml_index_minus(eml_index_plus(i2,IONE),nx); % i2 + 1 - nx;
    xnrm = eml_xnrm2(nx,A,i1,1);
    alphr = real(A(i,i));
    alphi = imag(A(i,i));
    if xnrm == 0 && alphi == 0
        % H  =  I
        tau(itau) = 0;
    else
        if isreal(A)
            beta1 = eml_dlapy2(alphr,xnrm);
        else
            beta1 = eml_dlapy3(alphr,alphi,xnrm);
        end
        if alphr >= 0
            beta1 = -beta1;
        end
        knt = IZERO;
        while abs(beta1) < SAFMIN
            knt = eml_index_plus(knt,IONE);
            for k = i1:i2
                A(k) = A(k)*RSAFMN;
            end
            beta1 = beta1*RSAFMN;
            alphi = alphi*RSAFMN;
            alphr = alphr*RSAFMN;
        end
        if knt > 0
            xnrm = eml_xnrm2(nx,A,i1,1);
            if isreal(A)
                beta1 = eml_dlapy2(alphr,xnrm);
            else
                beta1 = eml_dlapy3(alphr,alphi,xnrm);
            end
            if alphr >= 0
                beta1 = -beta1;
            end
        end
        if isreal(A)
            tau(itau) = eml_rdivide(beta1-alphr,beta1);
            alpha1 = eml_rdivide(1,alphr-beta1);
        else
            tau(itau) = complex(eml_rdivide(beta1-alphr,beta1),eml_rdivide(-alphi,beta1));
            alpha1 = eml_div(1,complex(alphr - beta1,alphi));
        end
        for k = i1 : i2
            A(k) = A(k)*alpha1;
        end
        for k = IONE : knt
            beta1 = beta1*SAFMIN;
        end
        A(i,i) = beta1;
    end
    if i < jmax
        conjtaui = conj(tau(itau));
        if conjtaui ~= 0
            % w = A(i:m,i+1:n)' * [1;A(i+1:m,i)];
            % A(i:m,i+1:n) = A(i:m,i+1:n) - [1;A(i+1:m,i)]*w';
            ip1 = eml_index_plus(i,IONE);
            for j = ip1:jmax
                wj = conj(A(i,j));
                for k = ip1:imax
                    wj = wj + eml_conjtimes(A(k,j),A(k,i));
                end
                wj = conjtaui*conj(wj);
                if wj ~= 0
                    A(i,j) = A(i,j) - wj;
                    for k = ip1:imax
                        A(k,j) = A(k,j) - A(k,i)*wj;
                    end
                end
            end
        end
    end
end

%--------------------------------------------------------------------------

function x = min2(x,y)
eml_must_inline;
% Simple minimum of 2 elements.  Output class is class(x).
if y < x
    x = cast(y,class(x));
end

%--------------------------------------------------------------------------
