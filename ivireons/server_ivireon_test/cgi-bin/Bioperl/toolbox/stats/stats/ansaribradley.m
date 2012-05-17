function [h,p,stats] = ansaribradley(x,y,alpha,tail,exact,dim)
%ANSARIBRADLEY Ansari-Bradley two-sample test for equal dispersions.
%   H = ANSARIBRADLEY(X,Y) performs an Ansari-Bradley test of the hypothesis
%   that two independent samples, in the vectors X and Y, come from the same
%   distribution, against the alternative that they come from distributions
%   that have the same median and shape but different dispersions (e.g.
%   variances).  The result is H=0 if the null hypothesis of identical
%   distributions cannot be rejected at the 5% significance level, or H=1
%   if the null hypothesis can be rejected at the 5% level.  X and Y can
%   have different lengths.
%
%   X and Y can also be matrices or N-D arrays.  For matrices, ANSARIBRADLEY
%   performs separate tests along each column, and returns a vector of results.
%   X and Y must have the same number of columns.  For N-D arrays,
%   ANSARIBRADLEY works along the first non-singleton dimension.  X and Y
%   must have the same size along all the remaining dimensions.
%
%   ANSARIBRADLEY treats NaNs as missing values, and ignores them.
%
%   H = ANSARIBRADLEY(X,Y,ALPHA) performs the test at the significance level
%   (100*ALPHA)%.  ALPHA must be a scalar.
%
%   H = ANSARIBRADLEY(X,Y,ALPHA,TAIL) performs the test against the alternative
%   hypothesis specified by TAIL:
%       'both'  -- "dispersion parameters are not equal" (two-tailed test)
%       'right' -- "dispersion of X is greater than dispersion of Y" (right-
%                  tailed test)
%       'left'  -- "dispersion of X is less than dispersion of Y" (left-
%                  tailed test)
%   TAIL must be a single string.
%
%   [H,P] = ANSARIBRADLEY(...) returns the p-value, i.e., the probability of
%   observing the given result, or one more extreme, by chance if the null
%   hypothesis is true.  Small values of P cast doubt on the validity of
%   the null hypothesis.
%
%   [H,P,STATS] = ANSARIBRADLEY(...) returns a structure with the following
%   fields:
%      'W'      -- the value of the test statistic W, which is the sum of
%                  the Ansari-Bradley ranks for the X sample
%      'Wstar'  -- approximate normal statistic W*
%
%   [...] = ANSARIBRADLEY(X,Y,ALPHA,TAIL,EXACT) with EXACT='on' computes P
%   using an exact calculation of the distribution of W.  This can be
%   time-consuming for large samples.  EXACT='off' computes P using a normal
%   approximation for the distribution of W*.  The default if EXACT is empty
%   is to use the exact calculation if N, the total number of rows in X and Y,
%   is 25 or less, and to use the  normal approximation if N>25.  Pass in []
%   for ALPHA and TAIL to use their default values while specifying a value
%   for EXACT.  Note that N is computed before any NaN values (representing
%   missing data) are removed.
%
%   [...] = ANSARIBRADLEY(X,Y,ALPHA,TAIL,EXACT,DIM) works along dimension
%   DIM of X and Y.
%
%   The Ansari-Bradley test is a nonparametric alternative to the two-sample
%   F test of equal variances.  It does not require the assumption that X and
%   Y come from normal distributions.  The dispersion of a distribution is
%   generally measured by its variance or standard deviation, but the
%   Ansari-Bradley test can be used with samples from distributions that do
%   not have finite variances.
%
%   The theory behind the Ansari-Bradley test requires that the groups
%   have equal medians.  Under that assumption and if the distributions
%   in each group are continuous and identical, the test does not depend
%   on the distributions in each group.  If the groups do not have the
%   same medians, the results may be misleading.  Ansari and Bradley
%   recommend subtracting the median in that case, but the distribution of 
%   the resulting test, under the null hypothesis, is no longer independent
%   of the common distribution of X and Y.  If you want to perform the
%   tests with medians subtracted, you should subtract the medians from X
%   and Y before calling ANSARIBRADLEY.
%
%   Example:  Is the dispersion significantly different for two model years?
%      load carsmall
%      [h,p,st] = ansaribradley(MPG(Model_Year==82),MPG(Model_Year==76))
%
%   See also VARTEST, VARTESTN, TTEST2, TIEDRANK.

%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/16 00:12:10 $

if nargin < 2
    error('stats:ansaribradley:TooFewInputs',...
          'Requires at least two input arguments');
end

if nargin < 3 || isempty(alpha)
    alpha = 0.05;
elseif ~isscalar(alpha) || alpha <= 0 || alpha >= 1
    error('stats:ansaribradley:BadAlpha',...
          'ALPHA must be a scalar between 0 and 1.');
end

if nargin < 4 || isempty(tail)
    tail = 0;
elseif ischar(tail) && (size(tail,1)==1)
    tail = find(strncmpi(tail,{'left','both','right'},length(tail))) - 2;
