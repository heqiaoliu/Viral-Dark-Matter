function [fout0,xout,u,ksinfo] = ksdensity(yData,varargin)
%KSDENSITY Compute kernel density or distribution estimate
%   [F,XI]=KSDENSITY(X) computes a probability density estimate of the sample
%   in the vector X.  KSDENSITY evaluates the density estimate at 100 points
%   covering the range of the data.  F is the vector of density values and XI
%   is the set of 100 points.  The estimate is based on a normal kernel
%   function, using a window parameter (bandwidth) that is a function of the
%   number of points in X.
%
%   F=KSDENSITY(X,XI) specifies the vector XI of values where the density
%   estimate is to be evaluated.
%
%   [F,XI,U]=KSDENSITY(...) also returns the bandwidth of the kernel smoothing
%   window.
%
%   KSDENSITY(...) without output arguments produces a plot of the results.
%
%   KSDENSITY(AX,...) plots into axes AX instead of GCA.
%
%   [...]=KSDENSITY(...,'PARAM1',val1,'PARAM2',val2,...) specifies parameter
%   name/value pairs to control the density estimation.  Valid parameters
%   are the following:
%
%      Parameter    Value
%      'censoring'  A logical vector of the same length of X, indicating which
%                   entries are censoring times (default is no censoring).
%      'kernel'     The type of kernel smoother to use, chosen from among
%                   'normal' (default), 'box', 'triangle', and
%                   'epanechnikov'.
%      'npoints'    The number of equally-spaced points in XI.
%      'support'    Either 'unbounded' (default) if the density can extend
%                   over the whole real line, or 'positive' to restrict it to
%                   positive values, or a two-element vector giving finite
%                   lower and upper limits for the support of the density.
%      'weights'    Vector of the same length as X, giving the weight to
%                   assign to each X value (default is equal weights).
%      'width'      The bandwidth of the kernel smoothing window.  The default
%                   is optimal for estimating normal densities, but you
%                   may want to choose a smaller value to reveal features
%                   such as multiple modes.
%      'function'   The function type to estimate, chosen from among 'pdf',
%                   'cdf', 'icdf', 'survivor', or 'cumhazard' for the density,
%                   cumulative probability, inverse cumulative probability,
%                   survivor, or cumulative hazard functions, respectively.
%                   For 'icdf', F=KSDENSITY(X,YI,...,'function','icdf')
%                   computes the estimated inverse CDF of the values in X, and
%                   evaluates it at the probability values specified in YI.
%
%   In place of the kernel functions listed above, you can specify another
%   kernel function by using @ (such as @normpdf) or quotes (such as 'normpdf').
%   KSDENSITY calls the function with a single argument that is an array
%   containing distances between data values in X and locations in XI where
%   the density is evaluated.  The function must return an array of the same
%   size containing corresponding values of the kernel function. When the
%   'function' parameter value is 'pdf', this kernel function should return
%   density values, otherwise it should return cumulative probability values.
%   Specifying a custom kernel when the 'function' parameter value is 'icdf'
%   is an error.
%
%   If the 'support' parameter is 'positive', KSDENSITY transforms X using
%   a log function, estimates the density of the transformed values, and
%   transforms back to the original scale.  If 'support' is a vector [L U],
%   KSDENSITY uses the transformation log((X-L)/(U-X)).  The 'width' parameter
%   and U outputs are on the scale of the transformed values.
%
%   Example: generate a mixture of two normal distributions, and
%   plot the estimated density.
%      x = [randn(30,1); 5+randn(30,1)];
%      [f,xi] = ksdensity(x);
%      plot(xi,f);
%
%   Example: generate a mixture of two normal distributions, and plot the
%   estimated cumulative distribution at a specified set of values.
%      x = [randn(30,1); 5+randn(30,1)];
%      xi = linspace(-10,15,201);
%      f = ksdensity(x,xi,'function','cdf');
%      plot(xi,f);
%
%   Example: generate a mixture of two normal distributions, and plot the
%   estimated inverse cumulative distribution function at a specified set of
%   values.
%      x = [randn(30,1); 5+randn(30,1)];
%      yi = linspace(.01,.99,99);
%      g = ksdensity(x,yi,'function','icdf');
%      plot(yi,g);
%
%   See also HIST, @.

