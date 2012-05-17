function [y, delta] = polyconf(p,x,S,varargin)
%POLYCONF Polynomial evaluation and confidence interval estimation.
%   Y = POLYCONF(P,X) returns the value of a polynomial P evaluated at X. P
%   is a vector of length N+1 whose elements are the coefficients of the
%   polynomial in descending powers.
%
%       Y = P(1)*X^N + P(2)*X^(N-1) + ... + P(N)*X + P(N+1)
%
%   If X is a matrix or vector, the polynomial is evaluated at all points
%   in X.  See also POLYVALM for evaluation in a matrix sense.
%
%   [Y,DELTA] = POLYCONF(P,X,S) uses the optional output, S, created by
%   POLYFIT to generate 95% prediction intervals.  If the coefficients in P
%   are least squares estimates computed by POLYFIT, and the errors in the
%   data input to POLYFIT were independent, normal, with constant variance,
%   then there is a 95% probability that Y +/- DELTA will contain a future
%   observation at X.
%
%   [Y,DELTA] = POLYCONF(P,X,S,'NAME1',VALUE1,'NAME2',VALUE2,...) specifies
%   optional argument name/value pairs chosen from the following list.
%   Argument names are case insensitive and partial matches are allowed.
%
%      Name       Value
%     'alpha'     A value between 0 and 1 specifying a confidence level of
%                 100*(1-alpha)%.  Default is alpha=0.05 for 95% confidence.
%     'mu'        A two-element vector containing centering and scaling
%                 parameters as computed by polyfit.  With this option,
%                 polyconf uses (X-MU(1))/MU(2) in place of x.
%     'predopt'   Either 'observation' (the default) to compute intervals for
%                 predicting a new observation at X, or 'curve' to compute
%                 confidence intervals for the polynomial evaluated at X.
%     'simopt'    Either 'off' (the default) for non-simultaneous bounds,
%                 or 'on' for simultaneous bounds.
%
%   See also POLYFIT, POLYTOOL, POLYVAL, INVPRED, POLYVALM.

%   For backward compatibility we also accept the following:
%   [...] = POLYCONF(p,x,s,ALPHA)
%   [...] = POLYCONF(p,x,s,alpha,MU)

%   Copyright 1993-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:16:53 $

error(nargchk(2,Inf,nargin,'struct'));

alpha = [];
mu = [];
doobs = true;   % predict observation rather than curve estimate
dosim = false;  % give non-simultaneous intervals
if nargin>3
    if ischar(varargin{1})
        % Syntax with parameter name/value pairs
        okargs =   {'alpha' 'mu' 'predopt' 'simopt'};
        defaults = {0.05    []   'obs'     'off'};
        [eid emsg alpha mu predopt simopt] = ...
                internal.stats.getargs(okargs,defaults,varargin{:});
        if ~isempty(eid)
            error(sprintf('stats:polyconf:%s',eid),emsg);
        end
        
        i = find(strncmpi(predopt,{'curve';'observation'},length(predopt)));
        if ~isscalar(i)
            error('stats:polyconf:BadPredOpt', ...
           'PREDOPT must be one of the strings ''curve'' or ''observation''.');
        end
        doobs = (i==2);
        
        i = find(strncmpi(simopt,{'on';'off'},length(simopt)));
        if ~isscalar(i)
            error('stats:polyconf:BadSimOpt', ...
           'SIMOPT must be one of the strings ''on'' or ''off''.');
        end
        dosim = (i==1);
    else
        % Old syntax
        alpha = varargin{1};
        if numel(varargin)>=2
            mu = varargin{2};
        end
    end
end
if nargout > 1
    if nargin < 3, S = []; end % this is an error; let polyval handle it
    if nargin < 4 || isempty(alpha)
        alpha = 0.05;
    elseif ~isscalar(alpha) || ~isnumeric(alpha) || ~isreal(alpha) ...
                            || alpha<=0          || alpha>=1
        error('stats:polyconf:BadAlpha',...
              'ALPHA must be a scalar between 0 and 1.');
    end
    if isempty(mu)
        [y,delta] = polyval(p,x,S);
    else
        [y,delta] = polyval(p,x,S,mu);
    end
    if doobs
        predvar = delta;                % variance for predicting observation
    else
        s = S.normr / sqrt(S.df);
        delta = delta/s;
        predvar = s*sqrt(delta.^2 - 1); % get uncertainty in curve estimation
    end
    if dosim
        k = length(p);
        crit = sqrt(k * finv(1-alpha,k,S.df)); % Scheffe simultaneous value
    else
        crit = tinv(1-alpha/2,S.df);           % non-simultaneous value
    end
    delta = crit * predvar;
else
    if isempty(mu)
        y = polyval(p,x);
    else
        y = polyval(p,x,[],mu);
    end
end
