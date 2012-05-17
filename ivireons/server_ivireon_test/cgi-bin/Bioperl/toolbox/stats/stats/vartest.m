function [h,p,ci,stats] = vartest(x,v,alpha,tail,dim)
%VARTEST  One-sample test of variance.
%  H = VARTEST(X,V) performs a chi-square test of the hypothesis that the
%  data in the vector X come from a normal distribution with variance V,
%  against the alternative that X comes from a normal distribution with a
%  different variance.  The result is H=0 if the null hypothesis ("variance
%  is V") cannot be rejected at the 5% significance level, or H=1 if the
%  null hypothesis can be rejected at the 5% level.
%
%  X may also be a matrix or an N-D array.  For matrices, VARTEST performs
%  separate tests along each column of X, and returns a vector of
%  results.  For N-D arrays, VARTEST works along the first non-singleton
%  dimension of X.  V must be a scalar.
%
%  VARTEST treats NaNs as missing values, and ignores them.
%
%  H = VARTEST(X,V,ALPHA) performs the test at the significance level
%  (100*ALPHA)%.  ALPHA must be a scalar.  Default value is 0.05.
%
%  H = VARTEST(X,V,ALPHA,TAIL) performs the test against the alternative
%  hypothesis specified by TAIL:
%      'both'  -- "variance is not V" (two-tailed test, default)
%      'right' -- "variance is greater than V" (right-tailed test)
%      'left'  -- "variance is less than V" (left-tailed test)
%  TAIL must be a single string.
%
%  [H,P] = VARTEST(...) returns the p-value, i.e., the probability of
%  observing the given result, or one more extreme, by chance if the null
%  hypothesis is true.  Small values of P cast doubt on the validity of
%  the null hypothesis.
%
%  [H,P,CI] = VARTEST(...) returns a 100*(1-ALPHA)% confidence interval for
%  the true variance.
%
%  [H,P,CI,STATS] = VARTEST(...) returns a structure with the following
%  fields:
%     'chisqstat' -- the value of the test statistic
%     'df'        -- the degrees of freedom of the test
%
%  [...] = VARTEST(X,V,ALPHA,TAIL,DIM) works along dimension DIM of X.
%  Pass in [] for ALPHA or TAIL to use their default values.
%
%  Example:  Is the standard deviation significantly different from 7?
%      load carsmall
%      [h,p,ci] = vartest(MPG, 7^2)
%
%  See also TTEST, ZTEST, VARTEST2.

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:18:10 $

if nargin < 2
    error('stats:vartest:TooFewInputs',...
              'Requires at least two input arguments.');
end

if ~isscalar(v) || ~isnumeric(v) || ~isreal(v) || v<0
    error('stats:vartest:BadVar','V must be a scalar variance value.');
end
if nargin < 3 || isempty(alpha)
    alpha = 0.05;
elseif ~isscalar(alpha) || alpha <= 0 || alpha >= 1
    error('stats:vartest:BadAlpha','ALPHA must be a scalar between 0 and 1.');
end

if nargin < 4 || isempty(tail)
    tail = 0;
elseif ischar(tail) && (size(tail,1)==1)
    tail = find(strncmpi(tail,{'left','both','right'},length(tail))) - 2;
end
if ~isscalar(tail) || ~isnumeric(tail)
    error('stats:vartest:BadTail', ...
          'TAIL must be one of the strings ''both'', ''right'', or ''left''.');
end

if nargin < 5 || isempty(dim)
    % Figure out which dimension mean will work along
    dim = find(size(x) ~= 1, 1);
    if isempty(dim), dim = 1; end
end
if ~isscalar(dim) || ~ismember(dim,1:ndims(x))
    error('stats:vartest:BadDim', ...
      'DIM must be an integer between 1 and %d.',ndims(x));
end        

nans = isnan(x);
dims = ndims(x);
x(nans) = 0;
if any(nans(:))
    samplesize = sum(~nans,dim);
else
    samplesize = size(x,dim); % a scalar, => a scalar call to tinv
end

df = max(samplesize - 1,0);
xmean = sum(x,dim) ./ max(1,samplesize);
if isscalar(xmean)
   xcntr = x - xmean;
else
   rep = ones(1,dims);
   rep(dim) = size(x,dim);
   xcntr = x - repmat(xmean,rep);
end
xcntr(nans) = 0;
sumsq = sum(abs(xcntr).^2,dim);
if v>0
   chisqstat = sumsq ./ v;
else
   chisqstat = Inf( size(sumsq) );
   chisqstat(sumsq==0) = NaN;
end

% Compute the correct p-value for the test, and confidence intervals
% if requested.
if tail == 0 % two-tailed test
    p = chi2cdf(chisqstat, df);
    p = 2*min(p, 1-p);
    if nargout > 2
        ci = cat(dim, sumsq ./ chi2inv(1 - alpha/2, df), ...
                      sumsq ./ chi2inv(alpha/2, df));
    end
elseif tail == 1 % right one-tailed test
    p = chi2pval(chisqstat, df);
    if nargout > 2
        ci = cat(dim, sumsq./chi2inv(1 - alpha, df), Inf(size(p)));
    end
elseif tail == -1 % left one-tailed test
    p = chi2cdf(chisqstat, df);
    if nargout > 2
        ci = cat(dim, zeros(size(p)), sumsq./chi2inv(alpha, df));
    end
else
    error('stats:vartest:BadTail',...
          'TAIL must be ''both'', ''right'', or ''left''.');
end
  
% Determine if the actual significance exceeds the desired significance
h = cast(p <= alpha, class(p));
h(isnan(p)) = NaN; % p==NaN => neither <= alpha nor > alpha

if nargout >= 4
    stats = struct('chisqstat', chisqstat, 'df', cast(df,class(chisqstat)));
    if isscalar(df) && ~isscalar(chisqstat)
        stats.df = repmat(stats.df,size(chisqstat));
    end
end

