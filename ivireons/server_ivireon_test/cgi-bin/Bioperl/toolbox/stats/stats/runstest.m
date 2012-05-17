function [H,P,stats] = runstest(x,v,varargin)
%RUNSTEST  Runs test for randomness.
%   H = RUNSTEST(X) performs a runs test on the sequence of observations in
%   the vector X.  This is a test of the hypothesis that the values in X
%   come in a random order, against the alternative that the ordering is
%   not random.  The test is based on the number of runs of consecutive
%   values above or below the mean of X.  Too few runs is an indication of
%   a tendency of high values to cluster together, and low values to
%   cluster together.  Too many runs is an indication of a tendency for high
%   values and low values to alternate.  The result is H=0 if the null
%   hypothesis ("sequence is random") cannot be rejected at the 5%
%   significance level, or H=1 if the null hypothesis can be rejected at
%   the 5% level.
% 
%   H = RUNSTEST(X,V) performs the test using runs above or below the
%   value V.
%
%   H = RUNSTEST(X,'UD') performs a test for the number of runs up or
%   down.  This also tests the hypothesis that the values in X come in a
%   random order.  Too few runs is an indication of a trend.  Too many
%   runs indicates a tendency to oscillate.
%
%   RUNSTEST treats NaNs as missing values, and ignores them.  For the
%   test of runs above or below V, values exactly equal to V are also
%   discarded.  For the test of runs up and down, values exactly equal
%   to the preceding value are discarded.
%
%   H = RUNSTEST(...,'PARAM1',VAL1,'PARAM2',VAL2,...) specifies additional
%   parameters and their values.  Valid parameters are the following:
%      'alpha'    Performs the test at the significance level ALPHA.
%                 ALPHA must be a scalar.
%      'method'   Either 'exact' to compute the p-value using an exact
%                 algorithm, or 'approximate' to use a normal approximation.
%                 Default is 'exact' for runs above/below, and for runs
%                 up/down when the length of X is 50 or less.  The 'exact'
%                 method is not available for runs up/down when the length
%                 of X is 51 or greater.
%      'tail'     Performs the test against the alternative hypothesis
%                 specified by TAIL:
%       'both'      two-tailed test:  "sequence is not random"
%       'right'     right-tailed test:
%                      "like values tend to separate" (runs above/below)
%                      "direction tends to alternate" (runs up/down)
%       'left'      left-tailed test:
%                      "like values tend to cluster"  (runs above/below)
%                      "values tend to have a trend"  (runs up/down)
%
%   [H,P] = RUNSTEST(...) returns the p-value, i.e., the probability of
%   observing the given result, or one more extreme, by chance if the null
%   hypothesis is true.  Small values of P cast doubt on the validity of
%   the null hypothesis.
%
%   [H,P,STATS] = RUNSTEST(...) returns a structure with the following fields:
%      'nruns' -- the number of runs
%      'n1'    -- number of values above V (or up)
%      'n0'    -- number of values below V (or down)
%      'z'     -- normal test statistic
%   The test statistic Z is approximately normally distributed when the
%   null hypothesis is true.  It is the difference between the number of
%   runs and its mean, divided by its standard deviation.  The output P
%   value is computed either from Z or from the exact distribution of
%   NRUNS, depending on the 'method' parameter.
% 
%   Example:
%      x = randn(40,1);
%      [h,p] = runstest(x,median(x))
% 
%   See also SIGNRANK, SIGNTEST.

%   Older syntax still supported:
%      [...] = RUNSTEST(X,V,ALPHA,TAIL)

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:17:24 $

% Get required data input vector and remove NaNs
error(nargchk(1,Inf,nargin,'struct'));
if ~isvector(x) && ~isempty(x)
    error('stats:runstest:VectorRequired','Input sample X must be a vector.');
end
x(isnan(x)) = [];

% Figure out whether to do runs above/below or up/down
if nargin==1 || isempty(v)
    updown = false;
    if isempty(x)
        v = NaN;
    else
        v = mean(x);
    end
elseif isnumeric(v) && isscalar(v)
    updown = false;
elseif isequal(lower(v),'ud')
    updown = true;
else
    error('stats:runstest:BadV','V must be either ''UD'' or a number');
end

