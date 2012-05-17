function [parmhat,parmci] = gpfit(x,alpha,options)
%GPFIT Parameter estimates and confidence intervals for generalized Pareto data.
%   PARMHAT = GPFIT(X) returns maximum likelihood estimates of the parameters
%   of the two-parameter generalized Pareto (GP) distribution given the data
%   in X.  PARMHAT(1) is the tail index (shape) parameter, K and PARMHAT(2) is
%   the scale parameter, SIGMA.  GPFIT does not fit a threshold (location)
%   parameter.
%
%   [PARMHAT,PARMCI] = GPFIT(X) returns 95% confidence intervals for the
%   parameter estimates.
%
%   [PARMHAT,PARMCI] = GPFIT(X,ALPHA) returns 100(1-ALPHA) percent confidence
%   intervals for the parameter estimates.
%
%   [...] = GPFIT(X,ALPHA,OPTIONS) specifies control parameters for the
%   iterative algorithm used to compute ML estimates. This argument can be
%   created by a call to STATSET.  See STATSET('gpfit') for parameter names
%   and default values.
%
%   Pass in [] for ALPHA to use the default values.
%
%   Other functions for the generalized Pareto, such as GPCDF, allow a
%   threshold parameter THETA.  However, GPFIT does not estimate THETA, and it
%   must be assumed known, and subtracted from X before calling GPFIT.
%
%   When K = 0 and THETA = 0, the GP is equivalent to the exponential
%   distribution.  When K > 0 and THETA = SIGMA/K, the GP is equivalent to the
%   Pareto distribution.  The mean of the GP is not finite when K >= 1, and the
%   variance is not finite when K >= 1/2.  When K >= 0, the GP has positive
%   density for X>THETA, or, when K < 0, for 0 <= (X-THETA)/SIGMA <= -1/K.
%
%   See also GPCDF, GPINV, GPLIKE, GPPDF, GPRND, GPSTAT, MLE, STATSET.

%   References:
%      [1] Embrechts, P., C. Klüppelberg, and T. Mikosch (1997) Modelling
%          Extremal Events for Insurance and Finance, Springer.
%      [2] Kotz, S. and S. Nadarajah (2001) Extreme Value Distributions:
%          Theory and Applications, World Scientific Publishing Company.

%   Copyright 1993-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:14:24 $

if ~isvector(x)
    error('stats:gpfit:VectorRequired','X must be a vector.');
elseif any(x <= 0)
    error('stats:gpfit:BadData','The data in X must be positive.');
end

if nargin < 2 || isempty(alpha)
    alpha = 0.05;
end

% The default options include turning fminsearch's display off.  This
% function gives its own warning/error messages, and the caller can turn
% display on to get the text output from fminsearch if desired.
if nargin < 3 || isempty(options)
    options = statset('gpfit');
else
    options = statset(statset('gpfit'),options);
end

classX = class(x);
if strcmp(classX,'single')
    x = double(x);
end

n = length(x);
x = sort(x(:));
xmax = x(end);
rangex = range(x);

% Can't make a fit.
if n == 0 || ~isfinite(rangex)
    parmhat = NaN(1,2,classX);
    parmci = NaN(2,2,classX);
    return
elseif rangex < realmin(classX)
    % When all observations are equal, try to return something reasonable.
    if xmax <= sqrt(realmax(classX));
        parmhat = cast([NaN 0],classX);
    else
        parmhat = cast([-Inf Inf]);
    end
    parmci = [parmhat; parmhat];
    return
    % Otherwise the data are ok to fit GP distr, go on.
end

% This initial guess is the method of moments:
xbar = mean(x);
s2 = var(x);
k0 = -.5 .* (xbar.^2 ./ s2 - 1);
sigma0 = .5 .* xbar .* (xbar.^2 ./ s2 + 1);
if k0 < 0 && (xmax >= -sigma0/k0)
    % Method of moments failed, start with an exponential fit
    k0 = 0;
    sigma0 = xbar;
end
parmhat = [k0 log(sigma0)];

% Maximize the log-likelihood with respect to k and lnsigma.
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
    warning('stats:gpfit:IterOrEvalLimit',wmsg);
elseif (err < 0)
    error('stats:gpfit:NoSolution',...
          'Unable to reach a maximum likelihood solution.');
end

tolBnd = options.TolBnd;
atBoundary = false;
if (parmhat(1) < 0) && (xmax > -parmhat(2)/parmhat(1) - tolBnd)
    warning('stats:gpfit:ConvergedToBoundary', ...
           ['Maximum likelihood has converged to a boundary point of the parameter space.\n' ...
            'Confidence intervals and standard errors can not be computed reliably.']);
    atBoundary = true;
elseif (parmhat(1) <= -1/2)
    warning('stats:gpfit:ConvergedToBoundary', ...
           ['Maximum likelihood has converged to an estimate of K < -1/2.\n' ...
            'Confidence intervals and standard errors can not be computed reliably.']);
    atBoundary = true;
end

if nargout > 1
    if ~atBoundary
        probs = [alpha/2; 1-alpha/2];
        [nlogL, acov] = gplike(parmhat, x);
        se = sqrt(diag(acov))';

        % Compute the CI for k using a normal distribution for khat.
        kci = norminv(probs, parmhat(1), se(1));

        % Compute the CI for sigma using a normal approximation for
        % log(sigmahat), and transform back to the original scale.
        % se(log(sigmahat)) is se(sigmahat) / sigmahat.
        lnsigci = norminv(probs, log(parmhat(2)), se(2)./parmhat(2));

        parmci = [kci exp(lnsigci)];
    else
        parmci = [NaN NaN; NaN NaN];
    end
end

if strcmp(classX,'single')
    parmhat = single(parmhat);
    if nargout > 1
        parmci = single(parmci);
    end
end


function nll = negloglike(parms, data)
% Negative log-likelihood for the GP (log(sigma) parameterization).
k       = parms(1);
lnsigma = parms(2);
sigma   = exp(lnsigma);

n = numel(data);
z = data./sigma;

if abs(k) > eps
    if k > 0 || max(z) < -1/k
        u = 1 + k.*z;
        sumlnu = sum(log1p(k.*z)); % sum(log(1+k.*z)
        nll = n*lnsigma + (1+1/k) * sumlnu;
%         if nargout > 1
%             v = z./u;
%             sumv = sum(v);
%             dk = -sumlnu./k^2 + (1+1/k)*sumv;
%             dsigma = (n - (k+1)*sumv)./sigma;
%             ngrad = [dk dsigma*sigma]; % [dL/dk dL/d(lnsigma)]
%         end
    else
        % The support of the GP when k<0 is 0 < x < abs(sigma/k).
        nll = Inf;
%         if nargout > 1
%             ngrad = [-Inf Inf];
%         end
    end
else % limiting exponential dist'n as k->0
    sumz = sum(z);
    sumzsq = sum(z.^2);
    nll = n*lnsigma + sumz;
%     if nargout > 1
%         dk = -sumzsq/2 + sumz;
%         dsigma = (n - sumz)./sigma;
%         ngrad = [dk dsigma*sigma]; % [dL/dk dL/d(lnsigma)]
%     end
end
