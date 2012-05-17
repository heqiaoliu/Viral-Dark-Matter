function [r,p,rlo,rup] = corrcoef(x,varargin)
%CORRCOEF Correlation coefficients.
%   R=CORRCOEF(X) calculates a matrix R of correlation coefficients for
%   an array X, in which each row is an observation and each column is a
%   variable.
%
%   R=CORRCOEF(X,Y), where X and Y are column vectors, is the same as
%   R=CORRCOEF([X Y]).  CORRCOEF converts X and Y to column vectors if they
%   are not, i.e., R=CORRCOEF(X,Y) is equivalent to R=CORRCOEF([X(:) Y(:)])
%   in that case.
%
%   If C is the covariance matrix, C = COV(X), then CORRCOEF(X) is
%   the matrix whose (i,j)'th element is
%
%          C(i,j)/SQRT(C(i,i)*C(j,j)).
%
%   [R,P]=CORRCOEF(...) also returns P, a matrix of p-values for testing
%   the hypothesis of no correlation.  Each p-value is the probability
%   of getting a correlation as large as the observed value by random
%   chance, when the true correlation is zero.  If P(i,j) is small, say
%   less than 0.05, then the correlation R(i,j) is significant.
%
%   [R,P,RLO,RUP]=CORRCOEF(...) also returns matrices RLO and RUP, of
%   the same size as R, containing lower and upper bounds for a 95%
%   confidence interval for each coefficient.
%
%   [...]=CORRCOEF(...,'PARAM1',VAL1,'PARAM2',VAL2,...) specifies additional
%   parameters and their values.  Valid parameters are the following:
%
%       Parameter  Value
%       'alpha'    A number between 0 and 1 to specify a confidence
%                  level of 100*(1-ALPHA)%.  Default is 0.05 for 95%
%                  confidence intervals.
%       'rows'     Either 'all' (default) to use all rows, 'complete' to
%                  use rows with no NaN values, or 'pairwise' to compute
%                  R(i,j) using rows with no NaN values in column i or j.
%
%   The p-value is computed by transforming the correlation to create a t
%   statistic having N-2 degrees of freedom, where N is the number of rows
%   of X.  The confidence bounds are based on an asymptotic normal
%   distribution of 0.5*log((1+R)/(1-R)), with an approximate variance equal
%   to 1/(N-3).  These bounds are accurate for large samples when X has a
%   multivariate normal distribution.  The 'pairwise' option can produce
%   an R matrix that is not positive definite.
%
%   Example:  Generate random data having correlation between column 4
%             and the other columns.
%       x = randn(30,4);       % uncorrelated data
%       x(:,4) = sum(x,2);     % introduce correlation
%       [r,p] = corrcoef(x)    % compute sample correlation and p-values
%       [i,j] = find(p<0.05);  % find significant correlations
%       [i,j]                  % display their (row,col) indices
%
%   Class support for inputs X,Y:
%      float: double, single
%
%   See also COV, VAR, STD.

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 5.11.4.12 $  $Date: 2010/02/25 08:08:28 $

if nargin<1
   error('MATLAB:corrcoef:NotEnoughInputs', 'Not enough input arguments.');
end
if ~isempty(varargin) && isnumeric(varargin{1})
   y = varargin{1};
   varargin(1) = [];

   % Convert two inputs to equivalent single input.
   x = x(:);
   y = y(:);
   if length(x)~=length(y)
      error('MATLAB:corrcoef:XYmismatch', 'The lengths of X and Y must match.');
   end
   x = [x y];
elseif ~ismatrix(x)
   error('MATLAB:corrcoef:InputDim', 'Inputs must be 2-D.');
end

% Quickly dispose of most common case.
if nargout<=1 && isempty(varargin)
   r = correl(x);
   return;
end

if ~isreal(x) && nargout>1
   error('MATLAB:corrcoef:ComplexInputs',...
         'Cannot compute p-values for complex inputs.');
end

% Deal with empty inputs
[n,m] = size(x);
if isempty(x)
    if n <= 1
        % Zero observations with m variables results in an m x m NaN,
        % unless m == 0 where we return a scalar NaN by convention.
        % Note, an empty row vector is treated as zero observations with
        % one variable, consistent with treatment of non-empty row vectors.
        r = NaN(max(m,1), class(x));
    else
        % n > 1 observations with no variables returns an empty matrix of
        % correlations.
        r = ones(0, class(x));
    end
    p = r; rlo = r; rup = r;
    return;
end

% Treat all vectors like column vectors.
if isvector(x)
    x = x(:);
    [n, m] = size(x);
end

% Process parameter name/value inputs.
[alpha,userows,emsg] = getparams(varargin{:});
error(emsg);

% Compute correlations.
t = isnan(x);
removemissing = any(t(:));
if isequal(userows, 'all') || ~removemissing
    [r, n] = correl(x);
elseif isequal(userows, 'complete')
    % Remove observations with missing values.
    x = x(~any(t,2),:);
    [r, n] = correl(x);
else
    % Compute correlation for each pair.
    r = zeros(m,class(x));
    n = zeros(m,class(x));
    jk = 1:2;
    for j = 1:m
        jk(1) = j;
        for k=1:j-1
            jk(2) = k;
            tjk = ~any(t(:,jk),2);
            n(j,k) = sum(tjk);
            if n(j,k)<=1
                r(j,k) = NaN;
            else
                rjk = correl(x(tjk,jk));
                r(j,k) = rjk(1,2);
            end
        end
        tj = ~t(:,j);
        n(j,j) = sum(tj);
        if n(j,j)<=1
            r(j,j) = NaN;
        else
            r(j,j) = correl(x(tj,j));
        end
    end
    r = r + tril(r,-1)';
    n = n + tril(n,-1)';
