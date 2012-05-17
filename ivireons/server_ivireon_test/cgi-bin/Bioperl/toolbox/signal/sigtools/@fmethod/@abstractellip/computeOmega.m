function [Omega,V] = computeOmega(this,N,q,k)
%COMPUTEOMEGA   

%   Author(s): R. Losada
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2005/06/16 08:42:30 $


m = 0:10; % Number of terms of summation

[indx,mu] = computeindxNmu(N);

Omega = zeros(1,length(indx));
for i = 1:length(indx),
    sum3 = computesum3(q,N,mu(i),m);
    sum4 = computesum4(q,N,mu(i),m);

    Omega(i) = 2*q^(1/4)*sum3/(1 + 2*sum4);
end

V = real(sqrt((1 - k*Omega.^2).*(1 - Omega.^2/k))); % In extreme cases,
                                                    % there could be
                                                    % roundoff that may
                                                    % make V complex.
%----------------------------------------------------------------------------
function sum3 = computesum3(q,N,mu,m)

sum3 = sum((-1).^m .* q.^(m.*(m+1)).*sin(mu*pi.*(2*m+1)/N));

%----------------------------------------------------------------------------
function sum4 = computesum4(q,N,mu,m)

m = m + 1;
sum4 = sum((-1).^m .* q.^(m.^2).*cos(mu*pi.*(2*m)/N));

%----------------------------------------------------------------------------
function [indx,mu] = computeindxNmu(N)

if rem(N,2),
    r = (N-1)/2;
    mu = 1:r;
else
    r = N/2;
    mu = (1:r) - 1/2;
end

indx = 1:r;


% [EOF]
