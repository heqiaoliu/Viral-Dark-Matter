function y = gampdf(x,a,b)
%GAMPDF Gamma probability density function.
%   Y = GAMPDF(X,A,B) returns the gamma probability density function with
%   shape and scale parameters A and B, respectively, at the values in X.
%   The size of Y is the common size of the input arguments. A scalar input
%   functions as a constant matrix of the same size as the other inputs.
%
%   Some references refer to the gamma distribution with a single
%   parameter.  This corresponds to the default of B = 1.
%
%   See also GAMCDF, GAMFIT, GAMINV, GAMLIKE, GAMRND, GAMSTAT, GAMMA,
%            GAMMALN.

%   References:
%      [1] Abramowitz, M. and Stegun, I.A. (1964) Handbook of Mathematical
%          Functions, Dover, New York, section 26.1.
%      [2] Evans, M., Hastings, N., and Peacock, B. (1993) Statistical
%          Distributions, 2nd ed., Wiley.

%   Copyright 1993-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2010/05/10 17:58:47 $

if nargin < 2
    error('stats:gampdf:TooFewInputs','Requires at least two input arguments');
elseif nargin < 3
    b = 1;
end

[errorcode, x, a, b] = distchck(3,x,a,b);

if errorcode > 0
    error('stats:gampdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize y to zero.
if isa(x,'single') || isa(a,'single') || isa(b,'single')
   y = zeros(size(x),'single');
else
   y = zeros(size(x));
end

% Return NaN for out of range parameters.
y(a < 0) = NaN;
y(b <= 0) = NaN;
y(isnan(a) | isnan(b) | isnan(x)) = NaN;

% Scale
z = x./b;

% Special cases
i = z==0 & a==1 & b>0;
y(i) = 1./b(i);
y(z==0 & a<1 & b>0) = Inf;

% Normal cases
k = find(z>0 & z<Inf & a>0 & a<Inf & b>0);

if ~isempty(k)
    z = z(k);
    a = a(k)-1;
    b = b(k);
    
    i = a<0;
    y(k(i)) = f(z(i),a(i)+1) .* exp(log(a(i)+1)-log(z(i))) ./ b(i);
    y(k(~i)) = f(z(~i),a(~i)) ./ b(~i);
end

end


function y = f(z,a)
% Compute gampdf without error checking for z>0 and a>0.
y = zeros(size(z));

% z term dominates
i1 = a<=realmin*z;
y(i1) = exp(-z(i1));

% Normal expansion through logs
i2 = z<realmin*a;
y(i2) = exp( a(i2).*log(z(i2)) -z(i2) -gammaln(a(i2)+1) );

% Loader's saddle point expansion
i3 = ~i1 & ~i2;
lnsr2pi = 0.9189385332046727; % log(sqrt(2*pi))
y(i3) = exp(-lnsr2pi -0.5*log(a(i3)) - stirlerr(a(i3)) ...
    - binodeviance(a(i3),z(i3)));
end
