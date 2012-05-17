function O = createns(X,varargin)
%CREATENS Create a NeighborSearcher object for K-nearest neighbors search.
%   NS = CREATENS(X) uses the data observations in an MX-by-N matrix X to
%   create an object NS. Rows of X correspond to observations and columns
%   correspond to variables. NS is an object of a class derived from the
%   NeighborSearcher class, i.e., either a ExhaustiveSearcher object or a
%   KDTreeSearcher object. You can use NS to find nearest neighbors in X
%   for other query points. When NS is an ExhaustiveSearcher object, the
%   KNNSEARCH method uses the exhaustive search algorithm to find the K
%   nearest neighbors, i.e., the KNNSEARCH method computes the distance
%   values from all the points in X to the query points to find the K
%   nearest neighbors. When NS is a KDTreeSearcher, CREATENS creates and
%   saves a kd-tree based on X in NS. The KNNSEARCH method uses the
%   kd-tree to find the K nearest neighbors.
%
%   NS = CREATENS(X,'NAME1',VALUE1,...,'NAMEN',VALUEN) accepts one or more
%   comma-separated optional argument name/value pairs. 
%
%     Name         Value
%     'NSMethod'   Nearest neighbors search method. Value is either:
%                   'kdtree' - Create a KDTreeSearcher object. 'kdtree' is
%                              only valid when the distance metric is one
%                              of the following metrics:
%                                   - 'euclidean'
%                                   - 'cityblock'
%                                   - 'minkowski'
%                                   - 'chebychev'
%                   'exhaustive' - Create an ExhaustiveSearcher object. 
%
%                  The default value is 'kdtree' when the number of columns
%                  of X is not greater than 10, X is not sparse, and the
%                  distance metric is one the above 4 metrics; Otherwise,
%                  the default value is 'exhaustive'.
%
%     'Distance'   A string or a function handle specifying the default
%                  distance metric used when you call the KNNSEARCH method
%                  to find nearest neighbors for future query points.
%                  The value can be one of the following:
%
%                  For both ExhaustiveSearcher and KDTreeSearcher objects:
%                  'euclidean'   - Euclidean distance (default).
%                  'cityblock'   - City Block distance.
%                  'minkowski'   - Minkowski distance. The default exponent
%                                  is 2.
%                  'chebychev'   - Chebychev distance (maximum coordinate
%                                  difference).
%
%                  For ExhaustiveSearcher object only:
%                  'seuclidean'  - Standardized Euclidean distance. Each
%                                  coordinate difference between X and a
%                                  query point is scaled by dividing by a 
%                                  scale value S. The default value of S is
%                                  the standard deviation computed from X,
%                                  S=NANSTD(X). To specify another value
%                                  for S, use the 'Scale' argument.
%                  'mahalanobis' - Mahalanobis distance, computed using a
%                                  positive definite covariance matrix C.
%                                  The default value of C is the sample
%                                  covariance matrix of X, as computed by
%                                  NANCOV(X). To specify another value for
%                                  C, use the 'Cov' argument.
%                  'cosine'      - One minus the cosine of the included
%                                  angle between observations (treated as
%                                  vectors).
%                  'correlation' - One minus the sample linear
%                                  correlation between observations
%                                  (treated as sequences of values).
%                  'spearman'    - One minus the sample Spearman's rank
%                                  correlation between observations
%                                  (treated as sequences of values).
%                  'hamming'     - Hamming distance, percentage of
%                                  coordinates that differ.
%                  'jaccard'     - One minus the Jaccard coefficient, the
%                                  percentage of nonzero coordinates that
%                                  differ.
%                  function      - A distance function specified using @
%                                  (for example @DISTFUN). A distance
%                                  function must be of the form
%
%                                  function D2 = DISTFUN(ZI, ZJ),
% 
%                                  taking as arguments a 1-by-N vector ZI
%                                  containing a single row from X or from
%                                  the query points Y, and an M2-by-N
%                                  matrix ZJ containing multiple rows of X
%                                  or Y, and returning an M2-by-1 vector of
%                                  distances D2, whose Jth element is the
%                                  distance between the observations ZI and
%                                  ZJ(J,:).
%
%    'P'           A positive scalar indicating the exponent for Minkowski
%                  distance. This argument is valid only when 'Distance' is
%                  'minkowski'. Default is 2.
%
%    'Cov'         A positive definite matrix indicating the covariance
%                  matrix when computing the Mahalanobis distance. This
%                  argument is valid only when 'Distance' is 'mahalanobis'.
%                  Default is NANCOV(X).
%
%    'Scale'       A vector S containing non-negative values, with length
%                  equal to the number of columns in X. Each coordinate
%                  difference between X and a query point is scaled by the
%                  corresponding element of S when computing the
%                  standardized Euclidean distance. This argument is valid
%                  only when 'Distance' is 'seuclidean'. Default is
%                  NANSTD(X).
%
%    'BucketSize'  The maximum number of data points in the leaf node of
%                  the kd-tree (default is 50). This argument is only
%                  meaningful for creating a KDTreeSearcher object.
%
%   Examples:
%      % Create a NeighborSearcher object for data X with the 'euclidean' 
%      % distance. Since X is not sparse and has 5 variables, and the
%      % distance is 'euclidean' by default, CREATENS creates a
%      % KDTreeSearcher object.
%      X = randn(100,5);
%      ns = createns(X);
%      % Find 5 nearest neighbors in X and the corresponding distance
%      % values for each point in Y
%      Y = randn(25, 5);
%      [idx, dist] = knnsearch(ns,Y,'k',5);
%
%      % Create a NeighborSearcher object for data X with the 'cosine' 
%      % distance. Since the kd-tree method doesn't support the 'cosine'
%      % distance, CREATENS creates an ExhaustiveSearcher object.
%      ns = createns(X, 'distance', 'cosine');
%      % Find 5 nearest neighbors in X for each point in Y
%      idx = knnsearch(ns,Y,'k',5);
%
%   See also ExhaustiveSearcher, KDTreeSearcher, KNNSEARCH.

