function x = hygeinv(p,m,k,n)
%HYGEINV Inverse of the hypergeometric cumulative distribution function (cdf).
%   X = HYGEINV(P,M,K,N) returns the inverse of the hypergeometric
%   cdf with parameters M, K, and N. Since the hypergeometric
%   distribution is discrete, HYGEINV returns the smallest integer X,
%   such that the hypergeometric cdf evaluated at X, equals or exceeds P.
%
%   The size of X is the common size of the input arguments. A scalar input
%   functions as a constant matrix of the same size as the other inputs.
%
%   See also HYGECDF, HYGEPDF, HYGERND, HYGESTAT, ICDF.

%   Copyright 1993-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2010/05/10 17:58:50 $

if nargin < 4,
    error('stats:hygeinv:TooFewInputs','Requires four input arguments.');
end

[errorcode p m k n] = distchck(4,p,m,k,n);

if errorcode > 0
    error('stats:hygeinv:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize X to zero.
if isa(p,'single') || isa(m,'single') || isa(k,'single') || isa(n,'single')
   x = zeros(size(p),'single');
else
   x = zeros(size(p));
end
x(isnan(p) | isnan(m) | isnan(k) | isnan(n)) = NaN;

%   Return NaN for values of the parameters outside their respective limits.
k1 = m < 0 | k < 0 | n < 0 | round(m) ~= m | round(k) ~= k ...
    | round(n) ~= n | n > m | k > m | p < 0 | p > 1 | isnan(p);
if any(k1(:))
    x(k1) = NaN;
end

cumdist = hygepdf(x,m,k,n);
count = zeros(size(p));

% Compare P to the hypergeometric distribution for each value of N.
while any(p(:) > cumdist(:)) && count(1) < max(n(:)) && count(1) < max(k(:))
    count = count + 1;
    idx = find(cumdist < p - eps(p));
    x(idx) = x(idx) + 1;
    cumdist(idx) = cumdist(idx) + hygepdf(count(idx),m(idx),k(idx),n(idx));
end

% Check using hygecdf
y = hygecdf(x,m,k,n);
ynew = zeros(size(y));
xnew = x;
under = y<p & ~k1;
while any(under(:))
    ynew(under) = hygecdf(xnew(under)+1,m(under),k(under),n(under));
    xnew(under) = xnew(under)+1;
    under = under & ynew<p;
end
x = xnew;
ynew = zeros(size(y));
xnew = x;
over = y>p & ~k1 & ~under;
while any(over(:))
    ynew(over) = hygecdf(xnew(over)-1,m(over),k(over),n(over));
    over = over & ynew>=p;
    xnew(over) = xnew(over)-1;
end
x = xnew;
