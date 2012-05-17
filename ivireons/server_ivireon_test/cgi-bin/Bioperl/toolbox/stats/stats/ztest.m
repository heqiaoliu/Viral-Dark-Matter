function [h,p,ci,zval] = ztest(x,m,sigma,alpha,tail,dim)
%ZTEST  One-sample Z-test.
%   H = ZTEST(X,M,SIGMA) performs a Z-test of the hypothesis that the data
%   in the vector X come from a distribution with mean M, and returns the
%   result of the test in H.  H=0 indicates that the null hypothesis
%   ("mean is M") cannot be rejected at the 5% significance level.  H=1
%   indicates that the null hypothesis can be rejected at the 5% level.  The
%   data are assumed to come from a normal distribution with standard
%   deviation SIGMA.
%
%   X may also be a matrix or an N-D array.  For matrices, ZTEST performs
%   separate Z-tests along each column of X, and returns a vector of
%   results.  For N-D arrays, ZTEST works along the first non-singleton
%   dimension of X.  M and SIGMA must be scalars.
%
%   ZTEST treats NaNs as missing values, and ignores them.
%
%   H = ZTEST(X,M,SIGMA,ALPHA) performs the test at the significance level
%   (100*ALPHA)%.  ALPHA must be a scalar.
%
%   H = ZTEST(X,M,SIGMA,ALPHA,TAIL) performs the test against the alternative
%   hypothesis specified by TAIL:
%       'both'  -- "mean is not M" (two-tailed test)
%       'right' -- "mean is greater than M" (right-tailed test)
%       'left'  -- "mean is less than M" (left-tailed test)
%   TAIL must be a single string.
%
%   [H,P] = ZTEST(...) returns the p-value, i.e., the probability of
%   observing the given result, or one more extreme, by chance if the null
%   hypothesis is true.  Small values of P cast doubt on the validity of
%   the null hypothesis.
%
%   [H,P,CI] = ZTEST(...) returns a 100*(1-ALPHA)% confidence interval for
%   the true mean.
%
%   [H,P,CI,ZVAL] = ZTEST(...) returns the value of the test statistic.
%
%   [...] = ZTEST(X,M,SIGMA,ALPHA,TAIL,DIM) works along dimension DIM of X.
%   Pass in [] to use default values for ALPHA or TAIL.
%
%   See also TTEST, SIGNTEST, SIGNRANK, VARTEST.

%   References:
%      [1] E. Kreyszig, "Introductory Mathematical Statistics",
%      John Wiley, 1970, page 206.

%   Copyright 1993-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:18:34 $

if nargin < 3
    error('stats:ztest:TooFewInputs',...
          'Requires at least three input arguments.');
elseif ~isscalar(m)
    error('stats:ztest:NonScalarM','M must be a scalar.');
elseif ~isscalar(sigma) || (sigma < 0)
    error('stats:ztest:NonScalarSigma','SIGMA must be a positive scalar.');
end

if nargin < 4 || isempty(alpha)
    alpha = 0.05;
elseif ~isscalar(alpha) || alpha <= 0 || alpha >= 1
    error('stats:ztest:BadAlpha','ALPHA must be a scalar between 0 and 1.');
end

if nargin < 5 || isempty(tail)
    tail = 0;
elseif ischar(tail) && (size(tail,1)==1)
    tail = find(strncmpi(tail,{'left','both','right'},length(tail))) - 2;
end
if ~isscalar(tail) || ~isnumeric(tail)
    error('stats:ztest:BadTail', ...
          'TAIL must be one of the strings ''both'', ''right'', or ''left''.');
end

if nargin < 6 || isempty(dim)
    % Figure out which dimension mean will work along
    dim = find(size(x) ~= 1, 1);
    if isempty(dim), dim = 1; end
end

nans = isnan(x);
if any(nans(:))
    samplesize = sum(~nans,dim);
else
    samplesize = size(x,dim); % make this a scalar if possible
end
xmean = nanmean(x,dim);
ser = sigma ./ sqrt(samplesize);
zval = (xmean - m) ./ ser;

% Compute the correct p-value for the test, and confidence intervals
% if requested.
if tail == 0 % two-tailed test
    p = 2 * normcdf(-abs(zval),0,1);
    if nargout > 2
        crit = norminv(1 - alpha/2, 0, 1) .* ser;
        ci = cat(dim, xmean-crit, xmean+crit);
    end
elseif tail == 1 % right one-tailed test
    p = normcdf(-zval,0,1);
    if nargout > 2
        crit = norminv(1 - alpha, 0, 1) .* ser;
        ci = cat(dim, xmean-crit, Inf(size(p)));
    end
elseif tail == -1 % left one-tailed test
    p = normcdf(zval,0,1);
    if nargout > 2
        crit = norminv(1 - alpha, 0, 1) .* ser;
        ci = cat(dim, -Inf(size(p)), xmean+crit);
    end
else
    error('stats:ztest:BadTail',...
          'TAIL must be ''both'', ''right'', or ''left'', or 0, 1, or -1.');
end

% Determine if the actual significance exceeds the desired significance
h = cast(p <= alpha, class(p));
h(isnan(p)) = NaN; % p==NaN => neither <= alpha nor > alpha
