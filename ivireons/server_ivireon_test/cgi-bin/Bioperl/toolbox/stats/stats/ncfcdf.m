function p = ncfcdf(x,nu1,nu2,delta)
%NCFCDF Noncentral F cumulative distribution function (cdf).
%   P = NCFCDF(X,NU1,NU2,DELTA) Returns the noncentral F cdf with numerator
%   degrees of freedom (df), NU1, denominator df, NU2, and noncentrality
%   parameter, DELTA, at the values in X.
%
%   The size of P is the common size of the input arguments. A scalar input
%   functions as a constant matrix of the same size as the other inputs.
%
%   See also NCFINV, NCFPDF, NCFRND, NCFSTAT, FCDF, CDF.

%   References:
%      [1]  Johnson, Norman, and Kotz, Samuel, "Distributions in
%      Statistics: Continuous Univariate Distributions-2", Wiley
%      1970 p. 192.
%      [2]  Evans, Merran, Hastings, Nicholas and Peacock, Brian,
%      "Statistical Distributions, Second Edition", Wiley
%      1993 p. 73-74.

%   Copyright 1993-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/05/10 17:58:55 $

if nargin <  4,
    error('stats:ncfcdf:TooFewInputs','Requires four input arguments.');
end

[errorcode x nu1 nu2 delta] = distchck(4,x,nu1,nu2,delta);

if errorcode > 0
    error('stats:ncfcdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

[m,n] = size(x);

% Initialize p to zero.
if isa(x,'single') || isa(nu1,'single') || isa(nu2,'single') || isa(delta,'single')
   p = zeros(m,n,'single');
   cvgtol = eps('single').^(3/4);
else
   p = zeros(m,n);
   cvgtol = eps.^(3/4);
end

% Deal with illegal parameters
k = (nu1 <= 0 | nu2 <= 0 | delta < 0);
p(k) = NaN;

% Deal with x==Inf
p(x==Inf & ~k) = 1;

% Deal with the central distribution
kz = (delta==0);
if any(kz(:))
   p(kz) = fcdf(x(kz),nu1(kz),nu2(kz));
end

% Anything left?
k1 = ~(k | kz | x<=0 | x==Inf);
if ~any(k1(:)), return; end

if ~all(k1(:)) % reset variable so that we don't have to deal with bad indices.
   x = x(k1);
   nu1 = nu1(k1);
   nu2 = nu2(k1);
   delta = delta(k1);
end
x = x(:);

% to simplify computation, pre-divide nu1,nu2 and delta
nu1 = nu1(:)/2; nu2 = nu2(:)/2; delta = delta(:)/2;

%Value passed to Beta distribution function.
tmp = nu1.*x./(nu2+nu1.*x);
logtmp = log(tmp);
nu2const = nu2.*log(1-tmp) - gammaln(nu2);

% Sum the series.  The general idea is that we are going to sum terms
% of the form
%        poisspdf(j,delta) .* betacdf(tmp,j+nu1,nu2)
% We will save some time by computing these pdf and cdf functions once at
% a point that we hope will be near the maximum of the series, and we will
% compute other terms in the series using recurrence relations.
j0 = floor(delta(:));      % start from here

% Compute Poisson pdf and beta cdf at the starting point
ppdf0 = exp(-delta + j0 .* log(delta) - gammaln(j0 + 1));
bcdf0 = betacdf(tmp,j0+nu1,nu2);

% Set up for loop over values less than j0
y = ppdf0 .* bcdf0;
ppdf = ppdf0;
bcdf = bcdf0;
olddy = zeros(size(delta));
deltay = zeros(size(delta));
j = j0-1;
ok = j>=0;
while any(ok)
   % Use recurrence relation to compute new pdf and cdf
   db = exp((j+nu1).*logtmp + nu2const + gammaln(j+nu1+nu2) - gammaln(j+nu1+1));
   ppdf(ok) = ppdf(ok) .* (j(ok)+1) ./ delta(ok);
   bcdf(ok) = bcdf(ok) + db(ok);
   deltay(ok) = ppdf(ok).*bcdf(ok);
   y(ok) = y(ok) + deltay(ok);

   % Convergence test:  change must be small and not increasing
   ok = ok & (deltay>y*cvgtol | abs(deltay)>olddy);

   j = j-1;
   ok = ok & j>=0;
   olddy(ok) = abs(deltay(ok));
end

% Set up again for loop upward from j0
ppdf = ppdf0;
bcdf = bcdf0;
olddy = zeros(size(delta));
j = j0+1;
ok = true(size(j));
for jj = 1:5000    % so that we don't get into an infinite loop
   ppdf = ppdf .* delta ./ j;
   bcdf = bcdf - exp((j+nu1-1).*logtmp + nu2const + ...
                     gammaln(j+nu1+nu2-1) - gammaln(j+nu1));
   deltay = ppdf.*bcdf;
   y = y + deltay;

   % Convergence test:  change must be small and not increasing
   ok = ok & (deltay>y*cvgtol | abs(deltay)>olddy);
   if ~any(ok)
       break;
   end
   
   olddy(ok) = abs(deltay(ok));
   j = j+1;
end

if (jj == 5000)
   warning('stats:ncfcdf:NoConvergence',...
           'Failed to converge, use the result cautiously.');
end

p(k1) = y;
