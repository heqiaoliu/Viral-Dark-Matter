function [m,v] = betastat(a,b)
%BETASTAT Mean and variance for the beta distribution.
%   [M,V] = BETASTAT(A,B) returns the mean and variance 
%   of the beta distribution with parameters A and B.
%
%   See also BETACDF, BETAFIT, BETAINV, BETALIKE, BETAPDF, BETARND.
    
%   References:
%      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.1.33.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:12:21 $

if nargin < 2, 
    error('stats:betastat:TooFewInputs','Requires two input arguments.');
end

[errorcode a b] = distchck(2,a,b);

if errorcode > 0
    error('stats:betastat:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

if isa(a,'single') || isa(b,'single')
   m = zeros(size(a),'single');
else
   m = zeros(size(a));
end
v = m;

%   Return NaN if the parameter values are outside their respective limits.
k = (a <= 0 | b <= 0);
if any(k) 
    m(k) = NaN;
    v(k) = NaN;
end

k1 = ~k;
if any(k1)
    m(k1) = a(k1) ./ (a(k1) + b(k1));
    v(k1) = m(k1) .* b(k1) ./ ((a(k1) + b(k1)) .* (a(k1) + b(k1) + 1));
end

