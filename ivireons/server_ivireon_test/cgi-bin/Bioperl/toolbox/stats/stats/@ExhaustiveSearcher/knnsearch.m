function [idx,dist]=knnsearch(obj,Y,varargin)
%KNNSEARCH Find K nearest neighbors using an ExhaustiveSearcher object.
%   IDX = KNNSEARCH(NS,Y) finds the nearest neighbor (closest point) in
%   X=NS.X for each point in Y. Rows of Y correspond to observations and
%   columns correspond to variables. Y must have the same number of columns
%   as X. IDX is a column vector with NY rows, where NY is the number of
%   rows in Y. Each row in IDX contains the index of the observation in X
%   that has the minimum distance to the corresponding row in Y. The
%   KNNSEARCH method computes the distance values from all the points in X
%   to the query points to find nearest neighbors. 
%
%   [IDX, D] = KNNSEARCH(NS,Y) returns a column vector D containing
%   the distance between each row of Y and its closest point in X.
%   That is, D(I) is the distance between X(IDX(I),:) and Y(I,:).
%
%   [IDX, D]= KNNSEARCH(NS,Y,'NAME1',VALUE1,...,'NAMEN',VALUEN) specifies
%   optional argument name/value pairs.
%
%     Name        Value
%     'K'         A positive integer, K, specifying the number of nearest
%                 neighbors in X for each point in Y. Default is 1. IDX
%                 and D are NY-by-K matrices. D sorts the distances in each
%                 row in ascending order. Each row in IDX contains the
%                 indices of K closest neighbors in X corresponding to
%                 the K smallest distances in D.
%
%     'Distance'  A string or a function handle specifying the distance
%                 metric. The value can be one of the following (default is
%                 NS.Distance):
%                 'euclidean'   - Euclidean distance.
%                 'seuclidean'  - Standardized Euclidean distance. Each
%                                 coordinate difference between X and a
%                                 query point is scaled by dividing by a
%                                 scale value S. The default value of S is
%                                 NS.DistParameter if NS.Distance is
%                                 'seuclidean', otherwise the default is
%                                 the standard deviation computed from X,
%                                 S=NANSTD(X). To specify another value for
%                                 S, use the 'Scale' argument.
%                 'cityblock'   - City Block distance.
%                 'chebychev'   - Chebychev distance (maximum coordinate
%                                 difference).
%                 'minkowski'   - Minkowski distance. Default is
%                                 NS.DistParameter if NS.Distance is
%                                 'minkowski', or 2 otherwise. To specify a
%                                 different exponent, use the 'P' argument.
%                 'mahalanobis' - Mahalanobis distance, computed using a
%                                 positive definite covariance matrix C.
%                                 Default is NS.DistParameter if
%                                 NS.Distance is 'mahalanobis', or
%                                 NANCOV(X) otherwise. To specify another
%                                 value for C, use the 'Cov' argument.
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
%                  function     - A distance function specified using @
%                                 (for example @DISTFUN). A distance
%                                 function must be of the form:
%
%                                 function D2 = DISTFUN(ZI, ZJ),
%
%                                 taking as arguments a 1-by-N vector ZI
%                                 containing a single row of X or Y, and an
%                                 M2-by-N matrix ZJ containing multiple
%                                 rows of X or Y, and returning an M2-by-1
%                                 vector of distances D2, whose Jth element
%                                 is the distance between the observations
%                                 ZI and ZJ(J,:).
%
%     'P'         A positive scalar P indicating the exponent for Minkowski
%                 distance. This argument is only valid when KNNSEARCH uses
%                 the 'minkowski' distance metric. Default is
%                 NS.DistParameter if NS.Distance is 'minkowski', or 2
%                 otherwise.
%
%     'Cov'       A positive definite matrix indicating the covariance
%                 matrix when computing the Mahalanobis distance. This
%                 argument is only valid when KNNSEARCH uses the
%                 'mahalanobis' distance metric. Default is
%                 NS.DistParameter if NS.Distance is 'mahalanobis', or
%                 NANCOV(X) otherwise.
%
%     'Scale'     A vector S containing non-negative values, with length
%                 equal to the number of columns in X. Each coordinate
%                 difference between X and a query point is scaled by the
%                 corresponding element of S when computing the
%                 standardized Euclidean distance. This argument is only
%                 valid when 'Distance' is 'seuclidean'. Default is
%                 NS.DistParameter if NS.Distance is 'seuclidean', or
%                 NANSTD(X) otherwise.
%
%   Example:
%      % Create an ExhaustiveSearcher object for data X with the cosine 
%      % distance. The kd-tree method does not support nearest neighbors 
%      % search for the cosine distance, therefore CREATENS creates an
%      % ExhaustiveSearcher object.
%      X = randn(100,5);
%      Y = randn(25,5);
%      ns = createns(X, 'distance', 'cosine');
%
%      % Find 5 nearest neighbors in X for each point in Y
%      idx = knnsearch(ns,Y,'k',5);
%
%      % Choose a different distance metric from the one used when creating
%      % this ExhaustiveSearcher object
%      idx2 = knnsearch(ns,Y,'k',5, 'distance','correlation');
%
%   See also KNNSEARCH, ExhaustiveSearcher, CREATENS.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:18:42 $

