function [minval, maxval] = robustdatabounds(X, msamp)
% Robust estimation of data boundaries.
%
% [minval, maxval] = robustdatabounds(X, N)
% minval and maxval are row vectors containing the min and max values of
% the columns of the matrix X.
% If X has no more than N rows, then non robust min and max values are
% returned. Default N=30;

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/10/31 06:14:34 $

% Author(s): Qinghua Zhang

if nargin<2
    msamp = 30;
end

if ~isrealmat(X)
    ctrlMsgUtils.error('Ident:idnlmodel:robustdataboundsCheck1')
end
if ~isposintscalar(msamp)
    ctrlMsgUtils.error('Ident:idnlmodel:robustdataboundsCheck2')
end

[m, n] = size(X);
if m<=msamp
    % Two few samples, simple min-max values
    minval = min(X,[],1);
    maxval = max(X,[],1);
    
else
    nav = round(log(m)*0.9); % min and max values will be averaged over nav samples.
    minvalues = zeros(nav, 1);
    maxvalues = zeros(nav, 1);
    mininds = zeros(nav, 1);
    maxinds = zeros(nav, 1);
    
    minval = zeros(1,n);
    maxval = zeros(1,n);
    
    for j=1:n
        
        [xmin, imin] = min(X(:,j));
        [xmax, imax] = max(X(:,j));
        
        minvalues(1) = xmin;
        maxvalues(1) = xmax;
        mininds(1) = imin;
        maxinds(1) = imax;
        
        for k=2:nav
            X(mininds(k-1),j) =  maxvalues(1);
            [xmin, imin] = min(X(:,j));
            minvalues(k) = xmin;
            mininds(k) = imin;
        end
        
        X(mininds, j) = minvalues(1);
        
        for k=2:nav
            X(maxinds(k-1),j) =  minvalues(1);
            [xmax, imax] = max(X(:,j));
            maxvalues(k) = xmax;
            maxinds(k) = imax;
        end
        
        minval(j) = median(minvalues);
        maxval(j) = median(maxvalues);
    end
end

% FILE END
