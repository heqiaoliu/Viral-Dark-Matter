function [idx,dist]=knnsearch(obj,Y,varargin)
%KNNSEARCH Find K nearest neighbors using a KDTreeSearcher object.
%   IDX = KNNSEARCH(NS,Y) finds the nearest neighbor (closest point) in
%   NS.X for each point in Y. Rows of Y correspond to observations and
%   columns correspond to variables. Y must have the same number of columns
%   as NS.X. IDX is a column vector with NY rows, where NY is the number
%   of rows in Y. Each row in IDX contains the index of the observation in
%   NS.X that has the smallest distance to the corresponding observation
%   in Y.
%
%   [IDX, D] = KNNSEARCH(NS,Y) returns a column vector D containing the
%   distances between each observation in Y and its corresponding closest
%   observation in NS.X. That is, D(I) is the distance between
%   NS.X(IDX(I),:) and Y(I,:).
%
%   [IDX, D] = KNNSEARCH(NS,Y,'NAME1',VALUE1,...,'NAMEN',VALUEN)
%   specifies optional argument name/value pairs:
%
%     Name        Value
%     'K'         A positive integer, K, specifying the number of nearest
%                 nearest neighbors in NS.X to find for each point in Y.
%                 Default is 1. IDX and D are NY-by-K matrices. D sorts the
%                 distances in each row in ascending order. Each row in IDX
%                 contains the indices of K closest neighbors in X
%                 corresponding to the K smallest distances in D.
%
%    'Distance'   A string specifying the distance metric. The value can be
%                 one of the following:
%                   'euclidean'   - Euclidean distance
%                   'cityblock'   - City Block distance
%                   'chebychev'   - Chebychev distance (maximum coordinate
%                                   difference)
%                   'minkowski'   - Minkowski distance
%                 Default is NS.Distance
%
%    'P'          A positive scalar indicating the exponent of Minkowski
%                 distance. This argument is only valid when KNNSEARCH uses
%                 the 'minkowski' distance metric. Default is
%                 NS.DistParameter if NS.Distance is 'minkowski', or 2
%                 otherwise.
%
%   Example:
%      % Create a KDTreeSearcher object for data X with the 'euclidean' 
%      % distance:
%      X = randn(100,5);
%      ns = createns(X,'nsmethod','kdtree');
%
%      % Find 5 nearest neighbors in X and the corresponding distance
%      % values for each point in Y:
%      Y = randn(25, 5);
%      [idx, dist] = knnsearch(ns,Y,'k',5);
%
%  See also KNNSEARCH, KDTreeSearcher, CREATENS.
  
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2010/03/16 00:18:44 $

if nargin < 2
    error('stats:KDTreeSearcher:knnsearch:TooFewInputs',...
        'Two input arguments are required.');
end

[nX,nDims] = size(obj.X);
[nY,nDims2]= size(Y);

if nDims2 ~= nDims
    error('stats:KDTreeSearcher:knnsearch:SizeMisMatch',...
        'Y must be a matrix with %d columns.', nDims);
end

pnames = { 'k'  'distance', 'p'  };
dflts =  { 1    []          []  };
[eid,errmsg,numNN,distMetric, minExp] = ...
    internal.stats.getargs(pnames, dflts, varargin{:});
if ~isempty(eid)
    error(sprintf('stats:KDTreeSearcher:knnsearch:%s',eid),errmsg);
end

if ~isscalar(numNN) || ~isnumeric(numNN) ||  ...
        numNN <1 || numNN~=round(numNN)
    error('stats:KDTreeSearcher:knnsearch:BadK',...
        'K must be a positive integer specifying the number of neighbors.');
end

