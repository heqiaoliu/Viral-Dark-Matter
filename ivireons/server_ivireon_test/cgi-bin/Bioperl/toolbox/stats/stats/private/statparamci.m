function ci=statparamci(param,Sigma,alpha,logflag)
%STATPARAMCI Utility to compute parameter confidence intervals
%   CI=STATPARAMCI(PARAM,SIGMA,ALPHA,N,LOGFLAG) compute confidence
%   intervals for parameters with estimated values PARAM and covariance
%   SIGMA.  The confidence level is 100*(1-ALPHA)%.  The sample size is N.
%   The confidence intervals are based on a normal approximation for the
%   distribution of the parameter estimates.  LOGFLAG indicates which
%   parameters should be approximated with a normal distribution on the log
%   scale.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:30:20 $

np = numel(param);
if nargin<4
    logflag = false(1,np);
end

if isempty(Sigma)
    ci = [];
    return;
end

% Get standard errors from SIGMA
se = sqrt(diag(Sigma))';

% Log transform
se(logflag) = se(logflag) ./ param(logflag);
param(logflag) = log(param(logflag));

% Get normal quantiles
z = -norminv(alpha/2);

% Interval = estimate +/- quantile * standard_error
ci = [param;param] + [se;se] .* repmat([-z;z],1,np);

% Inverse log transform
ci(:,logflag) = exp(ci(:,logflag));
