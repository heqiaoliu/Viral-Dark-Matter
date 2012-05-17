function [D,I] = pdist2(X,Y,dist,varargin)
%PDIST2 Pairwise distance between two sets of observations.
%   D = PDIST2(X,Y) returns a matrix D containing the Euclidean distances
%   between each pair of observations in the MX-by-N data matrix X and
%   MY-by-N data matrix Y. Rows of X and Y correspond to observations,
%   and columns correspond to variables. D is an MX-by-MY matrix, with the
%   (I,J) entry equal to distance between observation I in X and
%   observation J in Y. 
%
%   D = PDIST2(X,Y,DISTANCE) computes D using DISTANCE.  Choices are:
%
%       'euclidean'   - Euclidean distance (default)
%       'seuclidean'  - Standardized Euclidean distance. Each coordinate
%                       difference between rows in X and Y is scaled by
%                       dividing by the corresponding element of the
%                       standard deviation computed from X, S=NANSTD(X).
%                       To specify another value for S, use
%                       D = PDIST2(X,Y,'seuclidean',S).
%       'cityblock'   - City Block distance
%       'minkowski'   - Minkowski distance. The default exponent is 2. To
%                       specify a different exponent, use
%                       D = PDIST2(X,Y,'minkowski',P), where the
%                       exponent P is a scalar positive value.
%       'chebychev'   - Chebychev distance (maximum coordinate difference)
%       'mahalanobis' - Mahalanobis distance, using the sample covariance
%                       of X as computed by NANCOV.  To compute the
%                       distance with a different covariance, use
%                       D = PDIST2(X,Y,'mahalanobis',C), where the matrix C
%                       is symmetric and positive definite.
%       'cosine'      - One minus the cosine of the included angle
%                       between observations (treated as vectors)
%       'correlation' - One minus the sample linear correlation between
%                       observations (treated as sequences of values).
%       'spearman'    - One minus the sample Spearman's rank correlation
%                       between observations (treated as sequences of
%                       values)
%       'hamming'     - Hamming distance, percentage of coordinates
%                       that differ
%       'jaccard'     - One minus the Jaccard coefficient, the
%                       percentage of nonzero coordinates that differ
%       function      - A distance function specified using @, for example
%                       @DISTFUN
%
%   A distance function must be of the form
%
%         function D2 = DISTFUN(ZI,ZJ),
%
%   taking as arguments a 1-by-N vector ZI containing a single observation
%   from X or Y, an M2-by-N matrix ZJ containing multiple observations from
%   X or Y, and returning an M2-by-1 vector of distances D2, whose Jth
%   element is the distance between the observations ZI and ZJ(J,:).
%   
%   For built-in distance metrics, the distance between observation I in X
%   and observation J in Y will be NaN if observation I in X or observation
%   J in Y contains NaNs.
%
%   D = PDIST2(X,Y,DISTANCE,'Smallest',K) returns a K-by-MY matrix D
%   containing the K smallest pairwise distances to observations in X for
%   each observation in Y. PDIST2 sorts the distances in each column of D
%   in ascending order. D = PDIST2(X,Y,DISTANCE, 'Largest',K) returns the K
%   largest pairwise distances sorted in descending order. If K is greater
%   than MX, PDIST2 returns an MX-by-MY distance matrix. For each
%   observation in Y, PDIST2 finds the K smallest or largest distances by
%   computing and comparing the distance values to all the observations in
%   X.
%
%   [D,I] = PDIST2(X,Y,DISTANCE,'Smallest',K) returns a K-by-MY matrix I
%   containing indices of the observations in X corresponding to the K
%   smallest pairwise distances in D. [D,I] = PDIST2(X,Y,DISTANCE,
%   'Largest',K) returns indices corresponding to the K largest pairwise
%   distances.
%
%   Example:
%      % Compute the ordinary Euclidean distance
%      X = randn(100, 5);
%      Y = randn(25, 5);
%      D = pdist2(X,Y,'euclidean');         % euclidean distance
%
%      % Compute the Euclidean distance with each coordinate difference
%      % scaled by the standard deviation
%      Dstd = pdist2(X,Y,'seuclidean');
%
%      % Use a function handle to compute a distance that weights each
%      % coordinate contribution differently.
%      Wgts = [.1 .3 .3 .2 .1];            % coordinate weights
%      weuc = @(XI,XJ,W)(sqrt(bsxfun(@minus,XI,XJ).^2 * W'));
%      Dwgt = pdist2(X,Y, @(Xi,Xj) weuc(Xi,Xj,Wgts));
%
%   See also PDIST, KNNSEARCH, CREATENS, KDTreeSearcher,
%            ExhaustiveSearcher.

%   An example of distance for data with missing elements:
%
%      X = randn(100, 5);     % some random points
%      Y = randn(25, 5);      % some more random points
%      X(unidrnd(prod(size(X)),1,20)) = NaN; % scatter in some NaNs
%      Y(unidrnd(prod(size(Y)),1,5)) = NaN; % scatter in some NaNs
%      D = pdist2(X, Y, @naneucdist);
%
%      function D = naneucdist(XI, YJ) % euclidean distance, ignoring NaNs
%      [m,p] = size(YJ);
%      sqdxy = bsxfun(@minus,XI,YJ) .^ 2;
%      pstar = sum(~isnan(sqdxy),2); % correction for missing coordinates
%      pstar(pstar == 0) = NaN;
%      D = sqrt(nansum(sqdxy,2) .* p ./ pstar);
%
%
%   For a large number of observations, it is sometimes faster to compute
%   the distances by looping over coordinates of the data (though the code
%   is more complicated):
%
%      function D = nanhamdist(XI, YJ) % hamming distance, ignoring NaNs
%      [m,p] = size(YJ);
%      nesum = zeros(m,1);
%      pstar = zeros(m,1);
%      for q = 1:p
%          notnan = ~(isnan((XI(q)) | isnan(YJ(:,q)));
%          nesum = nesum + (XI(q) ~= YJ(:,q)) & notnan;
%          pstar = pstar + notnan;
%      end
%      D = nesum ./ pstar;

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2010/03/16 00:16:42 $

if nargin < 2
    error('stats:pdist2:TooFewInputs',...
        'Requires at least two input arguments.');
end

[nx,p] = size(X);
[ny,py] = size(Y);
if py ~= p
    error('stats:pdist2:SizeMismatch', ...
        'X and Y must have the same number of columns.');
end

additionalArg = [];

if nargin < 3
    dist = 'euc';
else %distance is provided
    if ischar(dist)
        methods = {'euclidean'; 'seuclidean'; 'cityblock'; 'chebychev'; ...
            'mahalanobis'; 'minkowski'; 'cosine'; 'correlation'; ...
            'spearman'; 'hamming'; 'jaccard'};
        i = find(strncmpi(dist, methods, length(dist)));
        if length(i) > 1
            error('stats:pdist2:BadDistance',...
                'Ambiguous ''DISTANCE'' argument:  %s.', dist);
        elseif isempty(i)
            error('stats:pdist2:UnrecognizedDistance',...
                'Unrecognized ''DISTANCE'' argument: %s.', dist);
        else
            dist = methods{i}(1:3);
            
            if ~isempty(varargin)
                arg = varargin{1};
                
                % Get the additional distance argument from the inputs
                if isnumeric(arg)
                    switch dist
                        case {'seu' 'mah' 'min'}
                            additionalArg = arg;
                            varargin = varargin(2:end);
                    end
                end
            end
        end
    elseif isa(dist, 'function_handle')
        distfun = dist;
        dist = 'usr';
    else
        error('stats:pdist2:BadDistance',...
            'The ''DISTANCE'' argument must be a string or a function.');
    end
end

pnames = {'smallest' 'largest'};
dflts =  {        []        []};
[eid,errmsg,smallest,largest] = internal.stats.getargs(pnames, dflts, varargin{:});
if ~isempty(eid)
    error(sprintf('stats:pdist2:%s',eid),errmsg);
end
if ~isempty(smallest)
    if ~isempty(largest)
        error('stats:pdist2:SmallestAndLargest', ...
            'SMALLEST and LARGEST must not be specified together.');
    end
    if ~(isscalar(smallest) && isnumeric(smallest) && smallest >= 1 && round(smallest) == smallest)
        error('stats:pdist2:BadSmallest', ...
            'SMALLEST must be a positive integer.')
    end
    smallestLargestFlag = min(smallest,nx);
elseif ~isempty(largest)
    if ~(isscalar(largest) && isnumeric(largest) && largest >= 1 && round(largest) == largest)
        error('stats:pdist2:BadSmallest', ...
            'LARGEST must be a positive integer.')
    end
    smallestLargestFlag = -min(largest,nx);
else
    if nargout > 1
        error('stats:pdist2:TooManyOutputs', ...
            'SMALLEST or LARGEST must be specified to compute second output I.');
    end
    smallestLargestFlag = [];
end

% For a built-in distance, integer/logical/char/anything data will be
% converted to float. Complex floating point data can't be handled by
% a built-in distance function.
%if ~strcmp(dist,'usr')

try
    outClass = superiorfloat(X,Y);
catch
    if isfloat(X)
        outClass = class(X);
    elseif isfloat(Y)
        outClass = class(Y);
    else
        outClass = 'double';
    end
end

if ~strcmp(dist,'usr')
    if ~strcmp(class(X),outClass) || ~strcmp(class(Y),outClass)
        warning('stats:pdist2:DataConversion', ...
            'Converting non-floating point data to %s.',outClass);
    end
    X = cast(X,outClass);
    Y = cast(Y,outClass);
    if  ~isreal(X) || ~isreal(Y)
        error('stats:pdist2:ComplexData', ...
            'PDIST2 does not accept complex data for built-in distances.');
    end
end

% Degenerate case, just return an empty of the proper size.
if (nx == 0) || (ny == 0)
    if ~isempty(smallestLargestFlag)
        nD = abs(smallestLargestFlag);
    else
        nD = nx;
    end
    D = zeros(nD,ny,outClass); % X and Y were single/double, or cast to double
    I = zeros(nD,ny,outClass);
    return;
end

switch dist
    case 'seu' % Standardized Euclidean weights by coordinate variance
        if isempty(additionalArg)
            additionalArg =  nanvar(X,[],1);
            if any(additionalArg == 0)
                warning('stats:pdist2:ConstantColumns',...
                    ['Some columns of X have zero standard deviation. ',...
                    'You may want to use other inverse weights or another distance metric. ']);
            end
            additionalArg = 1./ additionalArg;
        else
            if ~(isvector(additionalArg) && length(additionalArg) == p...
                    && all(additionalArg >= 0))
                error('stats:pdist2:InvalidWeights',...
                    ['The inverse Weights for the standardized Euclidean metric must be a vector of ', ...
                    'non-negative values, with length equal to the number of columns in X.']);
            end
            if any(additionalArg == 0)
                warning('stats:pdist2:ZeroInverseWeights',...
                    ['Some columns of the inverse weight for the standardized ',...
                    'Euclidean metric are zeros. ',...
                    'You may want to use other inverse weights or another distance metric. ']);
            end
            additionalArg = 1./ (additionalArg .^2);
        end
        
    case 'mah' % Mahalanobis
        if isempty(additionalArg)
            if nx == 1
                error('stats:pdist2:tooFewXRowsForMah',...
                    ['There must be more than one row in X to compute ',...
                    'the default covariance matrix for Mahalanobis metric.']);
                
            end
            additionalArg = nancov(X);
            [T,flag] = chol(additionalArg);
        else %provide the covariance for mahalanobis
            if ~isequal(size(additionalArg),[p,p])
                error('stats:pdist2:InvalidCov',...
                    ['The covariance matrix for the Mahalanobis metric must be a ',...
                    'square matrix with the same number of columns as X.']);
            end
            %cholcov will check whether the covariance is symmetric
            [T,flag] = cholcov(additionalArg,0); 
        end
       
        if flag ~= 0
                error('stats:pdist2:InvalidCov',...
                    ['The covariance matrix for the Mahalanobis metric must be symmetric ',...
                    'and positive definite.']);
        end
              
        if ~issparse(X) && ~issparse(Y)
             additionalArg = T \ eye(p); %inv(T) 
        end
        
    case 'min' % Minkowski
        if isempty(additionalArg)
            additionalArg = 2;
        elseif ~(isscalar(additionalArg) && additionalArg > 0)
            error('stats:pdist2:BadMinExp',...
                'The exponent for the Minkowski metric must be a positive scalar.');
        end
    case 'cos' % Cosine
        [X,Y,flag] = normalizeXY(X,Y);
        if flag
            warning('stats:pdist2:zeroPoints',...
                ['Some points in data have small relative magnitudes, making them ', ...
                'effectively zero. ',...
                'Cosine metric may not be appropriate for these points.']);
        end
        
    case 'cor' % Correlation
        X = bsxfun(@minus,X,mean(X,2));
        Y = bsxfun(@minus,Y,mean(Y,2));
        [X,Y,flag] = normalizeXY(X,Y);
        if flag
            warning('stats:pdist2:constantPoints',...
                ['Some points in data have small relative standard deviations, making them ', ...
                'effectively constant. ',...
                'Correlation metric may not be appropriate for these points.']);
        end
        
    case 'spe'
        X = tiedrank(X')'; % treat rows as a series
        Y = tiedrank(Y')';
        X = X - (p+1)/2; % subtract off the (constant) mean
        Y = Y - (p+1)/2;
        [X,Y,flag] = normalizeXY(X,Y);
        if flag
            warning('stats:pdist2:constantPoints',...
                ['Some points in data have too many ties, making them ', ...
                'effectively constant. ',...
                'Rank correlation metric may not be appropriate for these points.']);
        end
        
    otherwise
        
end

% Note that if the above switch statement is modified to include the
% 'che', 'euc', or 'cit' distances, that code may need to be repeated
% in the corresponding block below.
if strcmp(dist,'min') % Minkowski distance
    if isinf(additionalArg) %the exponent is inf
        dist = 'che';
        additionalArg = [];
    elseif additionalArg == 2 %the exponent is 2
        dist = 'euc';
        additionalArg = [];
    elseif additionalArg == 1 %the exponent is 1
        dist = 'cit';
        additionalArg = [];
    end
end

% Call a mex file to compute distances for the build-in distance measures
% on non-sparse real float (double or single) data.
if ~strcmp(dist,'usr') && (~issparse(X) && ~issparse(Y))
    additionalArg = cast(additionalArg,outClass);

    if nargout < 2
        D = pdist2mex(X',Y',dist,additionalArg,smallestLargestFlag);
    else
        [D,I] = pdist2mex(X',Y',dist,additionalArg,smallestLargestFlag);
    end
    
    % The following MATLAB code implements the same distance calculations as
    % the mex file. It assumes X and Y are real single or double.  It is
    % currently only called for sparse inputs, but it may also be useful as a
    % template for customization.
elseif ~strcmp(dist,'usr')
    if strmatch(dist, {'ham' 'jac' 'che'})
        xnans = any(isnan(X),2);
        ynans = any(isnan(Y),2);
    end
    
    if isempty(smallestLargestFlag)
        D = zeros(nx,ny,outClass);
    elseif nargout < 2
        D = zeros(abs(smallestLargestFlag),ny,outClass);
    else
        D = zeros(abs(smallestLargestFlag),ny,outClass);
        I = zeros(abs(smallestLargestFlag),ny,outClass);       
    end
    
    switch dist
        case 'euc'    % Euclidean
            for i = 1:ny
                dsq = zeros(nx,1,outClass);
                for q = 1:p
                    dsq = dsq + (X(:,q) - Y(i,q)).^2;
                end
                if isempty(smallestLargestFlag)
                    D(:,i) = sqrt(dsq);
                elseif nargout < 2
                    D(:,i) = partialSort(sqrt(dsq),smallestLargestFlag);
                else
                   [D(:,i),I(:,i)] = partialSort(sqrt(dsq),smallestLargestFlag);
                end
            end
                        
        case 'seu'    % Standardized Euclidean
            wgts = additionalArg;
            for i = 1:ny
                dsq = zeros(nx,1,outClass);
                for q = 1:p
                    dsq = dsq + wgts(q) .* (X(:,q) - Y(i,q)).^2;
                end
                
                if isempty(smallestLargestFlag)
                    D(:,i) = sqrt(dsq);
                elseif nargout < 2
                   D(:,i) = partialSort(sqrt(dsq),smallestLargestFlag);
                else
                   [D(:,i),I(:,i)] = partialSort(sqrt(dsq),smallestLargestFlag);
                end
            end
            
        case 'cit'    % City Block
            for i = 1:ny
                dsq = zeros(nx,1,outClass);
                for q = 1:p
                    dsq = dsq + abs(X(:,q) - Y(i,q));
                end
                
                if isempty(smallestLargestFlag)
                    D(:,i) = dsq;
                else
                    temp = dsq;
                    if nargout < 2
                        D(:,i) = partialSort(temp,smallestLargestFlag);
                    else
                        [D(:,i),I(:,i)] = partialSort(temp,smallestLargestFlag);
                    end
                end
            end
            
        case 'mah'    % Mahalanobis
          
            for i = 1:ny
                del = bsxfun(@minus,X,Y(i,:));
                dsq = sum((del/T) .^ 2, 2);
                if isempty(smallestLargestFlag)
                    D(:,i) = sqrt(dsq);
                else
                    temp = sqrt(dsq);
                    if nargout < 2
                        D(:,i) = partialSort(temp,smallestLargestFlag);
                    else
                        [D(:,i),I(:,i)] = partialSort(temp,smallestLargestFlag);
                    end
                end
            end
            
        case 'min'    % Minkowski
            expon = additionalArg;
            for i = 1:ny
                dpow = zeros(nx,1,outClass);
                for q = 1:p
                    dpow = dpow + abs(X(:,q) - Y(i,q)).^expon;
                end
                
                if isempty(smallestLargestFlag)
                    D(:,i) = dpow .^ (1./expon);
                else
                    temp = dpow .^ (1./expon);
                    if nargout < 2
                        D(:,i) = partialSort(temp,smallestLargestFlag);
                    else
                        [D(:,i),I(:,i)] = partialSort(temp,smallestLargestFlag);
                    end
                end
            end
            
        case {'cos' 'cor' 'spe'}   % Cosine, Correlation, Rank Correlation
            % This assumes that data have been appropriately preprocessed
            for i = 1:ny
                d = zeros(nx,1,outClass);
                for q = 1:p
                    d = d + (X(:,q).*Y(i,q));
                end
                d(d>1) = 1; % protect against round-off, don't overwrite NaNs
                
                if isempty(smallestLargestFlag)
                    D(:,i) = 1 - d;
                else
                    temp = 1 - d;
                    if nargout < 2
                        D(:,i) = partialSort(temp,smallestLargestFlag);
                    else
                        [D(:,i),I(:,i)] = partialSort(temp,smallestLargestFlag);
                    end
                end
                
            end
        case 'ham'    % Hamming
            for i = 1:ny
                nesum = zeros(nx,1,outClass);
                for q = 1:p
                    nesum = nesum + (X(:,q) ~= Y(i,q));
                end
                nesum(xnans|ynans(i)) = NaN;
                
                if isempty(smallestLargestFlag)
                    D(:,i) = (nesum ./ p);
                else
                    temp = (nesum ./ p);
                    if nargout < 2
                        D(:,i) = partialSort(temp,smallestLargestFlag);
                    else
                        [D(:,i),I(:,i)] = partialSort(temp,smallestLargestFlag);
                    end
                end
            end
        case 'jac'    % Jaccard
            for i = 1:ny
                nzsum = zeros(nx,1,outClass);
                nesum = zeros(nx,1,outClass);
                for q = 1:p
                    nz = (X(:,q) ~= 0 | Y(i,q) ~= 0);
                    ne = (X(:,q) ~= Y(i,q));
                    nzsum = nzsum + nz;
                    nesum = nesum + (nz & ne);
                end
                nesum(xnans | ynans(i)) = NaN;
                
                if isempty(smallestLargestFlag)
                    D(:,i) = (nesum ./ nzsum);
                else
                    temp = (nesum ./ nzsum);
                    if nargout < 2
                        D(:,i) = partialSort(temp,smallestLargestFlag);
                    else
                        [D(:,i),I(:,i)] = partialSort(temp,smallestLargestFlag);
                    end
                end
            end
        case 'che'    % Chebychev
            for i = 1:ny
                dmax = zeros(nx,1,outClass);
                for q = 1:p
                    dmax = max(dmax, abs(X(:,q) - Y(i,q)));
                end
                dmax(xnans | ynans(i)) = NaN;
                
                if isempty(smallestLargestFlag)
                    D(:,i) =  dmax;
                else
                    temp = dmax;
                    if nargout < 2
                        D(:,i) = partialSort(temp,smallestLargestFlag);
                    else
                        [D(:,i),I(:,i)] = partialSort(temp,smallestLargestFlag);
                    end
                end
            end
    end
    
    % Compute distances for a caller-defined distance function.
else % if strcmp(dist,'usr')
    try
        D = feval(distfun,Y(1,:),X(1,:));
    catch ME
        if strcmp('MATLAB:UndefinedFunction', ME.identifier) ...
                && ~isempty(strfind(ME.message, func2str(distfun)))
            error('stats:pdist2:DistanceFunctionNotFound',...
                'The distance function ''%s'' was not found.', func2str(distfun));
        end
        % Otherwise, let the catch block below generate the error message
        D = [];
    end
    
    if ~isnumeric(D)
        error('stats:pdist2:OutputBadType',....
            'The output of distance function must be numeric.');
    end
    
    if isempty(smallestLargestFlag)
        % Make the return have whichever numeric type the distance function
        % returns.
        D = zeros(nx,ny,class(D));
        
        for i = 1:ny
            try
                D(:,i) = feval(distfun,Y(i,:),X);
                
            catch ME
                if isa(distfun, 'inline')
                    throw(addCause(MException('stats:pdist2:DistanceFunctionError',...
                        'Error evaluating inline distance function.'),...
                        ME));
                else
                    throw(addCause(MException('stats:pdist2:DistanceFunctionError',...
                        'Error evaluating distance function ''%s''.',...
                        func2str(distfun)),...
                        ME));
                end
            end
        end
    else % isempty(smallestLargestFlag)
        D = zeros(abs(smallestLargestFlag),ny,class(D));
        if nargout >= 2
            I = zeros(abs(smallestLargestFlag),ny,class(D));
        end
        
        for i = 1:ny
            
            try
                temp = feval(distfun,Y(i,:),X);
            catch ME
                if isa(distfun, 'inline')
                    throw(addCause(MException('stats:pdist2:DistanceFunctionError',...
                        'Error evaluating inline distance function.'),...
                        ME));
                else
                    throw(addCause(MException('stats:pdist2:DistanceFunctionError',...
                        'Error evaluating distance function ''%s''.',...
                        func2str(distfun)),...
                        ME));
                end
            end
            
            if nargout < 2
                D(:,i) = partialSort(temp,smallestLargestFlag);
            else
                [D(:,i),I(:,i)] = partialSort(temp,smallestLargestFlag);
            end
        end
        
    end
end

%---------------------------------------------
% Normalize the data matrices X and Y to have unit norm
function [X,Y,flag] = normalizeXY(X,Y)
Xmax = max(abs(X),[],2);
X2 = bsxfun(@rdivide,X,Xmax);
Xnorm = sqrt(sum(X2.^2, 2));

Ymax = max(abs(Y),[],2);
Y2 = bsxfun(@rdivide,Y,Ymax);
Ynorm = sqrt(sum(Y2.^2, 2));
% Find out points for which distance cannot be computed.

% The norm will be NaN for rows that are all zeros, fix that for the test
% below.
Xnorm(Xmax==0) = 0;
Ynorm(Ymax==0) = 0;

% The norm will be NaN for rows of X that have any +/-Inf. Those should be
% Inf, but leave them as is so those rows will not affect the test below.
% The points can't be normalized, so any distances from them will be NaN
% anyway.

% Find points that are effectively zero relative to the point with largest norm.
flag =  any(Xnorm <= eps(max(Xnorm))) || any(Ynorm <= eps(max(Ynorm)));
Xnorm = Xnorm .* Xmax;
Ynorm = Ynorm .* Ymax;
X = bsxfun(@rdivide,X,Xnorm);
Y = bsxfun(@rdivide,Y,Ynorm);


function [D,I] = partialSort(D,smallestLargest)
if smallestLargest > 0
    n = smallestLargest;
else
    %sort(D,'descend') puts the NaN values at the beginning of the sorted list.
    %That is not what we want here.
    D = D*-1;
    n = -smallestLargest;
end

if nargout < 2
    D = sort(D,1);
    D = D(1:n,:);
else
    [D,I] = sort(D,1);
    D = D(1:n,:);
    I = I(1:n,:);
end

if smallestLargest < 0
    D = D * -1;
end


