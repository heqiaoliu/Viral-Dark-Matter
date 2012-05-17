function [a,tau] = eml_matlab_zgehrd(a)
%Embedded MATLAB Private Function

%   Based on:
%       -- LAPACK auxiliary routine ZGEHRD (version 3.2) --
%   This is unblocked code from ZGEHD2.

%   Copyright 2010 The MathWorks, Inc.
%#eml

n = cast(size(a,1),eml_index_class);
ONE = ones(eml_index_class);
ilo = ONE;
ihi = n;
if n < 1
    ntau = zeros(eml_index_class);
else
    ntau = eml_index_minus(n,1);
end
tau = eml.nullcopy(eml_expand(eml_scalar_eg(a),[ntau,1]));
work = eml_expand(eml_scalar_eg(a),[n,1]);
for i = ilo:eml_index_minus(ihi,1)
    im1 = eml_index_minus(i,1);
    ip1 = eml_index_plus(i,1);
    im1n = eml_index_times(im1,n);
    in = eml_index_times(i,n);
    % Compute elementary reflector H(i) to annihilate A(i+2:ihi,i)
    alpha1 = a(ip1,i);
    % zlarfg(ihi-i,alpha,a(min(i+2,n),i),1,tau(i))
    ia0 = eml_index_plus(min(eml_index_plus(i,2),n),eml_index_times(im1,n));
    [alpha1,a,tau(i)] = eml_matlab_zlarfg(eml_index_minus(ihi,i),alpha1,a,ia0,ONE);
    a(ip1,i) = 1;
    % Apply H(i) to A(1:ihi,i+1:ihi) from the right
    % zlarf('right',ihi,ihi-i,a(i+1,i),1,tau(i),a(1,i+1),lda,work)
    [a,work] = eml_matlab_zlarf('R', ...
        ihi,eml_index_minus(ihi,i), ...
        [],eml_index_plus(ip1,im1n),ONE, ...
        tau(i), ...
        a,eml_index_plus(in,1),n, ...
        work);
    % Apply H(i)' to A(i+1:ihi,i+1:n) from the left
    % zlarf('left',ihi-i,n-i,a(i+1,i),1,dconjg(tau(i)),a(i+1,i+1),lda,work)
    [a,work] = eml_matlab_zlarf('L', ...
        eml_index_minus(ihi,i),eml_index_minus(n,i), ...
        [],eml_index_plus(ip1,im1n),ONE, ...
        conj(tau(i)), ...
        a,eml_index_plus(ip1,in),n, ...
        work);
    a(ip1,i) = alpha1;
end
