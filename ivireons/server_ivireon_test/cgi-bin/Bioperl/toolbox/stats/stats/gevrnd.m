function r = gevrnd(k,sigma,mu,varargin)
%GEVRND Random arrays from the generalized extreme value distribution.
%   R = GEVRND(K,SIGMA,MU) returns an array of random numbers chosen from the
%   generalized extreme value (GEV) distribution with shape parameter K, scale
%   parameter SIGMA, and location parameter MU.  The size of R is the common
%   size of K, SIGMA, and MU if all are arrays.  If any parameter is a scalar,
%   the size of R is the size of the other parameters.
%
%   R = GEVRND(K,SIGMA,MU,M,N,...) or R = GEVRND(K,SIGMA,MU,[M,N,...]) returns
%   an M-by-N-by-... array.
%
%   When K < 0, the GEV is the type III extreme value distribution.  When K >
%   0, the GEV distribution is the type II, or Frechet, extreme value
%   distribution.  If W has a Weibull distribution as computed by the WBLRND
%   function, then -W has a type III extreme value distribution and 1/W has a
%   type II extreme value distribution.  In the limit as K approaches 0, the
%   GEV is the mirror image of the type I extreme value distribution as
%   computed by the EVRND function.
%
%   The mean of the GEV distribution is not finite when K >= 1, and the
%   variance is not finite when K >= 1/2.  The GEV distribution has positive
%   density only for values of X such that K*(X-MU)/SIGMA > -1.
%
%   See also EVRND, GEVCDF, GEVFIT, GEVINV, GEVLIKE, GEVPDF, GEVSTAT, RANDOM.

%   GEVRND uses the inversion method.

%   References:
%      [1] Embrechts, P., C. Klüppelberg, and T. Mikosch (1997) Modelling
%          Extremal Events for Insurance and Finance, Springer.
%      [2] Kotz, S. and S. Nadarajah (2001) Extreme Value Distributions:
%          Theory and Applications, World Scientific Publishing Company.

%   Copyright 1993-2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2010/03/16 00:14:16 $

if nargin < 3
    error('stats:gevrnd:TooFewInputs', ...
          'Requires at least three input arguments.');
end

[err,sizeOut] = statsizechk(3,k,sigma,mu,varargin{:});
if err > 0
    error('stats:gevrnd:InputSizeMismatch', ...
          'Size information is inconsistent.');
end
if isscalar(k), k = repmat(k,sizeOut); end

% Return NaN for elements corresponding to illegal parameter values.
sigma(sigma < 0) = NaN;

r = zeros(sizeOut,superiorfloat(k,sigma,mu));
u = rand(sizeOut);

% Find the k==0 cases and fill them in.
j = (abs(k) < eps);
r(j) = -log(-log(u(j)));

% Find the k~=0 cases and fill them in.
j = ~j;
r(j) = expm1(-k(j).*log(-log(u(j))))./k(j); % ((-log(u)).^(-k) - 1) ./ k

r = mu + sigma.*r;
