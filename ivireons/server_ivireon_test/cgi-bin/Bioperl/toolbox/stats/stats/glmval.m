function [yhat,dylo,dyhi] = glmval(beta,x,link,varargin)
%GLMVAL Predict values for a generalized linear model.
%   YHAT = GLMVAL(B,X,LINK) computes predicted values for the generalized
%   linear model with link function LINK and predictor values X.  GLMVAL
%   automatically includes a constant term in the model (do not enter a column
%   of ones directly into X).  B is a vector of coefficient estimates as
%   returned by the GLMFIT function.  LINK can be any of the link function
%   specifications acceptable to the GLMFIT function.
%
%   [YHAT,DYLO,DYHI] = GLMVAL(B,X,LINK,STATS) also computes 95% confidence
%   bounds on the predicted Y values.  STATS is the stats structure
%   returned by GLMFIT.  DYLO and DYHI define a lower confidence bound of
%   YHAT-DYLO and an upper confidence bound of YHAT+DYHI.  Confidence bounds
%   are non-simultaneous and they apply to the fitted curve, not to a new
%   observation.
%
%   [...] = GLMVAL(...,'PARAM1',val1,'PARAM2',val2,...) allows you to
%   specify optional parameter name/value pairs to control the predicted
%   values.  Parameters are:
%
%      'confidence' - the confidence level for the confidence bounds.
%
%      'size' - the size parameter (N) for a binomial model.  This may be a
%         scalar, or a vector with one value for each row of X.
%
%      'offset' - a vector to use as an additional predictor variable, but
%         with a coefficient value fixed at 1.0.
%
%      'constant' - specify as 'on' (the default) if the model fit included
%         a constant term, or 'off' if not.  The coefficient of the
%         constant term should be in the first element of B.
%
%   Example:  Display the fitted probabilities from a probit regression
%   model for y on x.  Each y(i) is the number of successes in n(i) trials.
%
%       x = [2100 2300 2500 2700 2900 3100 3300 3500 3700 3900 4100 4300]';
%       n = [48 42 31 34 31 21 23 23 21 16 17 21]';
%       y = [1 2 0 3 8 8 14 17 19 15 17 21]';
%       b = glmfit(x, [y n], 'binomial', 'link', 'probit');
%       yfit = glmval(b, x, 'probit', 'size', n);
%       plot(x, y./n, 'o', x, yfit./n, '-')
%
%   See also GLMFIT.

%   References:
%      [1] Dobson, A.J. (2001) An Introduction to Generalized Linear
%          Models, 2nd edition, Chapman&Hall/CRC Press.
%      [2] McCullagh, P., and J.A. Nelder (1990) Generalized Linear
%          Models, 2nd edition, Chapman&Hall/CRC Press.
%      [3] Collett, D. (2002) Modelling Binary Data, 2nd edition,
%          Chapman&Hall/CRC Press.

%   Copyright 1993-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:14:20 $

if nargin < 3
   error('stats:glmval:TooFewInputs','At least three arguments are required.');
end

% Get STATS if it's there.
optnargin = nargin - 3;
if optnargin > 0 && ~ischar(varargin{1}) % not a parameter name, assume it's STATS
    stats = varargin{1};
    varargin(1) = [];
    optnargin = optnargin - 1;
else
    stats = [];
end

% Process optional name/value pairs.
if optnargin > 0 && ischar(varargin{1}) % assume it's a parameter name, not CONFLEV
    paramNames = {'confidence' 'size' 'offset' 'constant'};
    paramDflts = {        .95      1        0        'on'};
    [errid,errmsg,clev,N,offset,const] = ...
                           internal.stats.getargs(paramNames, paramDflts, varargin{:});
    if ~isempty(errid)
        error(sprintf('stats:glmfit:%s',errid),errmsg);
    end

else % the old syntax glmval(beta,x,link,stats,clev,N,offset,const)
    clev = .95;
    N = 1;
    offset = 0;
    const = 'on';
    if optnargin > 0 && ~isempty(varargin{1}), clev = varargin{1}; end
    if optnargin > 1 && ~isempty(varargin{2}), N = varargin{2}; end
    if optnargin > 2 && ~isempty(varargin{3}), offset = varargin{3}; end
    if optnargin > 3 && ~isempty(varargin{4}), const = varargin{4}; end
end
isconst = isequal(const,'on');

% Instantiate functions for one of the canned links, or validate a
% user-defined link specification.
[emsg,linkFun,dlinkFun,ilinkFun] = stattestlink(link,class(x));
if ~isempty(emsg)
    error('stats:glmfit:BadLink',emsg);
end

% Should X be changed to a column vector?
if isvector(x) && size(x,1) == 1
   if (length(beta)==2 && isconst) || (isscalar(beta) && ~isconst)
      x = x(:);
      if isvector(N), N = N(:); end
      if isvector(offset), offset = offset(:); end
   end
end

% Add constant column to X matrix, compute linear combination, and
% use the inverse link function to get a predicted value
if isconst, x = [ones(size(x,1),1) x]; end
eta = x*beta + offset;
yhat = N .* ilinkFun(eta);

% Return bounds if requested
if nargout > 1
    if isempty(stats)
        error('stats:glmval:TooFewInputs', ...
              'The STATS parameter is required to compute confidence bounds.');
    end
    if ~isnan(stats.s) % dfe > 0 or estdisp == 'off'
        se = stats.se(:);
        cc = stats.coeffcorr;
        V = (se * se') .* cc;
        R = cholcov(V);
        vxb = sum((R * x').^2,1);
        if stats.estdisp
            crit = tinv((1+clev)/2, stats.dfe);
        else
            crit = norminv((1+clev)/2);
        end
        dxb = crit * sqrt(vxb(:));
        dyhilo = [N.*ilinkFun(eta-dxb) N.*ilinkFun(eta+dxb)];
        dylo = yhat - min(dyhilo,[],2);
        dyhi = max(dyhilo,[],2) - yhat;
    else
        dylo = NaN(size(yhat),class(yhat));
        dyhi = NaN(size(yhat),class(yhat));
    end
end