if ~isempty(distMetric)
    if ischar(distMetric)
        methods = {'euclidean'; 'cityblock'; 'chebychev'; ...
            'minkowski'};
        i = find(strncmpi(distMetric, methods, length(distMetric)));
        if length(i) > 1
            error('stats:KDTreeSearcher:knnsearch:BadDistance',...
                'Ambiguous Distance argument:  %s.', distMetric);
        elseif isempty(i)
            error('stats:KDTreeSearcher:knnsearch:UnrecognizedDistance',...
                'Unrecognized Distance argument for a KDTreeSearcher object: %s.', distMetric);
        else
            distMetric = methods{i};
        end
    else
        error('stats:KDTreeSearcher:knnsearch:BadDistance',...
            'The Distance argument must be a string.');
    end
else
    distMetric = obj.Distance; % use the default distance saved in obj.dist
end

if strncmp(distMetric,'min',3) % 'minkowski'
    if  ~isempty(minExp)
        if ~(isscalar(minExp) && isnumeric(minExp) && minExp > 0 )
            error('stats:KDTreeSearcher:knnsearch:BadMinExp', ...
                'The P argument for the Minkowski must be a positive scalar.')
        end
    elseif strncmp(obj.Distance,'minkowski',3) && ...
            ~isempty(obj.DistParameter)
        minExp = obj.DistParameter;
    else
        minExp = 2;
    end
else% 'euclidean', 'cityblock' or 'chebychev' distance
    if ~isempty(minExp)
        error('stats:KDTreeSearcher:knnsearch:InvalidMinExp',...
            'The P argument is only valid for ''minkowski'' distance metric.');
    end
    switch distMetric(1:3)
        case 'euc'
            minExp = 2;
        case 'cit'
            minExp = 1;
        case 'che'
            minExp = inf;
    end
end


% Integer/logical/char/anything data will be converted to float. Complex
% floating point data can't be handled.

try
    outClass = superiorfloat(obj.X,Y);
catch
    outClass = class(obj.X);
    warning('stats:KDTreeSearcher:knnsearch:DataConversion', ...
        'Converting non-floating Y data point to %s.',outClass);
end

Y = cast(Y,outClass);
if ~strcmp(outClass, class(obj.X))
    %only happens when X is double and Y is single
    X2 = cast(obj.X, outClass)';
else
    X2 = obj.X';
end

if ~isreal(Y)
    error('stats:KDTreeSearcher:knnsearch:ComplexData', ...
        'Complex data is not allowed.');
end

if issparse(Y)
    warning('stats:KDTreeSearcher:knnsearch:DataConversion', ...
        'Converting sparse data to full data.');
    Y = full(Y);
end

numNN = min(numNN,nX);
% Degenerate case, just return an empty of the proper size.
if (nY == 0 || numNN ==0)
    idx = zeros(nY, numNN,outClass);
    dist = zeros(nY, numNN, outClass);
    return;
end

numNN2 = min(numNN, obj.nx_nonan);
wasNaNY= any(isnan(Y),2);

if numNN2 > 0
    if nargout < 2
        idx = knnsearchmex(X2, Y', numNN2, minExp, obj.cutDim, obj.cutVal, ...
            obj.lowerBounds', obj.upperBounds',obj.leftChild, obj.rightChild, ...
            obj.leafNode,obj.idx,wasNaNY);
    else
        [idx, dist]= knnsearchmex(X2, Y',numNN2,minExp, obj.cutDim, obj.cutVal, ...
            obj.lowerBounds', obj.upperBounds',obj.leftChild, obj.rightChild, ...
            obj.leafNode, obj.idx,wasNaNY);
        dist = dist';
    end
   
    idx = idx';
else %The number of points with non-NaN values in X is zero
    idx = zeros(nY,0,outClass);
    if nargout >= 2
        dist = zeros(nY,0,outClass);
    end
end

numDiff = numNN - numNN2;
if numDiff > 0
    nanIdx = obj.wasnanIdx(1:numDiff);
    idx = [idx repmat(nanIdx,[nY,1])];
    if any(wasNaNY)
        idx(wasNaNY,numNN2+1:numNN) = numNN2+1:numNN;
    end
    if nargout >= 2
        dist = [dist nan(nY,numDiff)];
    end
end