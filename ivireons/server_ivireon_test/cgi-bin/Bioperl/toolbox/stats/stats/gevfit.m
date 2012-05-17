function [parmhat,parmci] = gevfit(x,alpha,options)
%GEVFIT Parameter estimates and confidence intervals for generalized extreme value data.
%   PARMHAT = GEVFIT(X) returns maximum likelihood estimates of the parameters
%   of the generalized extreme value (GEV) distribution given the data in X.
%   PARMHAT(1) is the shape parameter, K, PARMHAT(2) is the scale parameter,
%   SIGMA, and PARMHAT(3) is the location parameter, MU.
%
%   [PARMHAT,PARMCI] = GEVFIT(X) returns 95% confidence intervals for the
%   parameter estimates.
%
%   [PARMHAT,PARMCI] = GEVFIT(X,ALPHA) returns 100(1-ALPHA) percent
%   confidence intervals for the parameter estimates.
%
%   [...] = GEVFIT(X,ALPHA,OPTIONS) specifies control parameters for the
%   iterative algorithm used to compute ML estimates. This argument can be
%   created by a call to STATSET.  See STATSET('gevfit') for parameter names
%   and default values.
%
%   Pass in [] for ALPHA to use the default values.
%
%   When K < 0, the GEV is the type III extreme value distribution.  When K >
%   0, the GEV distribution is the type II, or Frechet, extreme value
%   distribution.  If W has a Weibull distribution as computed by the WBLFIT
%   function, then -W has a type III extreme value distribution and 1/W has a
%   type II extreme value distribution.  In the limit as K approaches 0, the
%   GEV is the mirror image of the type I extreme value distribution as
%   computed by the EVFIT function.
%
%   The mean of the GEV distribution is not finite when K >= 1, and the
%   variance is not finite when PSI >= 1/2.  The GEV distribution is defined
%   for K*(X-MU)/SIGMA > -1.
%
%   See also EVFIT, GEVCDF, GEVINV, GEVLIKE, GEVPDF, GEVRND, GEVSTAT, MLE,
%   STATSET.

%   References:
%      [1] Embrechts, P., C. Klüppelberg, and T. Mikosch (1997) Modelling
%          Extremal Events for Insurance and Finance, Springer.
%      [2] Kotz, S. and S. Nadarajah (2001) Extreme Value Distributions:
%          Theory and Applications, World Scientific Publishing Company.

%   Copyright 1993-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:14:12 $

if ~isvector(x)
    error('stats:gevfit:VectorRequired','X must be a vector.');
end

if nargin < 2 || isempty(alpha)
    alpha = 0.05;
end

% The default options include turning fminsearch's display off.  This
% function gives its own warning/error messages, and the caller can turn
% display on to get the text output from fminsearch if desired.
if nargin < 3 || isempty(options)
    options = statset('gevfit');
else
    options = statset(statset('gevfit'),options);
end

classX = class(x);
if strcmp(classX,'single')
    x = double(x);
end

n = length(x);
x = sort(x(:));
xmin = x(1);
xmax = x(end);
rangex = range(x);

% Can't make a fit.
if n == 0 || ~isfinite(rangex)
    parmhat = NaN(1,3,classX);
    parmci = NaN(2,3,classX);
    return
elseif rangex < realmin(classX)
    % When all observations are equal, try to return something reasonable.
    parmhat = [0, 0, x(1)];
    if n == 1
        parmci = cast([-Inf 0 -Inf; Inf Inf Inf],classX);
    else
        parmci = [parmhat; parmhat];
    end
    return
    % Otherwise the data are ok to fit GEV distr, go on.
end

% Get initial param values by linearizing a P-P plot over k.
F = (.5:1:(n-.5))' ./ n;
k0 = fminsearch(@(k) 1-corr(x,gevinv(F,k,1,0)), 0);
b = polyfit(gevinv(F,k0,1,0),x,1);
sigma0 = b(1);
mu0 = b(2);
if (k0 < 0 && (xmax > -sigma0/k0+mu0)) || (k0 > 0 && (xmin < -sigma0/k0+mu0))
    % The initial value cal;culation failed -- the data are not even in the
    % support of the parameter guesses.  Fall back to an EV, whose support is
    % unbounded.
    k0 = 0;
    evparms = evfit(x);
    sigma0 = evparms(2);
    mu0 = evparms(1);