%   Copyright 2009 The MathWorks, Inc.
%   $ $  $Date: 2010/03/16 00:13:12 $


if nargin < 1
    error('stats:createnn:TooFewInputs','At least one input argument is required.');
end

pnames = {'nsmethod' 'distance',   'bucketsize' };
dflts =  {[]         'euclidean'    []};

[eid,errmsg,nsmethod,distMetric,bSize,args] = ...
    internal.stats.getargs(pnames, dflts, varargin{:});
if ~isempty(eid)
    error(sprintf('stats:createns:%s',eid),errmsg);
end
nDims = size(X,2);
if isempty(nsmethod) %doesn't specify whether to use kdtree or exhaustive search
    %parse the distance input
    if ischar(distMetric)
        distList = {'euclidean';  'cityblock'; 'chebychev'; 'minkowski';...
            'mahalanobis'; 'seuclidean'; 'cosine'; 'correlation'; ...
            'spearman'; 'hamming'; 'jaccard'};
        i = find(strncmpi(distMetric, distList, length(distMetric)));
        if length(i) > 1
            error('stats:createns:BadDistance',...
                'Ambiguous Distance argument:  %s.', distMetric);
        elseif isempty(i)
            error('stats:createns:UnrecognizedDistance',...
                'Unrecognized Distance argument: %s.', distMetric);
        end
    elseif ~isa(distMetric, 'function_handle') 
        error('stats:createns:BadDistance',...
            'The Distance argument must be a string or a function.');
    end
    
    %We need to figure out which method will be used to perform KNN search.
    %If the distance belongs to the Minkowski distance family and the
    %dimension is less than 10 and the data is not sparse, a KDTreeSearcher
    %object will be created; Otherwise, we create an ExhaustiveSearcher
    if ischar(distMetric) && i <= 4 && nDims <= 10  && ~issparse(X)
        O = KDTreeSearcher(X,'distance',distMetric,'bucketSize',bSize, args{:});
    else% ExhaustiveSearcher
        if ~isempty(bSize)
            if ischar(distMetric) && i<=4 
                %the distance metric belongs to the Minkowski distance
                %family
                warning('stats:createns:IgnoringBucketSize',...
                    ['A ExhaustiveSearcher object will be created when the ',...
                    'number of features is greater than 10 or the data is sparse. ',...
                    '''BUCKETSIZE'' argument will be ignored. ',...
                    'Specify ''KDTREE'' for ''NSMETHOD'' argument if you want ',...
                    'to create a kd-tree to find nearest neighbors. ']);
            else
                warning('stats:createns:IgnoringBucketSize',...
                    ['An ExhaustiveSearcher object will be created because ',...
                    'KDTreeSearcher doesn''t support the requested distance ',...
                    'metric. ''BUCKETSIZE'' argument will be ignored. ']);
            end
        end
        O = ExhaustiveSearcher(X,'distance', distMetric,args{:});
    end
    
elseif ~ischar(nsmethod)
    error('stats:createns:BadMethod','''NSMETHOD'' must be a string.')
else
    nsmethodNames = {'exhaustive','kdtree'};
    i = strncmpi(nsmethod,nsmethodNames,1);
    if ~any(i)
        error('stats:createnn:UnknownMethod',...
            'Unknown ''NSMETHOD'' parameter value: %s.', nsmethod);
    end
    
    if find(i)==1 %strncmpi(nsmethod,'exhaustive',1)
        if ~isempty(bSize)
            warning('stats:createns:IgnoringBucketSize',...
                ['''BucketSize'' argument will be ignored when ',...
                '''NSMETHOD is set to ''Exhaustive''.']);
        end
        O = ExhaustiveSearcher(X,'distance',distMetric,args{:});
    else
        O = KDTreeSearcher(X,'distance',distMetric,'bucketSize',bSize,...
                              args{:});
    end
end