% Process remaining arguments
alpha = 0.05;
tail = 0;    % code for two-sided
method = '';
if nargin>=3
    if isnumeric(varargin{1})
        % Old syntax
        alpha = varargin{1};
        if nargin>=4
            tail = varargin{2};
        end
    else
        % Calling sequence with named arguments
        okargs =   {'alpha' 'tail' 'method'};
        defaults = {0.05    'both' ''};
        [eid emsg alpha tail method] = ...
                         internal.stats.getargs(okargs,defaults,varargin{:});
        if ~isempty(eid)
           error(sprintf('stats:runstest:%s',eid),emsg);
        end
    end
end

% Argument error checking
if isempty(alpha)
    alpha = 0.05;
elseif ~isscalar(alpha) || alpha <= 0 || alpha >= 1
    error('stats:runstest:BadAlpha','ALPHA must be a scalar between 0 and 1.');
end
if isempty(tail)
    tail = 0;   % both
elseif ischar(tail) && (size(tail,1)==1)
    tail = find(strncmpi(tail,{'left','both','right'},length(tail))) - 2;
end
if ~isscalar(tail) || ~isnumeric(tail) || ~ismember(tail,-1:1)
    error('stats:runstest:BadTail', ...
          'TAIL must be ''both'', ''right'', or ''left''.');
end
if ~isempty(method) && isempty(strmatch(lower(method),{'exact','approximate'}))
    error('stats:runstest:BadMethod',...
          'METHOD must be ''exact'' or ''approximate''.');    
end

% Convert to a binary sequence
N = numel(x);
if updown
   x = diff(x);
   if any(x==0)
       x(x==0) = [];
       N = numel(x) + 1;
       warning('stats:runstest:ValuesOmitted',...
               'X values exactly equal to the preceding values are omitted.');
   end
   x = double(x>0);
else
   if any(x==v)
       x(x==v) = [];
       N = numel(x);
       warning('stats:runstest:ValuesOmitted',...
               'X values exactly equal to V are omitted.');
   end
   x = double(x(:) > v);
end

% Compute number of runs, count of ones, etc.
n1 = sum(x==1);
n0 = numel(x)-n1;

% Make sure we can do the requested calculation
method = lower(method);
if isempty(method)
    doexact = (~updown) || N<=50;
elseif method(1)=='e' && updown && N>50
    warning('stats:runstest:NoExactMethod',...
        ['The ''exact'' method is not available for runs up/down with a\n'...
         'sample size greater than 50.  Using ''approximate'' instead.']);
    doexact = false;
else
    doexact = method(1)=='e';
end

if N>0
    nruns = 1 + sum(x(1:end-1) ~= x(2:end));

    % Normal statistic for asymptotic test
    if N==1
        z = NaN;
    else
        if updown
            meanR = (2*N-1)/3;
            stdR = sqrt((16*N-29)/90);
        else
            meanR = 1 + 2*n1*n0/N;
            stdR = sqrt(2*n1*n0*(2*n1*n0-N) / (N^2 * (N-1)));
        end
        if tail==0
            contcorr = -0.5 * sign(nruns-meanR);  % continuity correction
        elseif tail<0
            contcorr = 0.5;
        else
            contcorr = -0.5;
        end
        if stdR>0
            z = (nruns + contcorr - meanR) / stdR;
        else
            z = Inf * sign(nruns + contcorr - meanR);
        end
    end

    if doexact
        % Get probability for each feasible value
        if updown
            maxruns = N-1;
        else
            maxruns = 2*min(n1,n0)+1;
        end
        rlist = 1:maxruns;
        plist = statrunstestprob(N,n1,n0,rlist,updown);
    
        if isempty(plist)
            pexact = 1;
        else
            pexact = plist(nruns);
        end
        plo = sum(plist(1:nruns-1));
        phi = sum(plist(nruns+1:end));
    else
        % Compute probabilities using Z statistic
        pexact = 0;
        plo = normcdf(z);
        phi = normcdf(-z);
    end
else
    nruns = NaN;
    pexact = 1;
    plo = 0;
    phi = 0;
    z = NaN;
end


% Compute desired tail probability
if tail == 0     % two-tailed test
    P = min(1, 2*(pexact + min(plo,phi)));
elseif tail == 1 % right one-tailed test
    P = pexact + phi;
else % tail == -1, left one-tailed test
    P = pexact + plo;
end

% Set values of remaining output arguments
H = cast(P<=alpha, class(P));

if nargout>=3
    stats = struct('nruns',nruns, 'n1',n1, 'n0',n0, 'z',z);
end
