function [m,v] = gevstat(k,sigma,mu)
%GEVSTAT Mean and variance of the generalized extreme value distribution.
%   [M,V] = GEVSTAT(K,SIGMA,MU) returns the mean and variance of the
%   generalized extreme value (GEV) distribution with shape parameter K, scale
%   parameter SIGMA, and location parameter MU.
%
%   The sizes of M and V are the common size of the input arguments.  A scalar
%   input functions as a constant matrix of the same size as the other inputs.
%
%   When K < 0, the GEV is the type III extreme value distribution.  When K >
%   0, the GEV distribution is the type II, or Frechet, extreme value
%   distribution.  If W has a Weibull distribution as computed by the WBLSTAT
%   function, then -W has a type III extreme value distribution and 1/W has a
%   type II extreme value distribution.  In the limit as K approaches 0, the
%   GEV is the mirror image of the type I extreme value distribution as
%   computed by the EVSTAT function.
%
%   The mean of the GEV distribution is not finite when K >= 1, and the
%   variance is not finite when K >= 1/2.  The GEV distribution has positive
%   density only for values of X such that K*(X-MU)/SIGMA > -1.
%
%   See also EVSTAT, GEVCDF, GEVFIT, GEVINV, GEVLIKE, GEVPDF, GEVRND.

%   References:
%      [1] Embrechts, P., C. Klüppelberg, and T. Mikosch (1997) Modelling
%          Extremal Events for Insurance and Finance, Springer.
%      [2] Kotz, S. and S. Nadarajah (2001) Extreme Value Distributions:
%          Theory and Applications, World Scientific Publishing Company.

%   Copyright 1993-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:14:17 $

if nargin < 3
    error('stats:gevstat:TooFewInputs', ...
          'Requires at least three input arguments.');
end

[err,sizeOut] = statsizechk(3,k,sigma,mu);
if err > 0
    error('stats:gevstat:InputSizeMismatch', ...
          'Non-scalar arguments must match in size.');
end
lngam1 = gammaln(1 - k);
lngam2 = gammaln(1 - 2*k);
if isscalar(k)
    k = repmat(k,sizeOut);
    lngam1 = repmat(lngam1,sizeOut);
    lngam2 = repmat(lngam2,sizeOut);
end

% Return NaN for out of range parameters.
sigma(sigma <= 0) = NaN;

m = NaN(sizeOut,superiorfloat(k,sigma,mu));
v = NaN(sizeOut,superiorfloat(k,sigma,mu));

% Find the k==0 cases and fill them in.  Switch over to the limiting case
% before errors in computing lngam1 and lngam2 start to dominate m and v. 
jm = (abs(k) < 1e-8);
m(jm) = -psi(1);  % Euler's constant
jv = (abs(k) < 5e-6);
v(jv) = pi^2 / 6; % psi(1,1)

% Find the k~=0 cases and fill in the mean.
jm = ~jm;
jj = jm & (k < 1);
m(jj) = expm1(lngam1(jj)) ./ k(jj); % (gam1 - 1) ./ k
m(k >= 1) = Inf;

% Find the k~=0 cases and fill in the variance.
jv = ~jv;
jj = jv & (k < 1/2);
v(jj) = (expm1(lngam2(jj)) - expm1(2*lngam1(jj))) ./ k(jj).^2;
                                          % (gam2 - gam1.^2) ./ k.^2
v(k >= 1/2) = Inf;

m = mu + sigma .* m;
v = sigma.^2 .* v;
