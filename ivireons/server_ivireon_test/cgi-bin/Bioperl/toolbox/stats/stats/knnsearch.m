function [idx, dist] = knnsearch(X,Y,varargin)
%KNNSEARCH Find K nearest neighbors.
%   IDX = KNNSEARCH(X,Y) finds the nearest neighbor in X for each point in
%   Y. X is an MX-by-N matrix and Y is an MY-by-N matrix. Rows of X and Y
%   correspond to observations and columns correspond to variables. IDX is
%   a column vector with MY rows. Each row in IDX contains the index of
%   the nearest neighbor in X for the corresponding row in Y.
%
%   [IDX, D] = KNNSEARCH(X,Y) returns a MY-by-1 vector D containing the
%   distances between each row of Y and its closest point in X.
%
%   [IDX, D]= KNNSEARCH(X,Y,'NAME1',VALUE1,...,'NAMEN',VALUEN) specifies
%   optional argument name/value pairs:
%
%     Name        Value
%     'K'         A positive integer, K, specifying the number of nearest
%                 nearest neighbors in X to find for each point in Y.
%                 Default is 1. IDX and D are MY-by-K matrices. D sorts the
%                 distances in each row in ascending order. Each row in IDX
%                 contains the indices of K closest neighbors in X
%                 corresponding to the K smallest distances in D.
%
%     'NSMethod'  Nearest neighbors search method. Value is either:
%                 'kdtree' - Creates and uses a kd-tree to find nearest
%                            neighbors. 'kdtree' is only valid when the
%                            distance metric is one of the following metrics:
%                                   - 'euclidean'
%                                   - 'cityblock'
%                                   - 'minkowski'
%                                   - 'chebyshev'
%                 'exhaustive' - Uses the exhaustive search algorithm.  The
%                                distance values from all the points in X
%                                to each point in Y are computed to find
%                                nearest neighbors. 
%                 The default value is 'kdtree' when the number of columns
%                 of X is not greater than 10, X is not sparse, and the
%                 distance metric is one of the above 4 metrics; otherwise,
%                 the default value is 'exhaustive'.
%
%    'Distance'   A string or a function handle specifying the distance
%                 metric. The value can be one of the following:
%                 'euclidean'   - Euclidean distance (default).
%                 'seuclidean'  - Standardized Euclidean distance. Each
%                                 coordinate difference between X and a
%                                 query point is scaled by dividing by a
%                                 scale value S. The default value of S is
%                                 the standard deviation computed from X,
%                                 S=NANSTD(X). To specify another value for
%                                 S, use the 'Scale' argument.
%                 'cityblock'   - City Block distance.
%                 'chebychev'   - Chebychev distance (maximum coordinate
%                                 difference).
%                 'minkowski'   - Minkowski distance. The default exponent
%                                 is 2. To specify a different exponent,
%                                 use the 'P' argument. 
%                 'mahalanobis' - Mahalanobis distance, computed using a
%                                 positive definite covariance matrix C.
%                                 The default value of C is the sample
%                                 covariance matrix of X, as computed by
%                                 NANCOV(X). To specify another value for
%                                 C, use the 'Cov' argument.
%                 'cosine'      - One minus the cosine of the included
%                                 angle between observations (treated as
%                                 vectors).
%                 'correlation' - One minus the sample linear
%                                 correlation between observations
%                                 (treated as sequences of values).
%                 'spearman'    - One minus the sample Spearman's rank
%                                 correlation between observations
%                                 (treated as sequences of values).
%                 'hamming'     - Hamming distance, percentage of
%                                 coordinates that differ.
%                 'jaccard'     - One minus the Jaccard coefficient, the
%                                 percentage of nonzero coordinates that
%                                 differ.
%                 function      - A distance function specified using @
%                                 (for example @DISTFUN). A distance
%                                 function must be of the form
%  
%                                 function D2 = DISTFUN(ZI, ZJ),
%  
%                                 taking as arguments a 1-by-N vector ZI
%                                 containing a single row of X or Y, an
%                                 M2-by-N matrix ZJ containing multiple
%                                 rows of X or Y, and returning an M2-by-1
%                                 vector of distances D2, whose Jth element
%                                 is the distance between the observations
%                                 ZI and ZJ(J,:).
%
%    'P'          A positive scalar indicating the exponent of Minkowski
%                 distance. This argument is only valid when 'Distance' is
%                 'minkowski'. Default is 2.
%  
%    'Cov'        A positive definite matrix indicating the covariance
%                 matrix when computing the Mahalanobis distance. This
%                 argument is only valid when 'Distance' is
%                 'mahalanobis'. Default is NANCOV(X).
%  
%    'Scale'      A vector S containing non-negative values, with length
%                 equal to the number of columns in X. Each coordinate
%                 difference between X and a query point is scaled by the
%                 corresponding element of S. This argument is only valid
%                 when 'Distance' is 'seuclidean'. Default is NANSTD(X).
%  
%    'BucketSize' The maximum number of data points in the leaf node of the
%                 kd-tree (default is 50). This argument is only meaningful
%                 when kd-tree is used for finding nearest neighbors.
% 
%   Example:
%      % Find 2 nearest neighbors in X and the corresponding values to each
%      % point in Y using the distance metric 'cityblock'
%      X = randn(100,5);
%      Y = randn(25, 5);
%      [idx, dist] = knnsearch(X,Y,'dist','cityblock');
%
%   See also CREATENS, Exhaustivesearcher, KDTreeSearcher.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:15:01 $

if nargin < 2
    error('stats:knnsearch:TooFewInputs',...
        'Two input arguments are required.');
end
nDims = size(X,2);
nDimsY = size(Y,2);

if nDimsY ~= nDims
    error('stats:knnsearch:SizeMisMatch',...
        'X and Y must have the same number of columns.');
end

pnames = { 'k' 'nsmethod' 'bucketsize'};
dflts =  { 1   []         [] };
[eid, errmsg,numNN, nsmethod, bSize, args] =...
    internal.stats.getargs(pnames, dflts, varargin{:});
if ~isempty(eid)
    error(sprintf('stats:knnsearch:%s',eid),errmsg);
end

if ~isempty(numNN)
    if ~isscalar(numNN) || ~isnumeric(numNN) || numNN <1 || numNN~=round(numNN)
        error('stats:knnsearch:BadK',...
            'K must be an positive integer specifying the number of neighbors.');
    end
end
O=createns(X,args{:},'nsmethod', nsmethod,'bucketSize',bSize);
if nargout < 2
    idx = knnsearch(O,Y,'k',numNN);
else
    [idx, dist] = knnsearch(O,Y,'k',numNN);
end
end
