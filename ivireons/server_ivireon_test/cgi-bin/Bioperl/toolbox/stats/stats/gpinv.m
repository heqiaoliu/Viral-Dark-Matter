function x = gpinv(p,k,sigma,theta)
%GPINV Inverse of the generalized Pareto cumulative distribution function (cdf).
%   X = GPINV(P,K,SIGMA,THETA) returns the inverse cdf for a generalized
%   Pareto (GP) distribution with tail index (shape) parameter K, scale
%   parameter SIGMA, and threshold (location) parameter THETA, evaluated at
%   the values in P.  The size of X is the common size of the input arguments.
%   A scalar input functions as a constant matrix of the same size as the
%   other inputs.
%   
%   Default values for K, SIGMA, and THETA are 0, 1, and 0, respectively.
%
%   When K = 0 and THETA = 0, the GP is equivalent to the exponential
%   distribution.  When K > 0 and THETA = SIGMA/K, the GP is equivalent to the
%   Pareto distribution.  The mean of the GP is not finite when K >= 1, and the
%   variance is not finite when K >= 1/2.  When K >= 0, the GP has positive
%   density for X>THETA, or, when K < 0, for 0 <= (X-THETA)/SIGMA <= -1/K.
%
%   See also GPCDF, GPFIT, GPLIKE, GPPDF, GPRND, GPSTAT, ICDF.

%   References:
%      [1] Embrechts, P., C. Klüppelberg, and T. Mikosch (1997) Modelling
%          Extremal Events for Insurance and Finance, Springer.
%      [2] Kotz, S. and S. Nadarajah (2001) Extreme Value Distributions:
%          Theory and Applications, World Scientific Publishing Company.

%   Copyright 1993-2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:14:25 $

if nargin < 1
    error('stats:gpinv:TooFewInputs', 'Input argument P is undefined.');
end
if nargin < 2 || isempty(k), k = 0;     end
if nargin < 3 || isempty(sigma), sigma = 1; end
if nargin < 4 || isempty(theta), theta = 0; end

[err,sizeOut] = statsizechk(4,p,k,sigma,theta);
if err > 0
    error('stats:gpinv:InputSizeMismatch', ...
          'Non-scalar arguments must match in size.');
end
if isscalar(k), k = repmat(k,sizeOut); end

% Return NaN for out of range parameters.
sigma(sigma <= 0) = NaN;

pok = (0<p) & (p<1);
if isscalar(p), p = repmat(p,sizeOut); end

% Return NaN for out of range probabilities.
z = NaN(sizeOut,superiorfloat(p,k,sigma,theta));

% Find the k==0 cases and fill them in.
j = (abs(k) < eps) & pok;
z(j) = -log1p(-p(j));

% Find the k~=0 cases and fill them in.
j = (abs(k) >= eps) & pok;
z(j) = expm1(-k(j).*log1p(-p(j))) ./ k(j); % ((1-p).^(-k) - 1) ./ k;

if ~all(pok)
    % When k<0, the support is 0 <= (x-theta)/sigma <= -1/k
    z(p==0) = 0;
    jj = (p==1 & k<0);
    z(jj) = -1./k(jj);
    z(p==1 & k>=0) = Inf;
end

x = theta + sigma.*z;
