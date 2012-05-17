function [nlogL,acov] = gevlike(params, data)
%GEVLIKE Negative log-likelihood for the generalized extreme value distribution.
%   NLOGL = GEVLIKE(PARAMS,DATA) returns the negative of the log-likelihood
%   for the generalized extreme value (GEV) distribution, evaluated at
%   parameters PARAMS(1) = K, PARAMS(2) = SIGMA, and PARAMS(3) = MU, given
%   DATA.  NLOGL is a scalar.
%
%   [NLOGL, ACOV] = GEVLIKE(PARAMS,DATA) returns the inverse of Fisher's
%   information matrix, ACOV.  If the input parameter values in PARAMS are the
%   maximum likelihood estimates, the diagonal elements of ACOV are their
%   asymptotic variances.  ACOV is based on the observed Fisher's information,
%   not the expected information.
%
%   When K < 0, the GEV is the type III extreme value distribution.  When K >
%   0, the GEV distribution is the type II, or Frechet, extreme value
%   distribution.  If W has a Weibull distribution as computed by the WBLLIKE
%   function, then -W has a type III extreme value distribution and 1/W has a
%   type II extreme value distribution.  In the limit as K approaches 0, the
%   GEV is the mirror image of the type I extreme value distribution as
%   computed by the EVLIKE function.
%
%   The mean of the GEV distribution is not finite when K >= 1, and the
%   variance is not finite when K >= 1/2.  The GEV distribution has positive
%   density only for values of X such that K*(X-MU)/SIGMA > -1.
%
%   See also EVLIKE, GEVCDF, GEVFIT, GEVINV, GEVPDF, GEVRND, GEVSTAT.

%   References:
%      [1] Embrechts, P., C. Klüppelberg, and T. Mikosch (1997) Modelling
%          Extremal Events for Insurance and Finance, Springer.
%      [2] Kotz, S. and S. Nadarajah (2001) Extreme Value Distributions:
%          Theory and Applications, World Scientific Publishing Company.

%   Copyright 1993-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:14:14 $

if nargin < 2
    error('stats:gevlike:TooFewInputs','Requires two input arguments');
elseif ~isvector(data)
    error('stats:gevlike:VectorRequired','DATA must be a vector.');
end

nlogL  = negloglike(params, data);

if nargout > 1
    outClass = superiorfloat(params,data);
    
    % Compute first order central differences of the gradient.
    delta = eps(outClass)^(1/4);
    deltaparams = delta .* max(abs(params), 1);
    e = zeros(size(params),outClass);
    nH = zeros(3,3,outClass);
    for j=1:3
        e(j) = deltaparams(j);
        [dum,Gplus]  = negloglike(params+e, data);
        [dum,Gminus] = negloglike(params-e, data);

        % Normalize the first differences by the increment to get
        % derivative estimates.
        nH(:,j) = (Gplus(:) - Gminus(:)) ./ (2 * deltaparams(j));
        e(j) = 0;
    end

    % The asymptotic cov matrix approximation is the negative inverse
    % of the hessian.
    acov = inv(.5.*(nH + nH'));
end


function [nll,ngrad] = negloglike(parms, data)
% Negative log-likelihood for the GEV.
k     = parms(1);
sigma = parms(2);
lnsigma = log(sigma);
mu    = parms(3);

n = numel(data);
z = (data - mu) ./ sigma;

if abs(k) > eps
    t = 1 + k*z;
    if min(t) > 0
        u = 1 + k.*z;
        lnu = log1p(k.*z); % log(1 + k.*z)
        t = exp(-(1/k)*lnu); % (1 + k.*z).^(-1/k)
        nll = n*lnsigma + sum(t) + (1+1/k)*sum(lnu);
        if nargout > 1
            s = expm1(-(1/k)*lnu); % (1 + k.*z).^(-1/k) - 1
            r = (s - k)./u;
            dk = sum(lnu.*s./k - z.*r)./k;
            dsigma = sum(1+z.*r)./sigma;
            dmu = sum(r)./sigma;
            ngrad = [dk dsigma dmu];
        end
    else
        % The support of the GEV when is 0 < 1+k*z.
        nll = NaN;
        if nargout > 1
            ngrad = [NaN NaN NaN];
        end
    end
else % limiting extreme value dist'n as k->0
    nll = n*lnsigma + sum(exp(-z) + z);
    if nargout > 1
        u = expm1(-z); % exp(-z) - 1
        dk = sum(z.^2.*u/2 + z);
        dsigma = sum(1+z.*u)./sigma;
        dmu = sum(u)./sigma;
        ngrad = [dk dsigma dmu];
    end
end