end

% Compute p-value if requested.
if nargout>=2
   % Operate on half of symmetric matrix.
   lowerhalf = (tril(ones(m),-1)>0);
   rv = r(lowerhalf);
   if length(n)>1
      nv = n(lowerhalf);
   else
      nv = n;
   end

   % Tstat = +/-Inf and p = 0 if abs(r) == 1, NaN if r == NaN.
   Tstat = rv .* sqrt((nv-2) ./ (1 - rv.^2));
   p = zeros(m,class(x));
   p(lowerhalf) = 2*tpvalue(-abs(Tstat),nv-2);
   p = p + p' + diag(diag(r)); % Preserve NaNs on diag.

   % Compute confidence bound if requested.
   if nargout>=3
      % Confidence bounds are degenerate if abs(r) = 1, NaN if r = NaN.
      z = 0.5 * log((1+rv)./(1-rv));
      zalpha = NaN(size(nv),class(x));
      if any(nv>3)
         zalpha(nv>3) = (-erfinv(alpha - 1)) .* sqrt(2) ./ sqrt(nv(nv>3)-3);
      end
      rlo = zeros(m,class(x));
      rlo(lowerhalf) = tanh(z-zalpha);
      rlo = rlo + rlo' + diag(diag(r)); % Preserve NaNs on diag.
      rup = zeros(m,class(x));
      rup(lowerhalf) = tanh(z+zalpha);
      rup = rup + rup' + diag(diag(r)); % Preserve NaNs on diag.
   end
end


% ------------------------------------------------
function [r,n] = correl(x)
%CORREL Compute correlation matrix without error checking.

[n,m] = size(x);
r = cov(x);
d = sqrt(diag(r)); % sqrt first to avoid under/overflow
r = bsxfun(@rdivide,r,d); r = bsxfun(@rdivide,r,d'); % r = r ./ d*d';
% Fix up possible round-off problems, while preserving NaN: put exact 1 on the
% diagonal, and limit off-diag to [-1,1].
t = find(abs(r) > 1); r(t) = r(t)./abs(r(t));
r(1:m+1:end) = sign(diag(r));


% ------------------------------------------------
function p = tpvalue(x,v)
%TPVALUE Compute p-value for t statistic.

normcutoff = 1e7;
if length(x)~=1 && length(v)==1
   v = repmat(v,size(x));
end

% Initialize P.
p = NaN(size(x));
nans = (isnan(x) | ~(0<v)); % v == NaN ==> (0<v) == false

% First compute F(-|x|).
%
% Cauchy distribution.  See Devroye pages 29 and 450.
cauchy = (v == 1);
p(cauchy) = .5 + atan(x(cauchy))/pi;

% Normal Approximation.
normal = (v > normcutoff);
p(normal) = 0.5 * erfc(-x(normal) ./ sqrt(2));

% See Abramowitz and Stegun, formulas 26.5.27 and 26.7.1.
gen = ~(cauchy | normal | nans);
p(gen) = betainc(v(gen) ./ (v(gen) + x(gen).^2), v(gen)/2, 0.5)/2;

% Adjust for x>0.  Right now p<0.5, so this is numerically safe.
reflect = gen & (x > 0);
p(reflect) = 1 - p(reflect);

% Make the result exact for the median.
p(x == 0 & ~nans) = 0.5;


% -----------------------------------------------
function [alpha,userows,estruc] = getparams(varargin)
%GETPARAMS Process input parameters for CORRCOEF.
alpha = 0.05;
userows = 'all';
estruc = [];
while ~isempty(varargin)
   if length(varargin)==1
      estruc.message = 'Unmatched parameter name/value pair.';
      estruc.identifier = 'MATLAB:corrcoef:unmatchedPVPair';
      return
   end
   pname = varargin{1};
   if ~ischar(pname)
      estruc.message = 'Invalid argument name.';
      estruc.identifier = 'MATLAB:corrcoef:invalidArgName';
      return
   end
   pval = varargin{2};
   j = strmatch(pname, {'alpha' 'rows'});
   if isempty(j)
      estruc.message = sprintf('Invalid argument name ''%s''.',pname);
      estruc.identifier = 'MATLAB:corrcoef:invalidArgName';
      return
   end
   if j==1
      alpha = pval;
   else
      userows = pval;
   end
   varargin(1:2) = [];
end

% Check for valid inputs.
if ~isnumeric(alpha) || ~isscalar(alpha) || alpha<=0 || alpha>=1
   estruc.message = 'The ''alpha'' parameter must be a scalar between 0 and 1.';
   estruc.identifier = 'MATLAB:corrcoef:invalidAlpha';
   return
end
oktypes = {'all' 'complete' 'pairwise'};
if isempty(userows) || ~ischar(userows)
   i = [];
else
   i = strmatch(lower(userows), oktypes);
end
if isempty(i)
   estruc.message = 'Valid row choices are ''all'', ''complete'', and ''pairwise''.';
   estruc.identifier = 'MATLAB:corrcoef:invalidRowChoice';
   return
end
userows = oktypes{i};