%   Undocumented KSINFO output is used for the ProbDistUnivKernel class and
%   is subject to change in a future release.

% If there is any censoring, we would like to estimate the density up
% to the last non-censored observation.  Say this is XMAX.  Without
% censoring, the density estimate near XMAX would consist of contributions
% from kernels centered above and below XMAX.  We can't compute the
% contributions above XMAX, though, because we have no data.  Using only
% the kernels centered below XMAX makes the density estimate biased.
%
% In an attempt to reduce bias, we will compute the contributions
% from kernels centered below XMAX, and fold their values around XMAX.
% The result should be good if the density is nearly flat in this area.
% If the density is increasing then the estimate will still be biased
% downward, and if the density is decreasing it will still be biased
% upward, but the bias will be reduced.

% Reference:
%   A.W. Bowman and A. Azzalini (1997), "Applied Smoothing
%      Techniques for Data Analysis," Oxford University Press.

%   Copyright 1993-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:15:03 $


[axarg,yData,n,ymin,ymax,xispecified,xi,u,m,kernelname,...
    support,weight,cens,cutoff,ftype] = parse_args(yData,varargin{:});
weight = standardize_weight(weight,n);
cens = standardize_cens(cens,n);

[L,U] = compute_finite_support(support,ymin,ymax);
ty = apply_support(yData,L,U);

[ty,ymax,weight,u,foldpoint,maxp] = ...
    apply_censoring_get_bandwidth(cens,yData,ty,n,ymax,weight,u);

[fout,xout,u] = statkscompute(ftype,xi,xispecified,m,u,L,U,weight,cutoff,...
                              kernelname,ty,yData,foldpoint,maxp);

% Plot the results if they are not requested as return values
if nargout==0
    plot(axarg{:},xout,fout)
else
    fout0 = fout;
end

if nargout>=4
    ksinfo.ty = ty;
    ksinfo.weight = weight;
    ksinfo.foldpoint = foldpoint;
    ksinfo.L = L;
    ksinfo.U = U;
    ksinfo.maxp = maxp;
end

% -----------------------------
function [axarg,yData,n,ymin,ymax,xispecified,xi,u,m,kernelname,...
    support,weight,cens,cutoff,ftype] = parse_args(yData,varargin)
if (nargin > 0) && isscalar(yData) && ishghandle(yData) ...
        && isequal(get(yData,'type'),'axes')
    axarg = {yData};
    if nargin>1
        yData = varargin{1};
        varargin(1) = [];
    else
        yData = [];  % error to be dealt with below
    end
else
    axarg = {};
end

% Get y vector and its dimensions
if ~isvector(yData) || isempty(yData)
    error('stats:ksdensity:VectorRequired','X must be a non-empty vector.');
end
yData = yData(:);
yData(isnan(yData)) = [];
n = length(yData);
ymin = min(yData);
ymax = max(yData);

% Maybe xi was specified, or maybe not
xi = [];
xispecified = false;
if ~isempty(varargin)
    if ~ischar(varargin{1})
        xi = varargin{1};
        varargin(1) = [];
        xispecified = true;
    end
end

% Process additional name/value pair arguments
okargs =   {'width'     'npoints'   'kernel'   'support' ...
            'weights'   'censoring' 'cutoff'   'function'   };
defaults = {[]          100         'normal'   'unbounded' ...
            1/n         false(n,1)  []         'pdf'};
[eid,emsg,u,m,kernelname,support,weight,cens,cutoff,ftype] = ...
    internal.stats.getargs(okargs, defaults, varargin{:});
if ~isempty(eid)
    error(sprintf('stats:ksdensity:%s',eid),emsg);
end


% -----------------------------
function [L,U] = compute_finite_support(support,ymin,ymax)
if isnumeric(support)
    if numel(support)~=2
        error('stats:ksdensity:BadSupport',...
            'Value of ''support'' parameter must have two elements.');
    end
    if support(1)>=ymin || support(2)<=ymax
        error('stats:ksdensity:BadSupport',...
            'Data values must be between lower and upper ''support'' values.');
    end
    L = support(1);
    U = support(2);
