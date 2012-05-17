classdef ExhaustiveSearcher < NeighborSearcher
%ExhaustiveSearcher Nearest neighbor search object using exhaustive search.
%   An ExhaustiveSearcher object performs KNN (K-nearest-neighbor) search
%   using exhaustive search. You can create an ExhaustiveSearcher object
%   based on X using either of the following syntaxes:
%
%   CREATENS function:
%        NS = CREATENS(X,'NSMethod','exhaustive')
%   ExhaustiveSearcher constructor:
%        NS = ExhaustiveSearcher(X)
%
%   Rows of X correspond to observations and columns correspond to
%   variables. When one of the above methods creates an ExhaustiveSearcher
%   object, it saves X. The KNNSEARCH method computes the distance values
%   from all the points in X to the query points to find nearest neighbors.
%
%   ExhaustiveSearcher properties:
%       X               - Data used to create the object.
%       Distance        - The distance metric.
%       DistParameter   - The additional parameter for the distance metric.
%
%   ExhaustiveSearcher methods:
%       ExhaustiveSearcher - Construct an ExhaustiveSearcher object
%       knnsearch          - Find nearest neighbors for query points.
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
%  See also  CREATENS, KDTreeSearcher, STATS/KNNSEARCH.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:18:41 $
    

methods
    function obj = ExhaustiveSearcher(X,varargin)
