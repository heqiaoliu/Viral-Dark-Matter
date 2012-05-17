function varargout = copulafit(family,u,varargin)
%COPULAFIT Fit a parametric copula to data.
%   RHOHAT = COPULAFIT('Gaussian', U) returns an estimate RHOHAT of the matrix
%   of linear correlation parameters for a Gaussian copula, given data in U.  U
%   is an N-by-P matrix of values in (0,1), representing N points in the
%   P-dimensional unit hypercube.
%
%   [RHOHAT, NUHAT] = COPULAFIT('t', U) returns an estimate RHOHAT of the matrix
%   of linear correlation parameters for a t copula, and an estimate NUHAT of
%   the degrees of freedom parameter, given data in U.  U is an N-by-P matrix of
%   values in (0,1), representing N points in the P-dimensional unit hypercube.
%
%   [RHOHAT, NUHAT, NUCI] = COPULAFIT('t', U) returns an approximate 95%
%   confidence interval for the degrees of freedom parameter for a t copula,
%   given data in U.
%
%   PARAMHAT = COPULAFIT(FAMILY, U) returns an estimate PARAMHAT of the copula
%   parameter for an Archimedean copula specified by FAMILY, given data in U.  U
%   is an N-by-2 matrix of values in (0,1), representing N points in the unit
%   square.  FAMILY is 'Clayton', 'Frank', or 'Gumbel'.
%
%   [PARAMHAT, PARAMCI] = COPULAFIT(FAMILY, U) returns an approximate 95%
%   confidence interval for the copula parameter from an Archimedean copula
%   specified by FAMILY, given data in U.
%
%   [...] = COPULAFIT(..., 'Alpha', ALPHA) returns an approximate 100(1-ALPHA)%
%   confidence interval for the parameter estimate.
%
%   COPULAFIT uses maximum likelihood to fit the copula to U.  When U contains
%   data transformed to the unit hypercube by parametric estimates of their
%   marginal cumulative distribution functions, this is known as the Inference
%   Functions for Margins (IFM) method.  When U contains data transformed by
%   the empirical CDF, this is known as Canonical Maximum Likelihood (CML).
%
%   [...] = COPULAFIT('t', U, ..., 'Method', 'ApproximateML') fits a t copula by
%   maximizing an objective function, as suggested by Bouye et al., that
%   approximates the profile log-likelihood for the degrees of freedom parameter
%   nu, for large sample sizes.  This method can be significantly faster than
%   using maximum likelihood, however, it should be used with caution because
%   the estimates and confidence limits may not be accurate for small or
%   moderate sample sizes.  COPULAFIT('t', U, ..., 'Method', 'ML') is equivalent
%   to the default maximum likelihood fit.
%
%   [...] = COPULAFIT(..., 'Options', OPTIONS) specifies control parameters for
%   the iterative algorithm used to compute estimates.  This argument can be
%   created by a call to STATSET.  See STATSET('copulafit') for parameter names
%   and default values.  This argument does not apply to the 'Gaussian' family.
%
%   See also ECDF, COPULACDF, COPULAPDF, COPULARND.

%   References:
%      [1] Bouye, E., Durrleman, V., Nikeghbali, A., Riboulet, G., Roncalli, T.
%          (2000), "Copulas for Finance: A Reading Guide and Some Applications",
%          Working Paper, Groupe de Recherche Operationnelle, Credit Lyonnais.

%   Copyright 2007-2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:13:03 $

if nargin < 2
    error('stats:copulafit:TooFewInputs', 'Requires at least two input arguments.');
end
[n,d] = size(u);

if ndims(u)~=2 || d<2
    error('stats:copulafit:InvalidDataDimensions', ...
          'U must be a matrix with two or more columns.');
elseif ~all(all(0 < u & u < 1))
    error('stats:copulafit:DataOutOfRange', ...
          'U must contain values strictly between 0 and 1.');
end

if ischar(family)
    families = {'gaussian','t','clayton','frank','gumbel'};

    i = strmatch(lower(family), families);
    if numel(i) > 1
        error('stats:copulafit:InvalidFamily', ...
              'Ambiguous copula family: ''%s''.',family);
    elseif numel(i) == 1
        family = families{i};
    else
        error('stats:copulafit:InvalidFamily', ...
              'Unrecognized copula family: ''%s''',family);
    end
else
    error('stats:copulafit:InvalidFamily', ...
          'FAMILY must be a copula family name.');
end

