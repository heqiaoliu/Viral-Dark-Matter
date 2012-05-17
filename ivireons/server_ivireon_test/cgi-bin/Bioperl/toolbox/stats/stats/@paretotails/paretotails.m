classdef paretotails < piecewisedistribution
%PARETOTAILS Empirical cdf with generalized Pareto tails.
%   OBJ = PARETOTAILS(X, PL, PU) creates an object defining a distribution
%   consisting of the empirical distribution of X in the center, and Pareto
%   distributions in the tails.  X is a real-valued vector of data values
%   whose extreme observations are fit to generalized Pareto distributions
%   (GPD).  PL and PU identify the lower and upper tail cumulative
%   probabilities such that 100*PL and 100*(1 - PU) percent of the
%   observations in X are, respectively, fit to a GPD by maximum
%   likelihood.  If PL=0 or if there are not at least two distinct
%   observations in the lower tail, then no lower Pareto tail is fit.  If
%   PU=1 or if there are not at least two distinct observations in the
%   upper tail, then no upper Pareto tail is fit. 
%
%   OBJ = PARETOTAILS(X, PL, PU, CDFFUN) uses the function CDFFUN to
%   estimate the CDF of X between the lower and upper tail probabilities.
%   CDFFUN may be any of the following:
%       'ecdf'    (default) to use an interpolated empirical cdf, defined
%                 at the data values as the midpoints in the vertical steps
%                 in the ecdf, and computed by linear interpolation between
%                 data values
%       'kernel'  to use a kernel smoothing estimate of the cdf and interpolate
%                 between a discrete set of these estimated values
%       @FUN      handle to a function of the form [P,XI]=FUN(X) that
%                 accepts the input data vector and returns a vector P of
%                 cdf values and a vector XI of evaluation points.  The XI
%                 must be sorted and distinct but need not equal the values
%                 in X
%   The CDFFUN is used to compute the quantiles corresponding to PL and PU
%   by inverse interpolation, and to define the fitted distribution between
%   these quantiles.
%
%   The output object OBJ is a PARETOTAILS object with methods to evaluate
%   the cdf, inverse cdf, and other functions of the fitted distribution.
%   These methods are well-suited to copula and other Monte Carlo simulations.
%   The pdf method in the tails is the GPD density, but in the center it is
%   computed as the slope of the interpolated cdf.
%
%   The PARETOTAILS class is a subclass of the PIECEWISEDISTRIBUTION class,
%   and many of its methods are derived from that class.
%
%   Example: Compare a t distribution to a fit based on Pareto tails
%      t = trnd(3,100,1);
%      o = paretotails(t,.1,.9);
%      x = linspace(-5,5);
%      plot(x,o.cdf(x),'b-',x,tcdf(x,3),'r:')
%
%   See also ECDF, KSDENSITY, GPFIT, PARETOTAILS/CDF, PARETOTAILS/ICDF, PARETOTAILS/RANDOM.

