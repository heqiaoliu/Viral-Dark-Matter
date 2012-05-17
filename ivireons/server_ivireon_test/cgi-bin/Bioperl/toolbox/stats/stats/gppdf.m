function y = gppdf(x,k,sigma,theta)
%GPPDF Generalized Pareto probability density function (pdf).
%   Y = GPPDF(X,K,SIGMA,THETA) returns the pdf of the generalized Pareto (GP)
%   distribution with tail index (shape) parameter K, scale parameter SIGMA,
%   and threshold (location) parameter THETA, evaluated at the values in X.
%   The size of Y is the common size of the input arguments.  A scalar input
%   functions as a constant matrix of the same size as the other inputs.
%
%   Default values for K, SIGMA, and THETA are 0, 1, and 0, respectively.
%
%   When K = 0 and THETA = 0, the GP is equivalent to the exponential
%   distribution.  When K > 0 and THETA = SIGMA/K, the GP is equivalent to the
%   Pareto distribution.  The mean of the GP is not finite when K >= 1, and the
%   variance is not finite when K >= 1/2.  When K >= 0, the GP has positive
%   density for X>THETA, or, when K < 0, for 0 <= (X-THETA)/SIGMA <= -1/K.
%
%   See also GPCDF, GPFIT, GPINV, GPLIKE, GPRND, GPSTAT, PDF.

%   References:
%      [1] Embrechts, P., C. Klüppelberg, and T. Mikosch (1997) Modelling
%          Extremal Events for Insurance and Finance, Springer.
%      [2] Kotz, S. and S. Nadarajah (2001) Extreme Value Distributions:
%          Theory and Applications, World Scientific Publishing Company.

%   Copyright 1993-2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:14:28 $

if nargin < 1
    error('stats:gpcdf:TooFewInputs', 'Input argument X is undefined.');
end
if nargin < 2 || isempty(k), k = 0;     end
if nargin < 3 || isempty(sigma), sigma = 1; end
if nargin < 4 || isempty(theta), theta = 0; end

[err,sizeOut] = statsizechk(4,x,k,sigma,theta);
if err > 0
    error('stats:gppdf:InputSizeMismatch', ...
          'Non-scalar arguments must match in size.');
end
if isscalar(k), k = repmat(k,sizeOut); end

% Return NaN for out of range parameters.
sigma(sigma <= 0) = NaN;

y = zeros(sizeOut,superiorfloat(x,k,sigma,theta));

% Support is 0 <= x/sigma, force zero below that
z = (x-theta) ./ sigma; z(z<0) = Inf; % max drops NaNs
if isscalar(z), z = repmat(z,sizeOut); end

% Find the k==0 cases and fill them in.
j = (abs(k) < eps);
y(j) = exp(-z(j));

% When k<0, the support is 0 <= x/sigma <= -1/k.
t = z.*k;
jj = (t<=-1 & k<-eps);
t(jj) = 0; % temporarily silence warnings from log1p

% Find the k~=0 cases and fill them in.
j = ~j;
y(j) = exp((-1 - 1./k(j)).*log1p(t(j))); % (1 + z.*k).^(-1 - 1./k)
y(jj) = 0;

y = y ./ sigma;
