function [ranked,weight] = relieff(X,Y,K,varargin)
%RELIEFF Importance of attributes (predictors) using ReliefF algorithm.
%   [RANKED,WEIGHT] = RELIEFF(X,Y,K) computes ranks and weights of
%   attributes (predictors) for input data matrix X and response vector Y
%   using ReliefF algorithm for classification or RReliefF for regression
%   with K nearest neighbors. For classification, RELIEFF uses K nearest
%   neighbors per class. RANKED are indices of columns in X ordered by
%   attribute importance. WEIGHT are attribute weights ranging from -1 to 1
%   with large positive weights assigned to important attributes.
%
%   If Y is numeric, RELIEFF by default performs RReliefF analysis for
%   regression. If Y is categorical, logical, a character array, or a cell
%   array of strings, RELIEFF by default performs ReliefF analysis for
%   classification.
%
%   Attribute ranks and weights computed by RELIEFF usually depend on K. If
%   you set K to 1, the estimates computed by RELIEFF can be unreliable for
%   noisy data. If you set K to a value comparable with the number of
%   observations (rows) in X, RELIEFF can fail to find important
%   attributes. You can start with K=10 and investigate the stability and
%   reliability of RELIEFF ranks and weights for various values of K.
%
%   [RANKED,WEIGHT] = RELIEFF(X,Y,K,'PARAM1',val1,'PARAM2',val2,...)
%   specifies optional parameter name/value pairs:
%
%       'method'         - Either 'regression' (default if Y is numeric) or
%                          'classification' (default if Y is not numeric).
%       'prior'          - Prior probabilities for each class, specified as
%                          a string ('empirical' or 'uniform') or as a
%                          vector (one value for each distinct group name)
%                          or as a structure S with two fields:  S.group
%                          containing the group names as a categorical
%                          variable, character array, or cell array of
%                          strings; and S.prob containing a vector of
%                          corresponding probabilities. If the input value
%                          is 'empirical' (default), class probabilities
%                          are determined from class frequencies in Y. If
%                          the input value is 'uniform', all class
%                          probabilities are set equal.
%       'updates'        - Number of observations to select at random for
%                          computing the weight of every attribute. By
%                          default all observations are used.
%       'categoricalx'   - 'on' or 'off', 'off' by default. If 'on', treat
%                          all predictors in X as categorical. If 'off',
%                          treat all predictors in X as numerical. You
%                          cannot mix numerical and categorical predictors.
%       'sigma'          - Distance scaling factor. For observation I,
%                          influence on the attribute weight from its
%                          nearest neighbor J is multiplied by
%                          exp((-rank(I,J)/SIGMA)^2), where rank(I,J) is
%                          the position of J in the list of nearest
%                          neighbors of I sorted by distance in the
%                          ascending order. Default is Inf (all nearest
%                          neighbors have the same influence) for
%                          classification and 50 for regression.
%
% See also KNNSEARCH, PDIST2.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2.2.1 $

% Check number of required arguments
if nargin<3
    error('stats:relieff:TooFewInputs',...
        'At least 3 input arguments are required.');
end

% Check if the predictors in X are of the right type
if ~isnumeric(X)
    error('stats:relieff:BadX','You must supply numeric X.');
end

% Parse input arguments
validArgs = {'method' 'prior' 'updates'   'categoricalx' 'sigma'};
defaults  = {      ''      []     'all'            'off'      []};

% Get optional args
[eid,emsg,method,prior,numUpdates,categoricalX,sigma] ...
    = internal.stats.getargs(validArgs,defaults,varargin{:});
if ~isempty(emsg)
    error(sprintf('stats:relieff:%s',eid),emsg);
end

% Classification or regression?
isRegression = [];
if ~isempty(method)
    if ~ischar(method) || ...
            isempty(strmatch(lower(method),{'regression' 'classification'}))
        error('stats:relieff:BadMethod',...
            'You must supply method as either ''classification'' or ''regression''.');
    end
    method = lower(method);
    if ~isempty(strmatch(method,'regression'))
        isRegression = true;
    else
        isRegression = false;
    end
end

% Check the type of Y
if isnumeric(Y)
    if isempty(isRegression)
        isRegression = true;
    end
elseif iscellstr(Y) || ischar(Y) || isa(Y,'categorical') || islogical(Y)
    if     isempty(isRegression)
        isRegression = false;
    elseif isRegression
        error('stats:relieff:BadYTypeForClass',...
            'You cannot run regression analysis on categorical Y.');
    end
else
    error('stats:relieff:BadYType',...
        'You must provide Y as a numeric, categorical, or logical vector, or a cell array of strings, or a character matrix.');