%   Copyright 2006-2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:20:55 $

    properties(GetAccess='private', SetAccess='private')
        lowerparams = [];  % parameters of lower-tail Pareto, or [] if none
        upperparams = [];  % parameters of upper-tail Pareto, or [] if none
        pLower = [];       % lower tail probability, 0<=pLower<1
        pUpper = [];       % upper tail probability, 0<pUpper<=1
        qLower = [];       % quantile at lower tail boundary
        qUpper = [];       % quantile at upper tail boundary
        X = [];            % x values for cdf interpolation in center
        F = [];            % F(x) values for cdf interpolation in center
        descr = '';        % description to display for center
    end

    methods
    function b = paretotails(x,pLower,pUpper,cdfFunc)
    
        % Check for required args
        error(nargchk(3,4,nargin,'struct'));
        if nargin<4
            cdfFunc = 'ecdf';
        end
        checkargs(x,pLower,pUpper);
        [cdfFunc,descr] = checkcdf(cdfFunc);

        % Get boundaries, central CDF values, and tail parameters
        [lo,up,X,F,pLower,pUpper,qLower,qUpper] = init(x,pLower,pUpper,cdfFunc);
        % Make superior class
        b = b@piecewisedistribution;

        % Assign to object properties
        b.lowerparams = lo;
        b.upperparams = up;
        b.pLower = pLower;
        b.pUpper = pUpper;
        b.qLower = qLower;
        b.qUpper = qUpper;
        b.X = X;
        b.F = F;
        b.descr = descr;
        
        % The set methods will cause the piecewisedistribution properties,
        % including function handles, to be assigned
        end % constructor

    % The following set methods assign to the piecewisedistribution when
    % all of the paretotails properties are assigned
    function obj = set.lowerparams(obj,val)
        obj.lowerparams = val;
        obj = checkcomplete(obj);
        end
    function obj = set.upperparams(obj,val)
        obj.upperparams = val;
        obj = checkcomplete(obj);
        end
    function obj = set.pLower(obj,val)
        obj.pLower = val;
        obj = checkcomplete(obj);
        end
    function obj = set.pUpper(obj,val)
        obj.pUpper = val;
        obj = checkcomplete(obj);
        end
    function obj = set.X(obj,val)
        obj.X = val;
        obj = checkcomplete(obj);
        end
    function obj = set.F(obj,val)
        obj.F = val;
        obj = checkcomplete(obj);
        end
    function obj = set.qLower(obj,val)
        obj.qLower = val;
        obj = checkcomplete(obj);
        end
    function obj = set.qUpper(obj,val)
        obj.qUpper = val;
        obj = checkcomplete(obj);
        end
    function obj = set.descr(obj,val)
        obj.descr = val;
        obj = checkcomplete(obj);
        end
    end % methods block

    methods (Access='private')
    function obj=checkcomplete(obj)
        % If object definition is complete, create handles for parent object
        if ~isempty(obj.F) && ~isempty(obj.X) && ...
                ~isempty(obj.pLower) && ~isempty(obj.pUpper) && ...
                ~isempty(obj.qLower) && ~isempty(obj.qUpper) && ...
                (obj.pLower==0 || ~isempty(obj.lowerparams)) && ...
                (obj.pUpper==1 || ~isempty(obj.upperparams)) && ...
                ~isempty(obj.descr)
            [P,Q,S] = makehandles(obj);
            obj = setpieces(obj,P,Q,S);
        end
    end
    end % private methods
    
    methods(Hidden = true)        
        function a = properties(obj)
            a = [properties@piecewisedistribution(obj); 'lowerparams'; 'upperparams'];
        end
    end

end

function [loParam,upParam,X,F,pLower,pUpper,QL,QU] = init(x, pLower, pUpper, cdfFunc)

x = sort(x(:));

% Estimate the empirical CDF function of the input data. This CDF
% estimation function may, for example, smooth the CDF curve, or simply
% return the classical "staircase" sample CDF. All that is required is that
% it return a vector of values of the empirical CDF evaluated at X, F(X).
%
% Notice that this step first estimates the CDF using ALL the observations 
% of the input data set. Upon subsequent evaluation of the output CDF
% function, it will only be used to smooth the interior of the distribution
% between the lower & upper tails. In other words, the tails of the CDF
% estimated in this step are likely discarded, allowing the Pareto tails
% (if any) to take precedence.
try
  [F,X] = cdfFunc(x);
catch ME
    throw(addCause(MException('stats:paretotails:InvalidCDFFUN', ...
                              'Error calling CDFFUN function ''%s''.',...
                              func2str(cdfFunc)),...
                   ME));
end

X = X(:);              % Guarantee column vectors.
F = F(:);

diffx = diff(X);
if any(diffx<=0)
    if diffx(1)==0 && all(diffx(2:end)>0)
        % Result matches that of ecdf.  Allow this as a special case.
        X(1) = X(1) - eps(X(1));
    else
        error('stats:paretotails:InvalidCDFFUN', ...
              'CDFFUN must return sorted distinct XI values.');
    end
end
if any(diff(F)<0)
    error('stats:paretotails:InvalidCDFFUN', ...
          'CDFFUN must return F values that are non-decreasing with X.')
end

% Fit a generalized Pareto distribution (GPD) to the tails of the CDF.
loParam = [];
upParam = [];
ws(1) = warning('off','stats:gpfit:ConvergedToBoundary');
ws(2) = warning('off','stats:gpfit:IterOrEvalLimit');