end
if ~isscalar(tail) || ~isnumeric(tail)
    error('stats:ansaribradley:BadTail', ...
          'TAIL must be one of the strings ''both'', ''right'', or ''left''.');
end

if nargin < 5 || isempty(exact)
   doexact = '';
else
   if ischar(exact)
       choices = {'on';'off'};
       i = find(strncmpi(exact,choices,length(exact)));
   else
       i = [];
   end
   if ~isscalar(i)
       error('stats:ansaribradley:BadExact', ...
           'EXACT must be either ''on'' or ''off''.');
   end       
   doexact = (i==1);
end

if nargin < 6 || isempty(dim)
    % Figure out which dimension to work along by looking at x.
    % y will have to be compatible.
    dim = find(size(x) ~= 1, 1);
    if isempty(dim), dim = 1; end
    
    % If we haven't been given an explicit dimension, and we have two
    % vectors, then make y the same orientation as x.
    if isvector(x) && isvector(y)
        if (size(x,1)==1)
            y = y(:)'; 
        else
            y = y(:);
        end
    end
end
if ~isscalar(dim) || ~ismember(dim,1:ndims(x))
    error('stats:ansaribradley:BadDim', ...
      'DIM must be an integer between 1 and %d.',ndims(x));
end        

% Make sure all of x's and y's non-working dimensions are identical.
sizex = size(x); nx = sizex(dim); sizex(dim) = 1;
sizey = size(y); ny = sizey(dim); sizey(dim) = 1;
if ~isequal(sizex,sizey)
    error('stats:ansaribradley:InputSizeMismatch',...
          'The sizes of X and Y must be commensurate.');
end

if isempty(doexact)
    doexact = (nx+ny <= 25);
end

% Prepare data so that we can get at each sample easily
if  dim~=1
    x = shiftdim(x,dim-1);
    y = shiftdim(y,dim-1);
end
if ndims(x)>2
    x = reshape(x,nx,prod(sizex));
    y = reshape(y,ny,prod(sizey));
end

% Operate on each sample
nsamples = size(x,2);
W = zeros(sizex,superiorfloat(x,y));
Wstar = W;
p = W;
for j=1:nsamples
    % Perform test on jth sample
    xv = x(:,j);
    yv = y(:,j);
    xv(isnan(xv)) = [];
    yv(isnan(yv)) = [];
    nxv = length(xv);
    nyv = length(yv);
    z = [xv;yv];
    grp = [ones(nxv,1); 2*ones(nyv,1)];
    [W(j),Wstar(j),pvals] = abtest(z,grp,doexact);

    % Compute p-value considering requested alternative
    if tail == 0     % two-tailed test
        p(j) = min(1, 2*(pvals(2) + min(pvals(1),pvals(3))));
    elseif tail == 1 % right one-tailed test, note that a smaller value
                     % of W implies a larger variance for X
        p(j) = pvals(2)+pvals(1);
    elseif tail == -1 % left one-tailed test
        p(j) = pvals(2)+pvals(3);
    end
end

% Determine if the actual significance exceeds the desired significance
h = cast(p <= alpha, class(p));
h(isnan(p)) = NaN; % p==NaN => neither <= alpha nor > alpha

if nargout >= 3
    stats = struct('W', W, 'Wstar', Wstar);
end


% --------------------------------------------
function [W,Wstar,pvals] = abtest(x,g,doexact)
%ABTEST Ansari-Bradley test for a pair of vectors

% Get sorted data and group identifiers
[x,idx] = sort(x);
g = g(idx);

% Compute Ansari-Bradley scores
N = length(x);
r = tiedrank(x,0,1);

% Ansari-Bradley statistic W
W = sum(r(g==1));

% Asymptotic normal statistic W*
m = sum(g==1);
n = N-m;
sumsq = sum(r.^2);
if mod(N,2)==0      % even sample size
    meanW = m * (N+2) / 4;
    stdW = sqrt(m * n * (16*sumsq - N*(N+2)^2) / (16 * N * (N-1)));
else                % odd sample size
    meanW = m * (N+1)^2 / (4 * N);
    stdW = sqrt(m * n * (16*N*sumsq - (N+1)^4) / (16 * N^2 * (N-1)));
end
if stdW>0
    Wstar = (W - meanW) / stdW;
elseif W==meanW
    Wstar = NaN;
else
    Wstar = sign(W-meanW)*Inf;
end

if (m==0) || (n==0)
    pvals = NaN(1,3);
elseif doexact
    % Create equivalent two-row contingency table and weights
    u = unique(x);
    wts = zeros(1,length(u));
    
    t1 = (g==1);
    [row1,bin1] = histc(x(t1),u);
    wts(bin1) = r(t1);
    
    t2 = ~t1;
    [row2,bin2] = histc(x(t2),u);
    wts(bin2) = r(t2);
    
    tbl = [row1(:)'; row2(:)'];
    
    % Compute p-values using exact distribution
    [ignore,pvals] = statctexact(tbl,wts,W);
else
    % Use normal approximation
    p = normcdf(-abs(Wstar));
    if Wstar<0
        pvals = [p 0 1-p];
    else
        pvals = [1-p 0 p];
    end
end