end

% Reject prior for regression
if isRegression && ~isempty(prior)
    error('stats:relieff:NoPriorForRegression',...
        'You cannot supply prior class probabilities for regression.');
end

% Check if the input sizes are consistent
if (~ischar(Y) && length(Y)~=size(X,1)) ...
        || (ischar(Y) && size(Y,1)~=size(X,1)) 
    error('stats:relieff:XYSizeMismatch', ...
        'X must have as many rows as there are elements in Y.');
end

% Prepare data for classification or regression
if isRegression
    [X,Y] = removeNaNs(X,Y);
    
else % Group Y for classification. Get class counts and probabilities.
    % Get groups and matrix of class counts
    if isa(Y,'categorical')
        Y = droplevels(Y);
    end
    [Y,grp] = grp2idx(Y);
    [X,Y] = removeNaNs(X,Y);
    Ngrp = numel(grp);
    N = size(X,1);
    C = false(N,Ngrp);
    C(sub2ind([N Ngrp],(1:N)',Y)) = true;
    
    % Get class probs
    if isempty(prior) || strcmpi(prior,'empirical')
        classProb = sum(C,1);
    elseif strcmpi(prior,'uniform')
        classProb = ones(1,Ngrp);
    elseif isstruct(prior)
        if ~isfield(prior,'group') || ~isfield(prior,'prob')
            error('stats:relieff:PriorWithMissingField',...
                'Missing field in structure value for input prior probabilities.');
        end
        if iscell(prior.group)
            usrgrp = prior.group;
        else
            usrgrp = cellstr(prior.group);
        end
        [tf,pos] = ismember(grp,usrgrp);
        if any(~tf)
            error('stats:relieff:PriorWithClassNotFound',...
                'Missing prior probability for class %s.',grp{find(~tf,1)});
        end
        classProb = prior.prob(pos);
    elseif isnumeric(prior)
        if ~isfloat(prior) || length(prior)~=Ngrp || any(prior<0) || all(prior==0)
            error('stats:relieff:BadNumericPrior',...
                'Prior probabilities must be a float or double vector of %i non-negative elements with at least one positive value.',Ngrp);
        end
        classProb = prior;
    else
        error('stats:relieff:BadPrior',...
            'You must supply prior either as a string ''empirical'' or ''uniform'' or as a numeric vector or as a struct.');
    end
    
    % Normalize class probs
    classProb = classProb/sum(classProb);
    
    % If there are classes with zero probs, remove them
    zeroprob = classProb==0;
    if any(zeroprob)
        t = zeroprob(Y);
        if sum(t)==length(Y)
            error('stats:relieff:ZeroWeightPrior',...
                'The vector of prior probabilities assigns all probability to unobserved classes.');
        end
        Y(t) = [];
        X(t,:) = [];
        C(t,:) = [];
        C(:,zeroprob) = [];
        classProb(zeroprob) = [];
    end
end

% Do we have enough observations?
if length(Y)<2
    error('stats:relieff:NotEnoughObs',...
        'You need to supply at least 2 valid observations.');
end

% Check the number of nearest neighbors
if ~isnumeric(K) || ~isscalar(K) || K<=0
    error('stats:relieff:BadK',...
        'You must supply K as a numeric positive scalar.');
end
K = ceil(K);

% Check number of updates
if (~ischar(numUpdates) || ~strcmpi(numUpdates,'all')) && ...
        (~isnumeric(numUpdates) || ~isscalar(numUpdates) || numUpdates<=0)
    error('stats:relieff:BadNumUpdates',...
        'You must supply ''updates'' either as a string ''all'' or as a numeric positive scalar.');
end
if ischar(numUpdates)
    numUpdates = size(X,1);
else
    numUpdates = ceil(numUpdates);
end

% Check the type of X
if ~ischar(categoricalX) || ...
        (~strcmpi(categoricalX,'on') && ~strcmpi(categoricalX,'off'))
    error('stats:relieff:BadCategoricalX',...
        'You must supply ''categoricalx'' as either ''off'' or ''on''.');
end
categoricalX = strcmpi(categoricalX,'on');

% Check sigma
if ~isempty(sigma) && ...
        (~isnumeric(sigma) || ~isscalar(sigma) || sigma<=0)
    error('stats:relieff:BadSigma',...
        'You must supply ''sigma'' as a numeric positive scalar.');
end
if isempty(sigma)
    if isRegression
        sigma = 50;
    else
        sigma = Inf;
    end
end

% The # updates cannot be more than the # observations
numUpdates = min(numUpdates, size(X,1));

% Choose the distance function depending upon the categoricalX
if ~categoricalX
    distFcn = 'cityblock';
else
    distFcn = 'hamming';
end

% Find max and min for every predictor
p = size(X,2);
Xmax = max(X);
Xmin = min(X);
Xdiff = Xmax-Xmin;

% Exclude single-valued attributes
isOneValue = Xdiff < eps(Xmax);
if all(isOneValue)
    ranked = 1:p;
    weight = NaN(1,p);
    return;
end
X(:,isOneValue) = [];
Xdiff(isOneValue) = [];
rejected = find(isOneValue);
accepted = find(~isOneValue);

% Scale and center the attributes
if ~categoricalX
    X = bsxfun(@rdivide,bsxfun(@minus,X,mean(X)),Xdiff);
end

% Get appropriate distance function in one dimension.
% thisx must be a row-vector for one observation.
% x can have more than one row.
if ~categoricalX
    dist1D = @(thisx,x) cityblock(thisx,x);
else
    dist1D = @(thisx,x) hamming(thisx,x);
end

% Call ReliefF. By default all weights are set to NaN.
weight = NaN(1,p);
if ~isRegression
    weight(accepted) = RelieffClass(X,C,classProb,numUpdates,K,distFcn,dist1D,sigma);
else
    weight(accepted) =   RelieffReg(X,Y,          numUpdates,K,distFcn,dist1D,sigma);
end

% Assign ranks to attributes
[~,sorted] = sort(weight(accepted),'descend');
ranked = accepted(sorted);
ranked(end+1:p) = rejected;



% -------------------------------------------------------------------------
function attrWeights = RelieffClass(scaledX,C,classProb,numUpdates,K,...
    distFcn,dist1D,sigma)
% ReliefF for classification

[numObs,numAttr] = size(scaledX);
attrWeights = zeros(1,numAttr);
Nlev = size(C,2);

% Choose the random instances
rndIdx = randsample(numObs,numUpdates);
idxVec = (1:numObs)';

% Make searcher objects, one object per class. 
searchers = cell(Nlev,1);
for c=1:Nlev
    searchers{c} = createns(scaledX(C(:,c),:),'Distance',distFcn);
end

% Outer loop, for updating attribute weights iteratively
for i = 1:numUpdates
    thisObs = rndIdx(i);
    
    % Choose the correct random observation
    selectedX = scaledX(thisObs,:);

    % Find the class for this observation
    thisC = C(thisObs,:);
    
    % Find the k-nearest hits 
    sameClassIdx = idxVec(C(:,thisC));
    
    % we may not always find numNeighbor Hits
    lenHits = min(length(sameClassIdx)-1,K);

    % find nearest hits
    % It is not guaranteed that the first hit is the same as thisObs. Since
    % they have the same class, it does not matter. If we add observation
    % weights in the future, we will need here something similar to what we
    % do in ReliefReg.
    Hits = [];
    if lenHits>0
        idxH = knnsearch(searchers{thisC},selectedX,'K',lenHits+1);
        idxH(1) = [];
        Hits = sameClassIdx(idxH);
    end    
    
    % Process misses
    missClass = find(~thisC);
    Misses = [];
    
    if ~isempty(missClass) % Make sure there are misses!
        % Find the k-nearest misses Misses(C,:) for each class C ~= class(selectedX)
        % Misses will be of size (no. of classes -1)x(K)
        Misses = zeros(Nlev-1,min(numObs,K+1)); % last column has class index
        
        for mi = 1:length(missClass)
            
            % find all observations of this miss class
            missClassIdx = idxVec(C(:,missClass(mi)));
            
            % we may not always find K misses
            lenMiss = min(length(missClassIdx),K);
            
            % find nearest misses
            idxM = knnsearch(searchers{missClass(mi)},selectedX,'K',lenMiss);
            Misses(mi,1:lenMiss) = missClassIdx(idxM);
            
        end
        
        % Misses contains obs indices for miss classes, sorted by dist.
        Misses(:,end) = missClass;
    end
            
    %***************** ATTRIBUTE UPDATE *****************************
    % Inner loop to update weights for each attribute:
    
    for j = 1:numAttr
        dH = diffH(j,scaledX,thisObs,Hits,dist1D,sigma)/numUpdates;
        dM = diffM(j,scaledX,thisObs,Misses,dist1D,sigma,classProb)/numUpdates;
        attrWeights(j) = attrWeights(j) - dH + dM;
    end
    %****************************************************************
end


% -------------------------------------------------------------------------
function attrWeights = RelieffReg(scaledX,Y,numUpdates,K,distFcn,dist1D,sigma)
% ReliefF for regression

% Initialize the variables used to calculate the probabilities
% NdC : corresponds to the probability two nearest instances
% have different predictions.
% NdA(i) : corresponds to the probability that two nearest instances
% have different values for the attribute 'i'
% NdAdC(i) : corresponds to the probability that two nearest
% instances have different predictions, and different values for 'i'

[numObs,numAttr] = size(scaledX);
NdC = 0;
NdA = zeros(1,numAttr);
NdAdC = zeros(1,numAttr);

% Select 'numUpdates' random instances
rndIdx = randsample(numObs,numUpdates);

% Scale and center the response
% We need to do this for regression. 'y'-distance between instances
% is used to evaluate the attribute weights.
Ymax = max(Y);
Ymin = min(Y);
Y = bsxfun(@rdivide,bsxfun(@minus,Y,mean(Y)),Ymax-Ymin);

% How many neighbors can we find?
lenNei = min(numObs-1,K);

% The influences of neighbors decreases with their distance from
% the random instance. Calculate the weights that describe this
% decreasing influence. 
distWts = exp(-((1:lenNei)/sigma).^2)';
distWts = distWts/sum(distWts);

% Create NN searcher
searcher = createns(scaledX,'Distance',distFcn);

% Outer loop that iterates over the randomly chosen attributes
for i = 1:numUpdates
    thisObs = rndIdx(i);
    
    % Choose the correct random observation
    selectedX = scaledX(thisObs,:);
    
    % Find the k-nearest instances to the random instance
    idxNearest = knnsearch(searcher,selectedX,'K',lenNei+1);
    
    % Exclude this observation from the list of nearest neighbors if it is
    % there. If not, exclude the last one.
    tf = idxNearest==thisObs;
    if any(tf)
        idxNearest(tf) = [];
    else
        idxNearest(end) = [];
    end
    
    % Update NdC
    NdC = NdC + sum(abs(Y(thisObs)-Y(idxNearest)).*distWts);
    
    % Update NdA and NdAdC for each attribute
    for a = 1:numAttr
        vdiff = dist1D(scaledX(thisObs,a),scaledX(idxNearest,a));
        NdA(a) = NdA(a) + sum(vdiff.*distWts);
        NdAdC(a) = NdAdC(a) + ...
            sum( vdiff.*abs(Y(thisObs)-Y(idxNearest)).*distWts );
    end
end

attrWeights = NdAdC/NdC - (NdA-NdAdC)/(numUpdates-NdC);


%Helper functions for RelieffReg and RelieffClass

%--------------------------------------------------------------------------
% DIFFH (for RelieffClass): Function to calculate difference measure
% for an attribute between the selected instance and its hits

function distMeas = diffH(a,X,thisObs,Hits,dist1D,sigma)

% If no hits, return zero by default
if isempty(Hits)
    distMeas = 0;
    return;
end

% Get distance weights
distWts = exp(-((1:length(Hits))/sigma).^2)';
distWts = distWts/sum(distWts);

% Calculate weighted sum of distances
distMeas = sum(dist1D(X(thisObs,a),X(Hits,a)).*distWts);


%--------------------------------------------------------------------------
% DIFFM (for RelieffClass) : Function to calculate difference measure
% for an attribute between the selected instance and its misses
function distMeas = diffM(a,X,thisObs,Misses,dist1D,sigma,classProb)

distMeas = 0;

% If no misses, return zero
if isempty(Misses)
    return;
end

% Loop over misses
for mi = 1:size(Misses,1)
    
    ismiss = Misses(mi,1:end-1)~=0;
    
    if any(ismiss)
        cls = Misses(mi,end);
        nmiss = sum(ismiss);
        
        distWts = exp(-((1:nmiss)/sigma).^2)';
        distWts = distWts/sum(distWts);
        
        distMeas = distMeas + ...
            sum(dist1D(X(thisObs,a),X(Misses(mi,ismiss),a)).*distWts(1:nmiss)) ...
            *classProb(cls);
    end
end

% Normalize class probabilities.
% This is equivalent to P(C)/(1-P(class(R))) in ReliefF paper.
totProb = sum(classProb(Misses(:,end)));
distMeas = distMeas/totProb;


function [X,Y] = removeNaNs(X,Y)
% Remove observations with missing data
NaNidx = bsxfun(@or,isnan(Y),any(isnan(X),2));
X(NaNidx,:) = [];
Y(NaNidx,:) = [];


function d = cityblock(thisX,X)
d = abs(thisX-X);

function d = hamming(thisX,X)
d = thisX~=X;
