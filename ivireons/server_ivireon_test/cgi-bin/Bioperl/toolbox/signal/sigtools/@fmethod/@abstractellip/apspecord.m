function [sos,g,Astop] = apspecord(h,N,Wp,Apass,k,q)
% Specify order ellip analog prototype.

%   Author(s): R. Losada
%   Copyright 1999-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2005/06/16 08:42:29 $

if nargin < 5,
    % q and k are not always available
    [q,k] = computeq(h,Wp);
end

% Stopband attenuation can be found from
Astop = 10*log10((10^(.1*Apass) - 1)/(16*q^N) + 1);

L = 1/(2*N)*log((10^(0.05*Apass) + 1)/(10^(0.05*Apass) - 1));

m = 0:10; % Number of terms of summation

s0 = computes0(q,L,m);

% Special case N=1,
if N == 1,
    sos = [0 0 1 0 1 s0];
    g = s0;
else
    
    W = sqrt((1 + k*(s0^2))*(1 + (s0^2)/k));
    
    [Omega,V] = computeOmega(h,N,q,k);

    a0 = 1./Omega.^2;

    b0 = ((s0*V).^2 + (Omega.*W).^2)./(1 + s0^2.*Omega.^2).^2;

    b1 = 2*s0*V./(1 + s0^2.*Omega.^2);

    H0 = computeH0(N,s0,b0,a0,Apass);

    D0 = computeD0(N,s0);

    % Initialize sos matrix
    sos = zeros(length(a0),6);
    sos(:,[1,4]) = ones(size(sos,1),2);
    sos(:,[3,5,6]) = [a0(:) b1(:) b0(:)];
    if rem(N,2),
        sos(end+1,:) = [0 0 1 0 D0];
    end

    g = H0;
end

%----------------------------------------------------------------------------
function D0 = computeD0(N,s0)

if rem(N,2),
    D0 = [1, s0];
else
    D0 = 1;
end


%----------------------------------------------------------------------------
function H0 = computeH0(N,s0,b0,a0,Apass)

H0 = b0./a0;

if rem(N,2),
    H0(1) = s0*H0(1);
else
    H0(1) = 10^(-0.05*Apass)*H0(1);
end

%----------------------------------------------------------------------------
function s0 = computes0(q,L,m)

sum1 = computesum1(q,L,m);
sum2 = computesum2(q,L,m);
s0 = abs((2*q^(1/4)*sum1)/(1+2.*sum2));
    
%----------------------------------------------------------------------------
function sum1 = computesum1(q,L,m)

sum1 = sum((-1).^m .* q.^(m.*(m+1)).*sinh(L*(2*m+1)));

%----------------------------------------------------------------------------
function sum2 = computesum2(q,L,m)

m = m + 1;
sum2 = sum((-1).^m .* q.^(m.^2).*cosh(L*(2*m)));
