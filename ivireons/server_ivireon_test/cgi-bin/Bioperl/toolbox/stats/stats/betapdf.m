function y = betapdf(x,a,b)
%BETAPDF Beta probability density function.
%   Y = BETAPDF(X,A,B) returns the beta probability density
%   function with parameters A and B at the values in X.
%
%   The size of Y is the common size of the input arguments. A scalar input
%   functions as a constant matrix of the same size as the other inputs.
%
%   See also BETACDF, BETAFIT, BETAINV, BETALIKE, BETARND, BETASTAT, PDF,
%            BETA, BETALN.

%   References:
%      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.1.33.

%   Copyright 1993-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/05/10 17:58:34 $

if nargin < 3
   error('stats:betapdf:TooFewInputs','Requires three input arguments.');
end

[errorcode, x, a, b] = distchck(3,x,a,b);

if errorcode > 0
    error('stats:betapdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize y to zero.
if isa(x,'single') || isa(a,'single') || isa(b,'single')
   y = zeros(size(x),'single');
else
   y = zeros(size(x));
end

% Special cases
y(a==1 & x==0) = b(a==1 & x==0);
y(b==1 & x==1) = a(b==1 & x==1);
y(a<1 & x==0) = Inf;
y(b<1 & x==1) = Inf;

% Return NaN for out of range parameters.
y(a<=0) = NaN;
y(b<=0) = NaN;
y(isnan(a) | isnan(b) | isnan(x)) = NaN;

% Normal values
k = a>0 & b>0 & x>0 & x<1;
a = a(k);
b = b(k);
x = x(k);

% Compute logs
smallx = x<0.1;

loga = (a-1).*log(x);

logb = zeros(size(x));
logb(smallx) = (b(smallx)-1) .* log1p(-x(smallx));
logb(~smallx) = (b(~smallx)-1) .* log(1-x(~smallx));

y(k) = exp(loga+logb - betaln(a,b));