%ExhaustiveSearcher Construct an ExhaustiveSearcher object.
%   NS = ExhaustiveSearcher(X,'NAME1',VALUE1,...,'NAMEN',VALUEN) creates
%   an ExhaustiveSearcher object, specifying the following optional
%   argument name/value pairs:
%
%     Name         Value
%     'Distance'   A string or a function handle specifying the default
%                  distance metric when you call the KNNSEARCH method.
%                  The value can be one of the following:
%                  'euclidean'   - Euclidean distance (default).
%                  'seuclidean'  - Standardized Euclidean distance. Each
%                                  coordinate difference between X and a
%                                  query point is scaled by dividing by a
%                                  scale value S. The default value
%                                  of S is the standard deviation computed
%                                  from X, S=NANSTD(X). To specify another
%                                  value for S, use the 'Scale' argument.
%                 'cityblock'   -  City Block distance.
%                 'chebychev'   -  Chebychev distance (maximum coordinate
%                                  difference).
%                 'minkowski'   -  Minkowski distance. The default exponent
%                                  is 2. To specify a different exponent,
%                                  use the 'P' argument.
%                 'mahalanobis' -  Mahalanobis distance, computed using a
%                                  positive definite covariance matrix C.
%                                  The default value of C is the sample
%                                  covariance matrix, as computed by
%                                  NANCOV(X). To specify another value for
%                                  C, use the 'COV' argument.
%                 'cosine'      -  One minus the cosine of the included
%                                  angle between observations (treated as
%                                  vectors).
%                 'correlation' -  One minus the sample linear
%                                  correlation between observations
%                                  (treated as sequences of values).
%                 'spearman'    -  One minus the sample Spearman's rank
%                                  correlation between observations
%                                  (treated as sequences of values).
%                 'hamming'     -  Hamming distance, percentage of
%                                  coordinates that differ.
%                 'jaccard'     -  One minus the Jaccard coefficient, the
%                                  percentage of nonzero coordinates that
%                                  differ.
%                  distance     -  A distance function specified using @
%                                  (for example @DISTFUN). A distance
%                                  function must be of the form:
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
%    'P'          A positive scalar indicating the exponent for Minkowski
%                 distance. This argument is only valid when 'Distance' is
%                 'minkowski'. Default is 2.
%
%    'Cov'        A positive definite matrix indicating the covariance
%                 matrix when computing the Mahalanobis distance. This
%                 argument is only valid when 'Distance' is 'mahalanobis'.
%                 Default is NANCOV(X).
%
%    'Scale'      A vector S containing non-negative values, with length
%                 equal to the number of columns in X. Each coordinate
%                 difference between X and a query point is scaled by the
%                 corresponding element of S when computing the
%                 standardized Euclidean distance. This argument is only
%                 valid when 'Distance' is 'seuclidean'. Default is
%                 NANSTD(X).
%
%   See also ExhaustiveSearcher, CREATENS.

        if nargin == 0
            error('stats:ExhaustiveSearcher:NoDataInput',...
                'At least one input is required');
        end
        pnames = {'distance'    'p'  'cov' 'scale'};
        dflts =  { 'euclidean'  []    []    []};
        
        [eid,errmsg,dist,minExp, mahaCov, seucInvWgt] = ...
            internal.stats.getargs(pnames, dflts, varargin{:});
        if ~isempty(eid)
            error(sprintf('stats:Searcher:ExhaustiveSearcher:%s',eid),errmsg);
        end
        
        if isempty(dist)
            dist = 'euclidean' ;
            obj.Distance = dist;
        elseif ischar(dist)
            distList = {'euclidean'; 'seuclidean'; 'cityblock'; 'chebychev'; ...
                'mahalanobis'; 'minkowski'; 'cosine'; 'correlation'; ...
                'spearman'; 'hamming'; 'jaccard'};
            i = find(strncmpi(dist, distList, length(dist)));
            if length(i) > 1
                error('stats:ExhaustiveSearcher:BadDistance',...
                    'Ambiguous Distance argument:  %s.', dist);
            elseif isempty(i)
                error('stats:ExhaustiveSearcher:UnrecognizedDistance',...
                    'Unrecognized Distance argument: %s.', dist);
            else
                dist = distList{i};
                obj.Distance = dist;
                
            end
        elseif isa(dist, 'function_handle')
             obj.Distance = dist;
        else
            error('stats:ExhaustiveSearcher:BadDistance',...
                'The Distance argument must be a string or a function handle.');
        end
        
        if strncmp(dist,'minkowski',3)
            if  ~isempty(minExp)
                if ~(isscalar(minExp) && isnumeric(minExp) && minExp > 0 )
                    error('stats:ExhaustiveSearcher:BadMinExp', ...
                        'The P argument must be a positive scalar.')
                end
                obj.DistParameter = minExp;
            else
                obj.DistParameter = 2;
            end
        elseif ~isempty(minExp)
            error('stats:ExhaustiveSearcher:InvalidMinExp',...
                'The P argument is only valid for the Minkowski distance metric.');
        end
        
        [nx, nDims]= size(X);
        if strncmp(dist,'seuclidean',3)
            if ~isempty(seucInvWgt)
                if ~(isvector(seucInvWgt) && length(seucInvWgt) == nDims...
                        && all(seucInvWgt >= 0))
                    error('stats:ExhaustiveSearcher:BadScale',...
                        ['Weights for the standardized Euclidean metric must be a vector of ', ...
                        'positive values, with length equal to the number of columns in X.']);
                end
                obj.DistParameter = seucInvWgt;
            else
                obj.DistParameter = nanstd(X,[],1);
            end
            
        elseif ~isempty(seucInvWgt)
            error('stats:ExhaustiveSearcher:InvalidScale',...
                ['The Scale argument is only valid for the ',...
                'standardized Euclidean distance metric.']);
        end
        
        if strncmp(dist, 'mahalanobis',3)
            if ~isempty(mahaCov)
                if ~isequal(size(mahaCov),[nDims,nDims])
                    error('stats:ExhaustiveSearcher:BadCov',...
                        ['The Cov argument must be a ',...
                        'square matrix with the same number of columns as X.']);
                end
                %use cholcov because we also need to check whether the matrix is symmetric
                [~,flag] = cholcov(mahaCov,0);
                if flag ~= 0
                    error('stats:ExhaustiveSearcher:BadCov',...
                        ['The Cov argument must be symmetric ',...
                        'and positive definite.']);
                end
                obj.DistParameter = mahaCov;
            else
                if nx == 1
                    error('stats:ExhaustiveSearcher:TooFewXRowsForMah',...
                        ['There must be more than one row in X to compute ',...
                        'the default covariance matrix for Mahalanobis metric.']);
                    
                end
                obj.DistParameter = nancov(X);
            end
        elseif ~isempty(mahaCov)
            error('stats:ExhaustiveSearcher:InvalidCov',...
                'The Cov argument is only valid for Mahalanobis distance metric.');
        end
        
        if ischar(dist) %  %built-in distance
            %Integer/logical/char/anything data will be converted to double.
            %Complex floating point data can't be handled by a built-in
            %distance function.
            
            if ~isfloat(X)
                warning('stats:ExhaustiveSearcher:DataConversion', ...
                    'Converting %s data to double.',class(X));
                X = double(X);
            end
            if ~isreal(X)
                error('stats:ExhaustiveSearcher:ComplexData', ...
                    'ExhaustiveSearcher does not accept complex data for built-in distance.');
            end
        end
        
        obj.X = X;
    end %  ExhaustiveSearcher constructor
    
    
end %for methods

end % classdef
