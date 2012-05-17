function D = debye(x,k)
%DEBYE Debye function.
%   Y = DEBYE(X,K) returns the K-th order Debye function, evaluated at X.
%   X and K are scalars.  For real X, this is defined as
%
%      (K/X^K) * integral from 0 to X of (t/(exp(t)-1)) dt
%
%   The Debye function satisfies D_K(-X) = D_K(X) + K*X/(K+1) however, DEBYE
%   calculates D_K(X) directly for negative X.
%
%   Accurate to at least 6 digits (absolute) for orders 1 through 4.

%   Copyright 2005-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:28:25 $

absx = abs(x);
if absx > 1
    D = k*quadgk(@(x)debye_integrand(x,k),0,x,'AbsTol',1e-10,'RelTol',0)./(x.^k);
elseif absx > 0
    % see Abramowitz&Stegun, 27.1.1
    j = 1:10;
    logB2j = log([1/6 1/30 1/42 1/30 5/66 691/2730 7/6 3617/510 43867/798 174611/330]);
    signB2j = [1 -1 1 -1 1 -1 1 -1 1 -1];
    D = 1 - .5*x*k./(k+1) ...
          + k*sum(signB2j.*exp(logB2j + 2*j.*log(absx) - log(2*j+k) - gammaln(2*j+1)));
else
    D = ones(class(x));
end

function y = debye_integrand(t,k)
y = ones(size(t),class(t));
nz = (abs(t) >= realmin(class(t)));
y(nz) = (t(nz).^k) ./ expm1(t(nz));
