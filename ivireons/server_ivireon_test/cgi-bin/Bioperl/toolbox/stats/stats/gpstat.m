function [m,v] = gpstat(k,sigma,theta)
%GPSTAT Mean and variance of the generalized Pareto distribution.
%   [M,V] = GPSTAT(K,SIGMA,THETA) returns the mean and variance of the
%   generalized Pareto (GP) distribution with tail index (shape) parameter K,
%   scale parameter SIGMA, and threshold (location) parameter THETA.
%
%   The default value for THETA is 0.
%
%   When K = 0 and THETA = 0, the GP is equivalent to the exponential
%   distribution.  When K > 0 and THETA = SIGMA/K, the GP is equivalent to the
%   Pareto distribution.  The mean of the GP is not finite when K >= 1, and the
%   variance is not finite when K >= 1/2.  When K >= 0, the GP has positive
%   density for X>THETA, or, when K < 0, for 0 <= (X-THETA)/SIGMA <= -1/K.
%
%   See also GPCDF, GPFIT, GPINV, GPLIKE, GPPDF, GPRND.

%   References:
%      [1] Embrechts, P., C. Klüppelberg, and T. Mikosch (1997) Modelling
%          Extremal Events for Insurance and Finance, Springer.
%      [2] Kotz, S. and S. Nadarajah (2001) Extreme Value Distributions:
%          Theory and Applications, World Scientific Publishing Company.

%   Copyright 1993-2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:14:30 $

if nargin < 2
    error('stats:gpstat:TooFewInputs', ...
          'Requires at least two input arguments.');
end
if nargin < 3 || isempty(theta), theta = 0; end

[err,sizeOut] = statsizechk(3,k,sigma,theta);
if err > 0
    error('stats:gpstat:InputSizeMismatch', ...
          'Non-scalar arguments must match in size.');
end

% Return NaN for out of range parameters.
sigma(sigma <= 0) = NaN;

m = NaN(sizeOut,superiorfloat(k,sigma,theta));
v = NaN(sizeOut,superiorfloat(k,sigma,theta));

% Find the k==0 cases and fill them in.
j = (abs(k) < eps);
m(j) = 1;
v(j) = 1;

% Find the k~=0 cases and fill in the mean.
j = ~j;
jj = j & (k < 1);
m(jj) = 1 ./ (1 - k(jj));
m(k >= 1) = Inf;

% Find the k~=0 cases and fill in the variance.
jj = j & (k < 1/2);
v(jj) = 1 ./ ((1-k(jj)).^2 .* (1-2.*k(jj)));
v(k >= 1/2) = Inf;

m = theta + sigma .* m;
v = sigma.^2 .* v;