elseif ischar(support) && ~isempty(support)
    okvals = {'unbounded' 'positive'};
    rownum = strmatch(support,okvals);
    if isempty(rownum)
        error('stats:ksdensity:BadSupport',...
            'Invalid value of ''support'' parameter.')
    end
    support = okvals{rownum};
    if isequal(support,'unbounded')
        L = -Inf;
        U = Inf;
    else
        L = 0;
        U = Inf;
    end
    if isequal(support,'positive') && ymin<=0
        error('stats:ksdensity:BadSupport',...
            'Cannot set support to ''positive'' with non-positive data.')
    end
else
    error('stats:ksdensity:BadSupport',...
        'Invalid value of ''support'' parameter.')
end

% -----------------------------
function weight = standardize_weight(weight,n)
if isempty(weight)
    weight = ones(1,n);
elseif numel(weight)==1
    weight = repmat(weight,1,n);
elseif numel(weight)~=n || numel(weight)>length(weight)
    error('stats:ksdensity:InputSizeMismatch',...
        'Value of ''weight'' must be a vector of the same length as X.');
else
    weight = weight(:)';
end
weight = weight / sum(weight);

% -----------------------------
function cens = standardize_cens(cens,n)
if isempty(cens)
    cens = false(1,n);
elseif ~all(ismember(cens(:),0:1))
    error('stats:ksdensity:BadCensoring',...
        'Value of ''censoring'' must be a logical vector.');
elseif numel(cens)~=n || numel(cens)>length(cens)
    error('stats:ksdensity:InputSizeMismatch',...
        'Value of ''censoring'' must be a vector of the same length as X.');
elseif all(cens)
    error('stats:ksdensity:CompleteCensoring',...
        'Cannot compute kernel smooth with all observations censored.');
end
cens = cens(:);

% -----------------------------
function ty = apply_support(yData,L,U)
% Compute transformed values of data
if L==-Inf && U==Inf    % unbounded support
    ty = yData;
elseif L==0 && U==Inf   % positive support
    ty = log(yData);
else                    % finite support [L, U]
    ty = log(yData-L) - log(U-yData);    % same as log((y-L)./(U-y))
end

% -----------------------------
function [ty,ymax,weight,u,foldpoint,maxp] = ...
    apply_censoring_get_bandwidth(cens,yData,ty,n,ymax,weight,u)
% Deal with censoring
iscensored = any(cens);
if iscensored
    % Compute empirical cdf and create an equivalent weighted sample
    [F,XF] = ecdf(ty, 'censoring',cens, 'frequency',weight);
    weight = diff(F(:))';
    ty = XF(2:end);
    N = sum(~cens);
    ymax = max(yData(~cens));
    foldpoint = min(yData(cens & yData>=ymax)); % for bias adjustment
    issubdist = ~isempty(foldpoint);  % sub-distribution, integral < 1
    maxp = F(end);
else
    N = n;
    issubdist = false;
    maxp = 1;
end
if ~issubdist
    foldpoint = Inf; % no bias adjustment is needed
end

% Get bandwidth if not already specified
if (isempty(u)),
    if ~iscensored
        % Get a robust estimate of sigma
        med = median(ty);
        sig = median(abs(ty-med)) / 0.6745;
    else
        % Estimate sigma using quantiles from the empirical cdf
        Xquant = interp1(F,XF,[.25 .5 .75]);
        if ~any(isnan(Xquant))
            % Use interquartile range to estimate sigma
            sig = (Xquant(3) - Xquant(1)) / (2*0.6745);
        elseif ~isnan(Xquant(2))
            % Use lower half only, if upper half is not available
            sig = (Xquant(2) - Xquant(1)) / 0.6745;
        else
            % Can't easily estimate sigma, just get some indication of spread
            sig = ty(end) - ty(1);
        end
    end
    if sig<=0, sig = max(ty)-min(ty); end
    if sig>0
        % Default window parameter is optimal for normal distribution
        u = sig * (4/(3*N))^(1/5);
    else
        u = 1;
    end
end