pnames = {'alpha' 'method', 'options'};
dflts =  {   .05      'ml'        [] };
[eid,errmsg,alpha,method,options] = internal.stats.getargs(pnames, dflts, varargin{:});
if ~isempty(eid)
    error(sprintf('stats:copulafit:%s',eid),errmsg);
end

if ~(isscalar(alpha) && (0 < alpha && alpha < 1))
    error('stats:copulafit:InvalidAlpha', ...
          'ALPHA must be a scalar between 0 and 1.');
end
zcrit = norminv([alpha/2 1-alpha/2]);

if ischar(method)
    methods = {'ml' 'approximateml'};

    i = strmatch(lower(method), methods);
    if numel(i) > 1
        error('stats:copulafit:InvalidMethod', ...
              'Ambiguous fitting method: ''%s''.',method);
    elseif numel(i) == 1
        method = methods{i};
    else
        error('stats:copulafit:InvalidMethod', ...
              'Unrecognized fitting method: ''%s''',method);
    end
    if ~strcmp(method,'ml') && ~strcmp(family,'t')
        error('stats:copulafit:MethodNotSupported', ...
              '''%s'' is only supported for t copulas.',method);
    end
else
    error('stats:copulafit:InvalidMethod', ...
          'METHOD must be ''ML'' or ''ApproximateML''.');
end

options = statset(statset('copulafit'), options);

switch family
case 'gaussian'
    if nargout > 1
        error('stats:copulafit:TooManyOutputs', 'Too many output arguments.');
    end
    
    % Transform to z scale, and compute Rho
    z = norminv(u);
    RhoHat = corrcoef(z);
    
    varargout{1} = RhoHat;
    
case 't'
    if nargout > 3
        error('stats:copulafit:TooManyOutputs', 'Too many output arguments.');
    end
    
    % These vars are used to save intermediate estimates of Rho or R =
    % chol(Rho) between iterations of the optimization for nu, since the final
    % estimate from the previous value of nu will make a good starting point
    % for the new value of nu.
    Rsaved = []; Rhosaved = [];

    % Use FMINBND to maximize the profile likelihood for nu.
    %
    % Could minimize the full likelihood directly, but that tends to be slow
    % because of all the calls to TINV.  Also, the optimizer can have trouble
    % because there's often a long flat valley, and in high dimensions that's hard
    % to deal with.  Better to maximize the likelihood with a two-step iteration.
    if strcmp(method,'ml')
        profileFun = @profileNLL_t;
    else %if strcmp(method,'approximateml')
        profileFun = @approxProfileNLL_t;
    end
    lowerBnd = 1 + options.TolBnd; % limit d.f. to be > 1
    [lowerBnd,upperBnd] = bracket1D(profileFun,lowerBnd,5); % 'upper', search ascending from 5
    if ~isfinite(upperBnd)
        error('stats:copulafit:NoUpperBnd', ...
              ['Unable to find an upper bound for the estimate of nu.  Consider\n', ...
               'using a Gaussian copula instead.']);
    end
    opts = optimset(options);
    [nuHat,nll,err,output] = fminbnd(profileFun, lowerBnd, upperBnd, opts);
    if (err == 0)
        % fminbnd may print its own output text; in any case give something
        % more statistical here, controllable via warning IDs.
        if output.funcCount >= options.MaxFunEvals
            wmsg = 'Maximum likelihood estimation did not converge.  Function evaluation limit exceeded.';
        else
            wmsg = 'Maximum likelihood estimation did not converge.  Iteration limit exceeded.';
        end
        warning('stats:copulafit:IterOrEvalLimit',wmsg);
    elseif (err < 0)
        error('stats:copulafit:NoSolution',...
              'Unable to reach a maximum likelihood solution.');
    end
    [nll,RhoHat] = profileFun(nuHat);
    RhoHat(1:(d+1):d*d) = 1; % guarantee ones along the diagonal
    
    if (nargout > 2) && (nuHat <= lowerBnd)
        warning('stats:copulafit:NuAtBoundary',...
                ['Estimate for nu is at or near lower bound of 1.  Confidence\n', ...
                 'limits are not valid.']);
    end
    
    varargout(1:2) = {RhoHat nuHat};
    
    if nargout > 2
        % This warns if the 2nd deriv is not positive.
        d2 = d2profileLL_t(nuHat,profileFun);
        se = sqrt(1/d2);
        varargout{3} = nuHat + se*zcrit;
    end
    
case {'clayton' 'frank' 'gumbel'}
    if nargout > 2
        error('stats:copulafit:TooManyOutputs', 'Too many output arguments.');
    elseif d > 2
        error('stats:copulafit:TooManyDimensions', ...
              'Number of dimensions must be two for an Archimedean copula.');
    end
    
    switch family
    case 'clayton' % a.k.a. Cook-Johnson
        nloglf = @negloglike_clayton;
        lowerBnd = options.TolBnd;
    case 'frank'
        nloglf = @negloglike_frank;
        [dum,lowerBnd] = bracket1D(nloglf,5,-5); % 'lower', search descending from -5
        if ~isfinite(lowerBnd)
            error('stats:copulafit:NoLowerBnd', ...
                  'Unable to find a lower bound for the estimate of the copula parameter.');
        end
    case 'gumbel' % a.k.a. Gumbel-Hougaard
        nloglf = @negloglike_gumbel;
        lowerBnd = 1 + options.TolBnd;
    end
    [lowerBnd,upperBnd] = bracket1D(nloglf,lowerBnd,5); % 'upper', search ascending from 5
    if ~isfinite(upperBnd)
        error('stats:copulafit:NoUpperBnd', ...
              'Unable to find an upper bound for the estimate of the copula parameter.');
    end
    opts = optimset(options);
    [alphaHat,nll,err,output] = fminbnd(nloglf, lowerBnd, upperBnd, opts);
    if (err == 0)
        % fminbnd may print its own output text; in any case give something
        % more statistical here, controllable via warning IDs.
        if output.funcCount >= options.MaxFunEvals
            wmsg = 'Maximum likelihood estimation did not converge.  Function evaluation limit exceeded.';
        else
            wmsg = 'Maximum likelihood estimation did not converge.  Iteration limit exceeded.';
        end
        warning('stats:copulafit:IterOrEvalLimit',wmsg);
    elseif (err < 0)
        error('stats:copulafit:NoSolution',...
              'Unable to reach a maximum likelihood solution.');
    end
    varargout{1} = alphaHat;
    
    if nargout > 1
        [nll,d2] = nloglf(alphaHat);
        se = sqrt(1/d2);
        varargout{2} = alphaHat + se*zcrit;
    end
end


%----------------------------------------------------------------------
%
% Log-likelihood and profile LL functions for the t copula (nested within main function)
%
    function [nll,Rho,R] = profileNLL_t(nu)
        % Compute profile negative log-likelihood for a t copula at nu, by
        % maximizing over R = chol(Rho)
        
        % Transform to t scale, and compute initial estimate for Rho and its
        % Cholesky factor
        t_ = tinvLocal(u,nu);
        if isempty(Rsaved)
            Rho = corrcoef(t_);
            [R,p_] = chol(Rho);
            if p_ > 0 || any(isnan(diag(R)))
                error('stats:copulafit:RhoRankDeficient', ...
                     ['The estimate of Rho has become rank-deficient.  You may have\n' ...
                      'too few data, or strong dependencies among variables.']);
            end
        else
            % Use the final estimate of R from the previous iteration as the
            % starting value for this iteration, if it's available (in the
            % parent's workspace).
            R = Rsaved;
        end
        
        % Compute Rho using conditional maximum likelihood, given nu
        funfcn = {'fungrad' 'copulafit' @(params) profileObjFun(params,nu,t_) [] []};
        start_ = tovector(R);
        
        % The tolerances need to be fairly tight here, particularly when computing
        % the second derivative, since otherwise the computed profile likelihood
        % can fail to be concave upward.
        dfltOptions = struct('DerivativeCheck','off', 'HessMult',[], ...
            'HessPattern',ones(length(start_)), 'PrecondBandWidth',Inf, ...
            'TypicalX',ones(length(start_),1), 'MaxPCGIter',1, 'TolPCG',0.1, ...
            'TolX',1e-8, 'TolFun',1e-8, 'MaxIter',1000, 'MaxFunEvals',5000, ...
            'Display','off');
        [params,nll,lagrange,err,output] = ...
                 statsfminbx(funfcn, start_, -Inf(size(start_)), Inf(size(start_)), [], dfltOptions, 1);
        if (err == 0)
            % statsfminbx is forced to be silent, but give a warning here,
            % controllable via warning IDs.
            if output.funcCount >= options.MaxFunEvals
                wmsg = 'Calculation of profile likelihood did not converge for nu = %g.  Function evaluation limit exceeded.';
            else
                wmsg = 'Calculation of profile likelihood did not converge for nu = %g.  Iteration limit exceeded.';
            end
            warning('stats:copulafit:IterOrEvalLimit',wmsg,nu);
        elseif (err < 0)
            error('stats:copulafit:NoSolution',...
                  'Unable to compute profile likelihood for nu = %g.',nu);
        end
        
        R = tomatrix(params);
        Rho = R'*R;
        
        % Save the final estimate of R in the parent's workspace for use as a
        % starting value in the next iteration.
        Rsaved = R;
    end

    function [nll,Rho] = approxProfileNLL_t(nu)
        % Bouye' et al's iterative solution for Rho, given nu.  This is
        % motivated as a profile likelihood, although it isn't, but leads
        % to estimates of Rho and nu that are typically good approximations
        % to the MLEs when the sample size is large enough.  However, even for
        % moderately large sample sizes, the criterion can have multiple minima.
        
        % Transform to t scale, and compute initial estimate for Rho
        [n_,d_] = size(u);
        t_ = tinvLocal(u,nu);
        if isempty(Rhosaved)
            Rho = corrcoef(t_);
        else
            % Use the final estimate of Rho from the previous iteration as the
            % starting value for this iteration, if it's available (in the
            % parent's workspace).
            Rho = Rhosaved;
        end

        % Compute Rho as a fixed point of Bouye's iteration, given nu
        tol = 1e-8;
        maxiter = 100;
        for jj = 1:maxiter
            RhoOld = Rho;
            [R,p_] = chol(Rho);
            if p_ > 0
                error('stats:copulafit:RhoRankDeficient', ...
                     ['The estimate of Rho has become rank-deficient.  You may have\n' ...
                      'too few data, or strong dependencies among variables.']);
            end
            tRinv = t_ / R;
            % s_ = t_ ./ sqrt(repmat(1 + sum(tRinv.^2,2)/nu, 1, d));
            s_ = bsxfun(@rdivide, t_, sqrt(1 + sum(tRinv.^2,2)/nu));
            Rho = ((nu+d)./nu).*(s_'*s_)/n_;
            
            % Renormalize at each iteration
            c_ = sqrt(diag(Rho)); % sqrt first to avoid under/overflow
            cc_ = c_*c_'; cc_(1:(d_+1):end) = diag(Rho); % remove roundoff on diag
            Rho = Rho ./ cc_;

            if norm(Rho-RhoOld) < tol*norm(Rho), break; end
        end
        if jj > maxiter
            warning('stats:copulafit:RhoEstimateFailedConvergence', ...
                    'Estimation for Rho failed to converge.');
        end

        % Compute negative log-likelihood at nu and conditional Rho estimate
        nll = negloglike_t(nu,chol(Rho),t_);
        
        % Save the final estimate of Rho in the parent's workspace for use as a
        % starting value in the next iteration.
        Rhosaved = Rho;
    end

%----------------------------------------------------------------------
%
% Log-likelihood functions for Archimedean copulas (nested within main function)
%
    function [nll,d2] = negloglike_clayton(alpha)
        % C(u1,u2) = (u1^(-alpha) + u2^(-alpha) - 1)^(-1/alpha)
        powu = u.^(-alpha);
        lnu = log(u);
        logC = (-1./alpha).*log(sum(powu, 2) - 1);
        logy = log(alpha+1) + (2.*alpha+1).*logC - (alpha+1).*sum(lnu, 2);
        nll = -sum(logy);
        if nargout > 1
            % Return approximate 2nd derivative of the neg loglikelihood,
            % using -E[score^2] = E[hessian]
            dlogy = 1./(1+alpha) - logC./alpha ...
                + (2+1./alpha)*sum(powu.*lnu, 2)./(sum(powu, 2) - 1) - sum(lnu, 2);
            d2 = sum(dlogy.^2);
        end
    end

    function [nll,d2,dlogy] = negloglike_frank(alpha)
        % C(u1,u2) = -(1/alpha)*log(1 + (exp(-alpha*u1)-1)*(exp(-alpha*u1)-1)/(exp(-alpha)-1))
        expau = exp(alpha .* u);
        sumu = sum(u, 2);
        if abs(alpha) < 1e-5
            logy = 2*alpha*prod(u-.5,2); % -> zero as alpha -> 0
        else
            logy = log(-alpha.*expm1(-alpha)) + alpha.*sumu ...
                - 2*log(abs(1 + exp(alpha.*(sumu - 1)) - sum(expau, 2)));
        end
        nll = -sum(logy);
        if nargout > 1
            % Return approximate 2nd derivative of the neg loglikelihood,
            % using -E[score^2] = E[hessian]
            if abs(alpha) < 1e-5
                dlogy = 2*prod(u-.5,2);
            else
                dlogy = 1./alpha + 1./expm1(alpha) + sumu ...
                    - 2*((sumu-1).*exp(alpha.*(sumu-1)) - sum(u.*expau, 2)) ...
                    ./ (1 + exp(alpha.*(sumu-1)) - sum(expau, 2));
            end
            d2 = sum(dlogy.^2);
        end
    end

    function [nll,d2] = negloglike_gumbel(alpha)
        % C(u1,u2) = exp(-((-log(u1))^alpha + (-log(u2))^alpha)^(1/alpha))
        v = -log(u); % u is strictly in (0,1) => v strictly in (0,Inf)
        v = sort(v,2); vmin = v(:,1); vmax = v(:,2); % min/max, but avoid dropping NaNs
        logv = log(v);
        nlogC = vmax.*(1+(vmin./vmax).^alpha).^(1./alpha);
        lognlogC = log(nlogC);
        logy = log(alpha - 1 + nlogC) ...
            - nlogC + sum((alpha-1).*logv + v, 2) + (1-2*alpha).*lognlogC;
        nll = -sum(logy);
        if nargout > 1
            % Return approximate 2nd derivative of the neg loglikelihood,
            % using -E[score^2] = E[hessian]
            dnlogC = nlogC .* (-lognlogC + sum(logv.*v.^alpha, 2)./sum(v.^alpha, 2)) ./ alpha;
            dlogy = (1+dnlogC)./(alpha-1+nlogC) - dnlogC ...
                + sum(logv, 2) + (1-2*alpha)*dnlogC./nlogC - 2*lognlogC;
            d2 = sum(dlogy.^2);
        end
    end
end

%----------------------------------------------------------------------
%
% Log-likelihood and profile LL functions for the t copula (not nested)
%
function [obj,grad] = profileObjFun(params,nu,t)
    R = tomatrix(params);
    obj = negloglike_t(nu, R, t);
    delta = eps(class(params))^(1/4);

    % Compute a two-point central difference approximation to the gradient.
    if nargout == 2
        % This assumes that the finite diff steps will remain within the
        % parameter space.  The parameterization should ensure that.
        deltaparams = delta*max(abs(params), 1); % limit smallest absolute step
        e = zeros(size(params));
        grad = zeros(size(params));
        for j = 1:length(params)
            e(j) = deltaparams(j);
            Rplus = tomatrix(params+e); Rminus = tomatrix(params-e);
            grad(j) = negloglike_t(nu, Rplus, t) - negloglike_t(nu, Rminus, t);
            e(j) = 0;
        end

        % Normalize by increment to get derivative estimates.
        grad = grad ./ (2 * deltaparams);
    end
end

function d2 = d2profileLL_t(nu,profileNLL)
    % Return a numerical approximation to the 2nd derivative of the neg
    % profile loglikelihood for nu.  Note that this is the profile LL,
    % maximizing over Rho(nu), and not a slice of the full LL along nu.

    % Compute a five-point central difference approximation to
    % the second derivative.  Assumes nu is > 2*delta.
    delta = eps(class(nu))^(1/4);
    fm2 = profileNLL(nu+2*delta);
    fm1 = profileNLL(nu+delta);
    fm  = profileNLL(nu);
    fp1 = profileNLL(nu-delta);
    fp2 = profileNLL(nu-2*delta);
    if all(diff(diff([fm2 fm1 fm fp1 fp2])) > 0)
        d2 = (-fm2 + 16*fm1 - 30*fm + 16*fp1 - fp2) / (12 * delta.^2);
    else
        warning('stats:copulafit:ProfileLLNotConcave', ...
                ['Unable to compute a confidence interval.  The profile\n' ...
                 'log-likelihood does not have negative curvature at nu = %g.'],nu);
        d2 = NaN(class(nu));
    end
end

function nll = negloglike_t(nu, R, t)
    % Compute negative log-likelihood for a t copula at nu and R = chol(Rho)
    [n,d] = size(t);
    % R = R ./ repmat(sqrt(sum(R.^2,1)),d,1);
    R = bsxfun(@rdivide, R, sqrt(sum(R.^2,1)));

    % nll = -sum(log(mvtpdf(t,R'*R,nu)) - sum(log(tpdf(t,nu)),2)),
    % where t = tinvLocal(u,nu)
    tRinv = t / R;
    nll = - n*gammaln((nu+d)/2) + n*d*gammaln((nu+1)/2) - n*(d-1)*gammaln(nu/2) ...
          + n*sum(log(abs(diag(R)))) ...
          + ((nu+d)/2)*sum(log(1+sum(tRinv.^2, 2)./nu)) ...
          - ((nu+1)/2)*sum(sum(log(1+t.^2./nu),2),1);
end

%----------------------------------------------------------------------
%
% Utility functions
%

function x = tinvLocal(p,nu)

% For small d.f., call betaincinv which uses Newton's method
if nu < 1000
    q = p - .5;
    z = zeros(size(q),class(q));
    oneminusz = zeros(size(q),class(q));
    t = (abs(q(:)) < .25);
    if any(t)
        % for z close to 1, compute 1-z directly to avoid roundoff
        oneminusz(t) = betaincinv(2.*abs(q(t)),0.5,nu/2,'lower');
        z(t) = 1 - oneminusz(t);
    end
    t = ~t; % (abs(q) >= .25);
    if any(t)
        z(t) = betaincinv(2.*abs(q(t)),nu/2,0.5,'upper');
        oneminusz(t) = 1 - z(t);
    end
    x = sign(q) .* sqrt(nu .* (oneminusz./z));
    
% For large d.f., use Abramowitz & Stegun formula 26.7.5
else
    xn = norminv(p);
    x = xn + (xn.^3+xn)./(4*nu) + ...
        (5*xn.^5+16.*xn.^3+3*xn)./(96*nu.^2) + ...
        (3*xn.^7+19*xn.^5+17*xn.^3-15*xn)./(384*nu.^3) +...
        (79*xn.^9+776*xn.^7+1482*xn.^5-1920*xn.^3-945*xn)./(92160*nu.^4);
end
end

function [nearBnd,farBnd] = bracket1D(nllFun,nearBnd,farStart)
% Bracket the minimizer of a (one-param) negative log-likelihood function.
% nearBnd is a point known to be a lower/upper bound for the minimizer,
% this will be updated to tighten the bound if possible.  farStart is the
% first trial point to test to see if it's an upper/lower bound for the
% minimizer.  farBnd will be the desired upper/lower bound.
bound = farStart;
upperLim = 1e12; % arbitrary finite limit for search
oldnll = nllFun(bound);
oldbound = bound;
while abs(bound) <= upperLim
    bound = 2*bound; % assumes lower start is < 0, upper is > 0
    nll = nllFun(bound);
    if nll > oldnll
        % The neg loglikelihood increased, we're on the far side of the
        % minimum, so the current point is the desired far bound.
        farBnd = bound;
        break;
    else
        % The neg loglikelihood continued to decrease, so the previous point
        % is on the near side of the minimum, update the near bound.
        nearBnd = oldbound;
    end
    oldnll = nll;
    oldbound = bound;
end
if abs(bound) > upperLim
    farBnd = NaN;
end
end


function b = tovector(A)
% Convert the Cholesky factor of a correlation matrix to upper triangle vector
% form.  Columns of the Cholesky factor have unit norm, so they reduce to
% direction angles, consisting of one fewer element.
m = size(A,1);
Angles = zeros(m);
for i = 1:m-1
    Angles(i,:) = atan2(A(i,:),A(i+1,:));
    A(i+1,:) = A(i+1,:) ./ cos(Angles(i,:));
end
b = Angles(triu(true(m),1));
end


function A = tomatrix(b)
% Convert the Cholesky factor of a correlation matrix from upper triangle vector
% form.  Columns of the Cholesky factor have unit norm, so the columns can be
% recreated from direction angles.
m = (1 + sqrt(1+8*length(b)))/2;
Cosines = zeros(m);
Cosines(triu(true(m),1)) = cos(b);
Sines = ones(m);
Sines(triu(true(m),1)) = sin(b);
flip = m:-1:1;
prodSines = cumprod(Sines(flip,:)); prodSines = prodSines(flip,:);
A = [ones(1,m); Cosines(1:m-1,:)] .* prodSines;
% A = [ones(1,m); Cosines(1:m-1,:)] .* flipud(cumprod(flipud(Sines)));
end
