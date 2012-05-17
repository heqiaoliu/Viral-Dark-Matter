function r = gprnd(k,sigma,theta,varargin)
%GPRND Random arrays from the generalized Pareto distribution.
%   R = GPRND(K,SIGMA,THETA) returns an array of random numbers chosen from the
%   generalized Pareto (GP) distribution with tail index (shape) parameter K,
%   scale parameter SIGMA, and threshold (location) parameter THETA.  The size
%   of R is the common size of K, SIGMA, and THETA if all are arrays.  If any
%   parameter is a scalar, the size of R is the size of the other parameters.
%
%   R = GPRND(K,SIGMA,THETA,M,N,...) or R = GPRND(K,SIGMA,[M,N,...]) returns
%   an M-by-N-by-... array.
%
%   When K = 0 and THETA = 0, the GP is equivalent to the exponential
%   distribution.  When K > 0 and THETA = SIGMA/K, the GP is equivalent to the
%   Pareto distribution.  The mean of the GP is not finite when K >= 1, and the
%   variance is not finite when K >= 1/2.  When K >= 0, the GP has positive
%   density for X>THETA, or, when K < 0, for 0 <= (X-THETA)/SIGMA <= -1/K.
%
%   See also GPCDF, GPFIT, GPINV, GPLIKE, GPPDF, GPSTAT, RANDOM.

%   GPRND uses the inversion method.

%   References:
%      [1] Embrechts, P., C. Klüppelberg, and T. Mikosch (1997) Modelling
%          Extremal Events for Insurance and Finance, Springer.
%      [2] Kotz, S. and S. Nadarajah (2001) Extreme Value Distributions:
%          Theory and Applications, World Scientific Publishing Company.

%   Copyright 1993-2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:14:29 $

if nargin < 3
    error('stats:gprnd:TooFewInputs', ...
          'Requires at least three input arguments.');
end

[err,sizeOut] = statsizechk(3,k,sigma,theta,varargin{:});
if err > 0
    error('stats:gprnd:InputSizeMismatch', ...
          'Size information is inconsistent.');
end
if isscalar(k), k = repmat(k,sizeOut); end

% Return NaN for elements corresponding to illegal parameter values.
sigma(sigma < 0) = NaN;

r = zeros(sizeOut,superiorfloat(k,sigma,theta));
u = rand(sizeOut);

% Find the k==0 cases and fill them in.
j = (abs(k) < eps);
r(j) = -log(u(j));

% Find the k~=0 cases and fill them in.
j = ~j;
r(j) = expm1(-k(j).*log(u(j))) ./ k(j); % (u.^(-k) - 1) ./ k;

r = theta + sigma.*r;