try
    if pLower > 0                  % Lower tail estimation via maximum likelihood.
        QL = localinterp1(F,X,pLower);   % Lower tail threshold.
        y  = QL - x(x < QL);        % Exceedances below lower threshold (all positive).

        if length(y)>=2 && max(y)>min(y)
            [oldwmsg,oldwid] = lastwarn;
            lastwarn('');
            parameters = gpfit(y);
            [wmsg,wid] = lastwarn;
            if isequal(wid,'stats:gpfit:ConvergedToBoundary')
                warning('stats:paretotails:ConvergedToBoundary','%s\n%s',...
                      'Problem fitting generalized Pareto distribution to lower tail.',...
                      'Maximum likelihood has converged to a boundary point of the parameter space.');
            elseif isequal(wid,'stats:gpfit:IterOrEvalLimit')
                warning('stats:paretotails:NoConvergence','%s\n%s',...
                      'Problem fitting generalized Pareto distribution to lower tail.',...
                      'Maximum likelihood estimation did not converge.');
            else
                lastwarn(oldwmsg,oldwid);
            end
            loParam = parameters;
        else
            pLower = 0;
            QL = X(1);
            warning('stats:paretotails:NoTailData',...
                    'Omitting lower tail because of insufficient or constant data.');
        end

        % Make sure the lower end is exactly at QL
        j = find(X>QL,1,'first');
        X = [QL; X(j:end)];
        F = [pLower; F(j:end)];
    else
        QL = X(1);
        F(1) = 0;
    end
    
    if pUpper < 1                  % Upper tail estimation via maximum likelihood.
        QU = localinterp1(F,X,pUpper);   % Upper tail threshold.
        y  = x(x > QU) - QU;        % Exceedances above upper threshold.

        if length(y)>=2 && max(y)>min(y)
            [oldwmsg,oldwid] = lastwarn;
            lastwarn('');
            parameters = gpfit(y);
            [wmsg,wid] = lastwarn;
            if isequal(wid,'stats:gpfit:ConvergedToBoundary')
                warning('stats:paretotails:ConvergedToBoundary','%s\n%s',...
                      'Problem fitting generalized Pareto distribution to upper tail.',...
                      'Maximum likelihood has converged to a boundary point of the parameter space.');
            elseif isequal(wid,'stats:gpfit:IterOrEvalLimit')
                warning('stats:paretotails:ConvergedToBoundary','%s\n%s',...
                      'Problem fitting generalized Pareto distribution to upper tail.',...
                      'Maximum likelihood estimation did not converge.');
            else
                lastwarn(oldwmsg,oldwid);
            end
            upParam = parameters;
        else
            warning('stats:paretotails:NoTailData',...
                    'Omitting upper tail because of insufficient or constant data.');
            pUpper = 1;
            QU = X(end);
        end
        
        % Make sure the upper end is exactly at QU
        j = find(X<QU,1,'last');
        X = [X(1:j); QU];
        F = [F(1:j); pUpper];
    else
        QU = X(end);
        F(end) = 1;
    end
catch ME
    warning(ws);
    rethrow(ME);
end
warning(ws);

% Avoid flat spots when we interpolate
% First remove interior points in an interval of constant F
t = (diff(F)==0);
t(2:end) = t(1:end-1)&t(2:end);
t = 1+find(t);
F(t)=[];
X(t)=[];

% Now nudge the remaining two F values apart
t = (diff(F)==0);
F(t) = F(t)-eps(F(t));
end

% ---------------------------------
function [cdfFunc,descr] = checkcdf(cdfFunc)
%CHECKCDF - get cdf function handle and description
if isempty(cdfFunc) || strcmpi(cdfFunc,'ecdf')
   cdfFunc = @smoothECDF;
   descr = 'interpolated empirical cdf';
elseif strcmpi(cdfFunc,'kernel')
   cdfFunc = @(x) ksdensity(x,'function','cdf');
   descr = 'interpolated kernel smooth cdf';
elseif isa(cdfFunc, 'function_handle')
   descr = sprintf('function: %s',func2str(cdfFunc));
else
   error('stats:paretotails:NonFunctionHandle', ...
         'CDFFUN must be ''ecdf'', ''kernel'', or a function handle.');
end
end

% ---------------------------------
function checkargs(x, pLower, pUpper)
%CHECKARGS - check required args
if ~isa(x, 'double') || ~isreal(x) || ~isvector(x)
   error('stats:paretotails:VectorRequired', ...
         'Input data X must be a real-valued vector.');
end

if ~isscalar(pLower) || (pLower < 0) || (pLower > 1)
   error('stats:paretotails:InvalidPL', ...
         'PL tail probability must be a scalar on [0,1].');
end

if ~isscalar(pUpper) || (pUpper < 0) || (pUpper > 1)
   error('stats:paretotails:InvalidPU', ...
         'PU tail probability must be a scalar on [0,1].');
end

if pLower > pUpper
   error('stats:paretotails:InconsistentProbabilities', ...
         'Tail probabilities must be such that 0 <= PL <= PU <= 1.');
end
end

% ---------------------------------------------------------
function [P,Q,S] = makehandles(obj)
%MAKEHANDLES - make function handles to compute distribution functions

