function y = var(x,w,dim)
%VAR Variance.
%   For vectors, Y = VAR(X) returns the variance of the values in X.  For
%   matrices, Y is a row vector containing the variance of each column of
%   X.  For N-D arrays, VAR operates along the first non-singleton
%   dimension of X.
%
%   VAR normalizes Y by N-1 if N>1, where N is the sample size.  This is
%   an unbiased estimator of the variance of the population from which X is
%   drawn, as long as X consists of independent, identically distributed
%   samples. For N=1, Y is normalized by N. 
%
%   Y = VAR(X,1) normalizes by N and produces the second moment of the
%   sample about its mean.  VAR(X,0) is the same as VAR(X).
%
%   Y = VAR(X,W) computes the variance using the weight vector W.  W typically
%   contains either counts or inverse variances.  The length of W must equal
%   the length of the dimension over which VAR operates, and its elements must
%   be nonnegative.  If X(I) is assumed to have variance proportional to
%   1/W(I), then Y * MEAN(W)/W(I) is an estimate of the variance of X(I).  In
%   other words, Y * MEAN(W) is an estimate of variance for an observation
%   given weight 1.
%
%   Y = VAR(X,W,DIM) takes the variance along the dimension DIM of X.  Pass
%   in 0 for W to use the default normalization by N-1, or 1 to use N.
%
%   The variance is the square of the standard deviation (STD).
%
%   Example: If X = [4 -2 1
%                    9  5 7]
%      then var(X,0,1) is [12.5 24.5 18.0] and var(X,0,2) is [9.0
%                                                             4.0]
%
%   Class support for inputs X, W:
%      float: double, single
%
%   See also MEAN, STD, COV, CORRCOEF.

%   VAR supports both common definitions of variance.  If X is a
%   vector, then
%
%      VAR(X,0) = SUM(RESID.*CONJ(RESID)) / (N-1)
%      VAR(X,1) = SUM(RESID.*CONJ(RESID)) / N
%
%   where RESID = X - MEAN(X) and N is LENGTH(X). For scalar X,
%   the first definition would result in NaN, so the denominator N 
%   is always used.
%
%   The weighted variance for a vector X is defined as
%
%      VAR(X,W) = SUM(W.*RESID.*CONJ(RESID)) / SUM(W)
%
%   where now RESID is computed using a weighted mean.

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.7.4.8 $  $Date: 2010/02/25 08:08:38 $

if isinteger(x) 
    error('MATLAB:var:integerClass',...
          'First argument must be single or double.');
end

if nargin < 2 || isempty(w), w = 0; end

if nargin < 3
    % The output size for [] is a special case when DIM is not given.
    if isequal(x,[]), y = NaN(class(x)); return; end

    % Figure out which dimension sum will work along.
    dim = find(size(x) ~= 1, 1);
    if isempty(dim), dim = 1; end
end
n = size(x,dim);

% Unweighted variance
if isequal(w,0) || isequal(w,1)
    if w == 0 && n > 1
        % The unbiased estimator: divide by (n-1).  Can't do this
        % when n == 0 or 1.
        denom = n - 1;
    else
        % The biased estimator: divide by n.
        denom = n; % n==0 => return NaNs, n==1 => return zeros
    end

    if n > 0 % avoid divide-by-zero
        xbar = sum(x, dim) ./ n;
        x = bsxfun(@minus, x, xbar);
    end
    y = sum(abs(x).^2, dim) ./ denom; % abs guarantees a real result

    % Weighted variance
elseif isvector(w) && all(w >= 0)
    if numel(w) ~= n
        if isscalar(w)
            error('MATLAB:var:invalidWgts',...
                  'W must be a vector of nonnegative weights, or a scalar 0 or 1.');
        else
            error('MATLAB:var:invalidSizeWgts',...
                  'The length of W must be compatible with X.');
        end
    end

    % Normalize W, and embed it in the right number of dims.  Then
    % replicate it out along the non-working dims to match X's size.
    wresize = ones(1,max(ndims(x),dim)); wresize(dim) = n;
    w = reshape(w ./ sum(w), wresize);
    x0 = bsxfun(@times, w, x);
    x = bsxfun(@minus, x, sum(x0, dim));
    y = sum(bsxfun(@times, w, abs(x).^2), dim); % abs guarantees a real result

else
    error('MATLAB:var:invalidWgts', ...
          'W must be a vector of nonnegative weights, or a scalar 0 or 1.');
end
