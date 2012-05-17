function x = gevinv(p,k,sigma,mu)
%GEVINV Inverse of the generalized extreme value cumulative distribution function (cdf).
%   X = GEVINV(P,K,SIGMA,MU) returns the inverse cdf for a generalized extreme
%   value (GEV) distribution with shape parameter K, scale parameter SIGMA, and
%   location parameter MU, evaluated at the values in P.  The size of X is
%   the common size of the input arguments.  A scalar input functions as a
%   constant matrix of the same size as the other inputs.
%   
%   Default values for K, SIGMA, and MU are 0, 1, and 0, respectively.
%
%   When K < 0, the GEV is the type III extreme value distribution.  When K >
%   0, the GEV distribution is the type II, or Frechet, extreme value
%   distribution.  If W has a Weibull distribution as computed by the WBLINV
%   function, then -W has a type III extreme value distribution and 1/W has a
%   type II extreme value distribution.  In the limit as K approaches 0, the
%   GEV is the mirror image of the type I extreme value distribution as
%   computed by the EVINV function.
%
%   The mean of the GEV distribution is not finite when K >= 1, and the
%   variance is not finite when K >= 1/2.  The GEV distribution has positive
%   density only for values of X such that K*(X-MU)/SIGMA > -1.
%
%   See also EVINV, GEVCDF, GEVFIT, GEVLIKE, GEVPDF, GEVRND, GEVSTAT, ICDF.

%   References:
%      [1] Embrechts, P., C. Klüppelberg, and T. Mikosch (1997) Modelling
%          Extremal Events for Insurance and Finance, Springer.
%      [2] Kotz, S. and S. Nadarajah (2001) Extreme Value Distributions:
%          Theory and Applications, World Scientific Publishing Company.

%   Copyright 1993-2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:14:13 $

if nargin < 1
    error('stats:gevinv:TooFewInputs', 'Input argument P is undefined.');
end
if nargin < 2, k = 0;     end
if nargin < 3, sigma = 1; end
if nargin < 4, mu = 0;    end

[err,sizeOut] = statsizechk(4,p,k,sigma,mu);
if err > 0
    error('stats:gevinv:InputSizeMismatch', ...
          'Non-scalar arguments must match in size.');
end
if isscalar(k), k = repmat(k,sizeOut); end

% Return NaN for out of range parameters.
sigma(sigma <= 0) = NaN;

pok = (0<p) & (p<1);
if isscalar(p), p = repmat(p,sizeOut); end

% Return NaN for out of range probabilities.
z = NaN(sizeOut,superiorfloat(p,k,sigma,mu));

% Find the k==0 cases and fill them in.
j = (abs(k) < eps) & pok;
z(j) = -log(-log(p(j)));

% Find the k~=0 cases and fill them in.
j = (abs(k) >= eps) & pok;
z(j) = expm1(-k(j).*log(-log(p(j))))./k(j); % ((-log(u)).^(-k) - 1) ./ k

if ~all(pok)
    % When k~=0, the support is 1 + k.*(x-mu)/sigma > 0
    z(p==0 & k<=0) = -Inf;
    jj = (p==1 & k<0);
    z(jj) = -1./k(jj);
    jj = (p==0 & k>0);
    z(jj) = -1./k(jj);
    z(p==1 & k>=0) = Inf;
end

x = mu + sigma.*z;