if nargin < 2
    error('stats:ExhaustiveSearcher:knnsearch:TooFewInputs',...
        'Two input arguments are required.');
end

[~,nDims] = size(obj.X);
[~,nDims2]= size(Y);

if nDims2 ~= nDims
    error('stats:ExhaustiveSearcher:knnsearch:SizeMisMatch',...
        'Y must be a matrix with %d columns.', nDims);
end

pnames = { 'k'  'distance'  'p', 'cov', 'scale'};
dflts =  { 1    []           []   []     []   };
[eid,errmsg,numNN,distMetric, minExp, mahaCov, seucInvWgt] = ...
    internal.stats.getargs(pnames, dflts, varargin{:});
if ~isempty(eid)
    error(sprintf('stats:ExhaustiveSearcher:knnsearch:%s',eid),errmsg);
end

if isempty(distMetric)
      distMetric = obj.Distance;
elseif ischar(distMetric)
     methods = {'euclidean'; 'seuclidean'; 'cityblock'; 'chebychev'; ...
        'mahalanobis'; 'minkowski'; 'cosine'; 'correlation'; ...
        'spearman'; 'hamming'; 'jaccard'};
    i =  find(strncmpi(distMetric, methods, length(distMetric)));
    if length(i) > 1
        error('stats:ExhaustiveSearcher:knnsearch:BadDistance',...
            'Ambiguous Distance argument:  %s.', distMetric);
    elseif isempty(i)
        error('stats:ExhaustiveSearcher:knnsearch:UnrecognizedDistance',...
            'Unrecognized Distance argument: %s.', distMetric);
    else
        distMetric = methods{i};
    end

end

arg ={};
if ischar(distMetric)
 
    checkExtraArg(distMetric,minExp,seucInvWgt,mahaCov);
    
    switch distMetric(1:3)
        case 'min'
            if  isempty(minExp) && ~isempty(obj.DistParameter) && ....
                    strncmp(obj.Distance,'minkowski',3)
                minExp = obj.DistParameter;
            end
            arg = {minExp};

        case 'seu'
            if isempty(seucInvWgt) && ~isempty(obj.DistParameter) &&...
                    strncmp(obj.Distance,'seu',3)
                seucInvWgt = obj.DistParameter;
            end
            arg = {seucInvWgt};
            
        case 'mah'
            if isempty(mahaCov) && ~isempty(obj.DistParameter) &&...
                    strncmp(obj.Distance,'mah',3)
                mahaCov = obj.DistParameter;
            end
            arg = {mahaCov};
    end
    
else %no built-in distance
    checkExtraArg('userDist',minExp,seucInvWgt,mahaCov);
end

if nargout < 2
    [~,idx]  = pdist2(obj.X,Y, distMetric, arg{:}, 'smallest',numNN);
else
    [dist,idx] = pdist2(obj.X,Y, distMetric, arg{:}, 'smallest',numNN);
end


idx = idx';

if nargout > 1
    dist = dist';
end
end %method knnsearch

%Give an error if an extra input is provided
function checkExtraArg(distMetric,minExp,seucInvWgt,mahaCov)
if ~isempty(minExp) && ~strncmp(distMetric,'min',3)
    error('stats:ExhaustiveSearcher:knnsearch:InvalidMinExp',...
         'The P argument is only valid for ''minkowski'' distance metric.');
end
if ~isempty(seucInvWgt) && ~strncmp(distMetric,'seu',3)
    error('stats:ExhaustiveSearcher:knnsearch:InvalidSeucInvWgt',...
        'The Scale argument is only valid for ''seuclidean'' distance metric.');
end
if ~isempty(mahaCov) && ~strncmp(distMetric,'mah',3)
    error('stats:ExhaustiveSearcher:knnsearch:InvalidMahaCov',...
        'The Cov argument is only valid for ''mahalanobis'' distance metric.');
end

end


