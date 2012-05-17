function [phat, pci] = betafit(x,alpha)
%BETAFIT Parameter estimates and confidence intervals for beta distributed data.
%   BETAFIT(X) Returns the maximum likelihood estimates of the parameters
%   of the beta distribution given the data in the vector, X.  
%
%   [PHAT, PCI] = BETAFIT(X,ALPHA) gives MLEs and 100(1-ALPHA) percent
%   confidence intervals given the data. By default, the optional parameter
%   ALPHA = 0.05 corresponding to 95% confidence intervals.
%
%   The beta distribution is defined on the open interval (0,1).  However, it
%   is sometimes also necessary to fit a beta distribution to data that
%   include exact zeros or ones.  For such data, the beta likelihood function
%   is unbounded, and standard maximum likelihood estimation is not possible.
%   In that case, BETAFIT maximizes a modified likelihood that incorporates
%   the zeros or ones by treating them as if they were values that have been
%   left-censored at SQRT(REALMIN) or right-censored at 1-EPS/2, respectively.
%
%   See also BETACDF, BETAINV, BETALIKE, BETAPDF, BETARND, BETASTAT, MLE. 

%   Reference:
%      (1994) Hahn, Gerald J., and Shapiro, Samuel, S. "Statistical Models in
%      Engineering", Wiley Classics Library, John Wiley & Sons, p. 95.

%   Copyright 1993-2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:12:15 $

if nargin < 2 
    alpha = 0.05;
end

if isempty(x)
    phat = nan(1,2,class(x));
    pci = nan(2,2,class(x));
    return
elseif ~isvector(x)
    error('stats:betafit:VectorRequired','The first input must be a vector.');
end

% Remove missing values from the data.
x = x(~isnan(x));

% Cannot fit data outside of the closed interval [0,1], or constant data.
xmin = min(x); xmax = max(x);
if ((xmin < 0) || (xmax > 1))
    error('stats:betafit:BadData',...
          'All values must be within the closed interval [0,1].');
elseif abs(xmin - xmax) <= 2*eps(xmax)
    error('stats:betafit:BadData',...
          'Cannot fit a beta distribution if all data values are the same.');
end

% Initial parameter estimates.
n = length(x);
tmp1 = prod((1-x) .^ (1/n));
tmp2 = prod(x .^ (1/n));
tmp3 = (1 - tmp1 - tmp2);
ahat = 0.5*(1-tmp1) / tmp3;
bhat = 0.5*(1-tmp2) / tmp3;
pstart = [ahat bhat];

% If all values are strictly within the interval (0,1), use
% maximum likelihood with the usual continuous log-likelihood.
xl = sqrt(realmin(class(x))); % some tolerance above zero
xu = 1 - eps(class(x))/2;
if (xl <= xmin) && (xmax <= xu)
    sumlogx = sum(log(x));
    sumlog1mx = sum(log1p(-x));
    negloglike = @negloglike_cts;
    
% If some values are zero or one, maximize a mixed likelihood that
% includes discrete probabilities for those values.  Note that the asymmetry
% in xl and xu (relative to 0 and 1, respectively) means that when the data
% vector x contains exact zeros or ones, the parameter estimates for x and
% (1-x) are typically not just flipped.  But that's true even without exact
% ones and zeros, because of floating point's differing precision at 0 and 1.
else
    x0 = (x < xl);
    n0 = sum(x0);
    x1 = (x > xu);
    n1 = sum(x1);
    x2 = x(~x0 & ~x1);
    n2 = length(x2);
    sumlogx2 = sum(log(x2));
    sumlog1mx2 = sum(log1p(-x2));
    negloglike = @negloglike_mixed;
end

% Maximize the likelihood using a log transform for the parameters, to ensure
% the parameters are positive.
pstart = log(pstart);
opts = optimset('Display','off','TolX',1e-6,'TolFun',1e-6);
phat = fminsearch(negloglike,pstart,opts);
phat = exp(phat);

if nargout == 2
    % Compute CIs on the log scale for both params
    [logL, acov] = betalike(phat,x);
    logphat = log(phat);
    selog = sqrt(diag(acov))' ./ phat;
    p_int = [alpha/2; 1-alpha/2];
    pci = exp(norminv([p_int p_int], [logphat; logphat], [selog; selog]));
end

    % Negative log-likelihood for data with no zeros or ones.
    function nll = negloglike_cts(p)
        p = exp(p); % remove log transform
        nll = n*betaln(p(1),p(2)) - (p(1)-1)*sumlogx - (p(2)-1)*sumlog1mx;
    end

   % Negative log-likelihood for data with zeros or ones.
    function nll = negloglike_mixed(p)
        p = exp(p); % remove log transform
        nll = n2*betaln(p(1),p(2)) - (p(1)-1)*sumlogx2 - (p(2)-1)*sumlog1mx2;
        
        % Include F(xl) = Pr(X <= xl) for data that are zeros.
        if n0 > 0
            nll = nll - n0*log(betainc(xl,p(1),p(2),'lower'));
        end
        
        % Include 1-F(xu) = Pr(X >= xu) for data that are ones.
        if n1 > 0
            nll = nll - n1*log(betainc(xu,p(1),p(2),'upper'));
        end
    end

end