end
parmhat = [k0 log(sigma0) mu0];

% Maximize the log-likelihood with respect to k, lnsigma, and mu.
[parmhat,nll,err,output] = fminsearch(@negloglike,parmhat,options,x);
parmhat(2) = exp(parmhat(2));

if (err == 0)
    % fminsearch may print its own output text; in any case give something
    % more statistical here, controllable via warning IDs.
    if output.funcCount >= options.MaxFunEvals
        wmsg = 'Maximum likelihood estimation did not converge.  Function evaluation limit exceeded.';
    else
        wmsg = 'Maximum likelihood estimation did not converge.  Iteration limit exceeded.';
    end
    warning('stats:gevfit:IterOrEvalLimit',wmsg);
elseif (err < 0)
    error('stats:gevfit:NoSolution',...
          'Unable to reach a maximum likelihood solution.');
end

tolBnd = options.TolBnd;
atBoundary = false;
if ((parmhat(1) < 0) && (xmax > -parmhat(2)/parmhat(1) + parmhat(3) - tolBnd)) || ...
   ((parmhat(1) > 0) && (xmin < -parmhat(2)/parmhat(1) + parmhat(3) + tolBnd))
    warning('stats:gevfit:ConvergedToBoundary', ...
           ['Maximum likelihood has converged to a boundary point of the parameter space.\n' ...
            'Confidence intervals and standard errors cannot be computed reliably.']);
    atBoundary = true;
end

if nargout > 1
    if ~atBoundary
        probs = [alpha/2; 1-alpha/2];
        [nlogL, acov] = gevlike(parmhat, x);
        se = sqrt(diag(acov))';

        % Compute the CI for k using a normal distribution for khat.
        kci = norminv(probs, parmhat(1), se(1));

        % Compute the CI for sigma using a normal approximation for
        % log(sigmahat), and transform back to the original scale.
        % se(log(sigmahat)) is se(sigmahat) / sigmahat.
        lnsigci = norminv(probs, log(parmhat(2)), se(2)./parmhat(2));

        % Compute the CI for mu using a normal distribution for muhat.
        muci = norminv(probs, parmhat(3), se(3));

        parmci = [kci exp(lnsigci) muci];
    else
        parmci = [NaN NaN NaN; NaN NaN NaN];
    end
end

if strcmp(classX,'single')
    parmhat = single(parmhat);
    if nargout > 1
        parmci = single(parmci);
    end
end



function nll = negloglike(parms, data)
% Negative log-likelihood for the GEV (log(sigma) parameterization).
k     = parms(1);
lnsigma = parms(2);
sigma = exp(lnsigma);
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
%         if nargout > 1
%             s = expm1(-(1/k)*lnu); % (1 + k.*z).^(-1/k) - 1
%             r = (s - k)./u;
%             dk = sum(lnu.*s./k - z.*r)./k;
%             dsigma = sum(1+z.*r)./sigma;
%             dmu = sum(r)./sigma;
%             ngrad = [dk dsigma*sigma dmu]; % [dL/dk dL/d(lnsigma) dL/dmu]
%         end
    else
        % The support of the GEV when is 0 < 1+k*z.
        nll = Inf;
%         if nargout > 1
%             ngrad = [-Inf Inf -Inf];
%         end
    end
else % limiting extreme value dist'n as k->0
    nll = n*lnsigma + sum(exp(-z) + z);
%     if nargout > 1
%         u = expm1(-z); % exp(-z) - 1
%         dk = sum(z.^2.*u/2 + z);
%         dsigma = sum(1+z.*u)./sigma;
%         dmu = sum(u)./sigma;
%         ngrad = [dk dsigma*sigma dmu]; % [dL/dk dL/d(lnsigma) dL/dmu]
%     end
end
