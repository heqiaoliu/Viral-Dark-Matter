function [nlogL,acov] = gplike(params, data)
%GPLIKE Negative log-likelihood for the generalized Pareto distribution.
%   NLOGL = GPLIKE(PARAMS,DATA) returns the negative of the log-likelihood for
%   the two-parameter generalized Pareto (GP) distribution, evaluated at
%   parameters PARAMS(1) = K and PARAMS(2) = SIGMA, given DATA.  GPLIKE does
%   not allow a threshold (location) parameter.   NLOGL is a scalar.
%
%   [NLOGL, ACOV] = GPLIKE(PARAMS,DATA) returns the inverse of Fisher's
%   information matrix, ACOV.  If the input parameter values in PARAMS are the
%   maximum likelihood estimates, the diagonal elements of ACOV are their
%   asymptotic variances.  ACOV is based on the observed Fisher's information,
%   not the expected information.
%
%   When K = 0 and THETA = 0, the GP is equivalent to the exponential
%   distribution.  When K > 0 and THETA = SIGMA/K, the GP is equivalent to the
%   Pareto distribution.  The mean of the GP is not finite when K >= 1, and the
%   variance is not finite when K >= 1/2.  When K >= 0, the GP has positive
%   density for X>THETA, or, when K < 0, for 0 <= (X-THETA)/SIGMA <= -1/K.
%
%   See also GPCDF, GPFIT, GPINV, GPPDF, GPRND, GPSTAT.

%   References:
%      [1] Embrechts, P., C. Klüppelberg, and T. Mikosch (1997) Modelling
%          Extremal Events for Insurance and Finance, Springer.
%      [2] Kotz, S. and S. Nadarajah (2001) Extreme Value Distributions:
%          Theory and Applications, World Scientific Publishing Company.

%   Copyright 1993-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:14:26 $

if nargin < 2
    error('stats:gplike:TooFewInputs','Requires two input arguments');
elseif ~isvector(data)
    error('stats:gplike:VectorRequired','DATA must be a vector.');
end

k       = params(1);    % Tail index parameter
sigma   = params(2);    % Scale parameter
lnsigma = log(sigma);   % Scale parameter, logged

n = numel(data);
z = data./sigma;

if abs(k) > eps
    if k > 0 || max(z) < -1/k
        u = 1 + k.*z;
        sumlnu = sum(log1p(k.*z));
        nlogL = n*lnsigma + (1+1/k).*sumlnu;
        if nargout > 1
            v = z./u;
            sumv = sum(v);
            sumvsq = sum(v.^2);
            nH11 = 2*sumlnu./k^3 - 2*sumv./k^2 - (1+1/k).*sumvsq;
            nH12 = (-sumv + (k+1).*sumvsq)./sigma;
            nH22 = (-n + 2*(k+1).*sumv - k*(k+1).*sumvsq)./sigma^2;
            acov = [nH22 -nH12; -nH12 nH11] / (nH11*nH22 - nH12*nH12);
        end
    else
        % The support of the GP when k<0 is 0 < y < abs(sigma/k)
        nlogL = Inf;
        if nargout > 1
            acov = [NaN NaN; NaN NaN];
        end
    end
else % limiting exponential dist'n as k->0
    % Handle limit explicitly to prevent (1/0) * log(1) == Inf*0 == NaN.
    nlogL = n*lnsigma + sum(z);
    if nargout > 1
        sumz = sum(z);
        sumzsq = sum(z.^2);
        sumzcb = sum(z.^3);
        nH11 = (2/3)*sumzcb - sumzsq;
        nH12 = (-n + 2*sumz)./sigma^2;
        nH22 = (-sumz + sumzsq)./sigma;
        acov = [nH22 -nH12; -nH12 nH11] / (nH11*nH22 - nH12*nH12);
    end
end