% Get boundary points and tail parameters
isLowerTailEmpty = (obj.pLower==0);
isUpperTailEmpty = (obj.pUpper==1);
P = [obj.pLower(~isLowerTailEmpty); obj.pUpper(~isUpperTailEmpty)];
Q = [obj.qLower(~isLowerTailEmpty); obj.qUpper(~isUpperTailEmpty)];
P = P(:);
Q = Q(:);
X = obj.X;
F = obj.F;

j = 0;
if isempty(obj.lowerparams)
    QL = -Inf;
    PL = 0;
else
    QL = Q(1);
    PL = P(1);
    lowerK  = obj.lowerparams(1);
    lowerSigma = obj.lowerparams(2);
end
if isempty(obj.upperparams)
    QU = Inf;
    PU = 1;
else
    QU = Q(end);
    PU = P(end);
    upperK  = obj.upperparams(1);
    upperSigma = obj.upperparams(2);
end

% Define lower tail using Pareto distribution
if ~isempty(obj.lowerparams)
    j = j+1;
    S(j).cdf  = @(x) PL * (1 - gpcdf(max(0,QL-x), lowerK, lowerSigma));
    S(j).icdf = @(p) QL - gpinv(1-p/PL, lowerK, lowerSigma);
    S(j).pdf = @(x) PL * gppdf(QL-x, lowerK, lowerSigma);
    S(j).random = @(sz) QL - gprnd(lowerK,lowerSigma,0,sz);
    S(j).description = sprintf('lower tail, GPD(%g,%g)',...
                               lowerK,lowerSigma);
end

% Define middle portion using empirical cdf
j = j+1;
S(j).cdf = @(x) interp1(X, F, max(QL,min(QU,x)));
S(j).icdf = @(p) interp1(F, X, p, 'linear', NaN);
S(j).pdf = @(x) smoothPDF(x, X, F);
S(j).random = [];   % use default random number generator via icdf
S(j).description = obj.descr;

% Define upper tail using Pareto distribution
if ~isempty(obj.upperparams)
    j = j+1;
    S(j).cdf  = @(x) PU + (1-PU) * gpcdf(max(0,x-QU), upperK, upperSigma);
    S(j).icdf = @(p) QU + gpinv((p-PU)/(1-PU), upperK, upperSigma);
    S(j).pdf = @(x) (1-PU) * gppdf(x-QU, upperK, upperSigma);
    S(j).random = @(sz) QU + gprnd(upperK,upperSigma,0,sz);
    S(j).description = sprintf('upper tail, GPD(%g,%g)',...
                               upperK,upperSigma);
end
end

% -------------------------------
   function [F,X] = smoothECDF(x)
   %SMOOTHCDF Smooth the empirical CDF by linear interpolation.
   % [F,XI] = SMOOTHCDF(X) calculates tha smoothed ECDF from the vector X.

   % At sorted value x(i), the CDF jumps from (i-1)/n to i/n.  Define the
   % smoothed value here as (i-.5)/n, and interpolate between data values.
   [F, X]   = ecdf(x);                % Empirical CDF
   F(2:end) = F(2:end) - diff(F)/2;   % Take the midpoint at each jump

   % To ensure that the smoothed CDF covers the closed interval [0,1], the 
   % first and last elements of the output quantile vector XI are linearly 
   % extrapolated using the adjacent slope of the piecewise linear CDF.
   n = length(X);
   X(1)   = X(2) -   F(2)    *(X(3) - X(2))  /(F(3) - F(2));
   X(n+1) = X(n) + (1 - F(n))*(X(n) - X(n-1))/(F(n) - F(n-1));
   F(n+1) = 1;
   end
   
% -------------------------------
   function f = smoothPDF(x,X,F)
   %SMOOTHPDF Compute the pdf as the derivative of the interpolated cdf.
   
   [counts,bin] = histc(x,X);
   bin(x==X(1)) = 1;
   bin(x==X(end)) = length(counts)-1;
   f = NaN(size(x));
   t = (bin>0);
   bin = bin(t);
   f(t) = (F(bin+1) - F(bin)) ./ (X(bin+1) - X(bin));
   end

% ---------------------------
function yi = localinterp1(x,y,xi)
% local interp1 allows repeats in x but expects a scalar xi and sorted x

% Force xi to be in range
xi = min(x(end),max(x(1),xi));

% If xi is in the array, find the mean of the corresponding y values
t = (x==xi);
if any(t)
    yi = mean(y(t));
    return
end

% Find j and k so that x(j)<xi<x(k)
j = find(x<xi,1,'last');
k = j + 1;

% Interpolate between these two x values
yi = y(j) + (y(k)-y(j)) * (xi-x(j)) ./ (x(k)-x(j));
end
