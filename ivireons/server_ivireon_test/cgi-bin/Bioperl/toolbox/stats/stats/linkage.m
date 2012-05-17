function Z = linkage(Y, method, pdistArg)
%LINKAGE Create hierarchical cluster tree.
%   Z = LINKAGE(X), where X is a matrix with two or more rows, creates a
%   matrix Z defining a tree of hierarchical clusters of the rows of X.
%   Clusters are based on the single linkage algorithm using Euclidean
%   distances between the rows of X. Rows of X correspond to observations
%   and columns to variables.
%
%   Z = LINKAGE(X,METHOD) creates a hierarchical cluster tree using the
%   the specified algorithm. The available methods are:
%
%      'single'    --- nearest distance (default)
%      'complete'  --- furthest distance
%      'average'   --- unweighted average distance (UPGMA) (also known as
%                      group average)
%      'weighted'  --- weighted average distance (WPGMA)
%      'centroid'  --- unweighted center of mass distance (UPGMC)
%      'median'    --- weighted center of mass distance (WPGMC)
%      'ward'      --- inner squared distance (min variance algorithm)
%
%   Z = LINKAGE(X,METHOD,METRIC) performs clustering based on the distance
%   metric METRIC between the rows of X. METRIC can be any of the distance
%   measures accepted by the PDIST function. The default is 'euclidean'.
%   For more information on PDIST and available distances, type HELP PDIST.
%   The centroid, median, and Ward's methods are intended only for the
%   Euclidean distance metric.
%
%   Z = LINKAGE(X, METHOD, PDIST_INPUTS) enables you to pass extra input
%   arguments to PDIST. PDIST_INPUTS should be a cell array containing
%   input arguments to be passed to PDIST.
%
%   Z = LINKAGE(Y) and Z = LINKAGE(Y,METHOD) are alternative syntaxes that
%   accept a vector representation Y of a distance matrix. Y may be a
%   distance matrix as computed by PDIST, or a more general dissimilarity
%   matrix conforming to the output format of PDIST.
%
%   The output matrix Z contains cluster information. Z has size m-1 by 3,
%   where m is the number of observations in the original data. Column 1
%   and 2 of Z contain cluster indices linked in pairs to form a binary
%   tree. The leaf nodes are numbered from 1 to m. They are the singleton
%   clusters from which all higher clusters are built. Each newly-formed
%   cluster, corresponding to Z(i,:), is assigned the index m+i, where m is
%   the total number of initial leaves. Z(i,1:2) contains the indices of
%   the two component clusters which form cluster m+i. There are m-1 higher
%   clusters which correspond to the interior nodes of the output
%   clustering tree. Z(i,3) contains the corresponding linkage distances
%   between the two clusters which are merged in Z(i,:), e.g. if there are
%   total of 30 initial nodes, and at step 12, cluster 5 and cluster 7 are
%   combined and their distance at this time is 1.5, then row 12 of Z will
%   be (5,7,1.5). The newly formed cluster will have an index 12+30=42. If
%   cluster 42 shows up in a latter row, that means this newly formed
%   cluster is being combined again into some bigger cluster.
%
%   The centroid and median methods can produce a cluster tree that is not
%   monotonic. This occurs when the distance from the union of two
%   clusters, r and s, to a third cluster is less than the distance between
%   r and s. In such a case, in a dendrogram drawn with the default
%   orientation, the path from a leaf to the root node takes some downward
%   steps. You may want to use another method when that happens.
%
%   You can provide the output Z to other functions including DENDROGRAM to
%   display the tree, CLUSTER to assign points to clusters, INCONSISTENT to
%   compute inconsistent measures, and COPHENET to compute the cophenetic
%   correlation coefficient.
%
%   Example: Compute four clusters of the Fisher iris data using Ward
%            linkage and ignoring species information, and see how the
%            cluster assignments correspond to the three species.
%
%       load fisheriris
%       Z = linkage(meas,'ward','euclidean');
%       c = cluster(Z,'maxclust',4);
%       crosstab(c,species)
%       dendrogram(Z)
%
%   See also PDIST, INCONSISTENT, COPHENET, DENDROGRAM, CLUSTER,
%   CLUSTERDATA, KMEANS, SILHOUETTE.

%   Copyright 1993-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $

% Check for size and type of input
[k, n] = size(Y);
m = ceil(sqrt(2*n)); % m = (1+sqrt(1+8*n))/2, but works for large n
if k>1  % data matrix input
    if nargin<2
        method = 'single';
    end
    if nargin<3
        pdistArg = 'euclidean';
    end
    nargs = 3;
else % distance matrix input or bad input
    nargs = nargin;
end

if nargs==3 % should be data input
    if k == 1 && m*(m-1)/2 == n
        warning('stats:linkage:CallingPDIST',...
                ['You have used the syntax to call PDIST from within LINKAGE, but the first ',...
                 'input argument to LINKAGE appears to be a distance matrix already.']);
    end
    if k < 2
        error('stats:linkage:TooFewDistances',...
              'You have to have at least two observations to do a linkage.');
    end
    callPdist = true;
    if ischar(pdistArg)
        pdistArg = {pdistArg};
    elseif ~iscell(pdistArg)
        error('stats:linkage:BadPdistArgs',...
              'Third input must be a string or a cell array.');
    end
else % should be distance input
    callPdist = false;
    if n < 1
        error('stats:linkage:TooFewDistances',...
              'You have to have at least one distance to do a linkage.');
    end
    if k ~= 1 || m*(m-1)/2 ~= n
        error('stats:linkage:BadSize',...
              'The first input does not appear to be a distance matrix because its size is not compatible with the output of the PDIST function. A data matrix input must have more than one row.');
    end
end

% Selects appropriate method
methods = {'single',   'nearest'; ...
           'complete', 'farthest'; ...
           'average',  'upgma'; ...
           'weighted', 'wpgma'; ...
           'centroid', 'upgmc'; ...
           'median',   'wpgmc'; ...
           'ward''s',  'incremental'};
if nargs == 1 % set default switch to be 'si'
    s = 1;
else
    s = find(strncmpi(method,methods,length(method)));
    if isempty(s)
        error('stats:linkage:BadMethod','Unknown method name: %s.',method);
    elseif length(s)>1
        error('stats:linkage:BadMethod','Ambiguous method name: %s.',method);
    else
        if s>size(methods,1), s = s - size(methods,1); end
    end
end
methodStr = methods{s};
method = methodStr(1:2);


% The recursive distance updates for these three methods only make sense
% when the distance matrix contains Euclidean distances (which will be
% squared) or the distance metric is Euclidean
if  ~isempty(strmatch(method,['ce';'me';'wa']))
    if ~callPdist
        if (any(~isfinite(Y)) || ~iseuclidean(Y))
            warning('stats:linkage:NotEuclideanMatrix',...
                '%s linkage specified with non-Euclidean dissimilarity matrix.',methodStr);
        end
    else
        nonEuc = false;
        if (~isempty(pdistArg))
            if (~ischar (pdistArg{1}))
                nonEuc = true;
            else
                distMethods = {'euclidean'; 'minkowski';'mahalanobis'; };
                %pdistArg{1} represents the distance metric
                i = strmatch(lower(pdistArg{1}), distMethods);
                if length(i) > 1
                    error('stats:linkage:BadDistance',...
                        'Ambiguous ''DISTANCE'' argument:  %s.', pdistArg{1});
                elseif (isempty(i) || i == 3 || ...
                  (i == 2 && length(pdistArg) ~= 1 && isscalar(pdistArg{2}) && pdistArg{2} ~= 2) )
                    nonEuc = true;
                end
            end
            
        end
        if (nonEuc)
            warning('stats:linkage:NotEuclideanMethod',...
                '%s linkage specified with non-Euclidean distance metric.',methodStr);
        end
    end
end

if exist('linkagemex','file')==3
    % call mex file
    if callPdist
        Z = linkagemex(Y,method,pdistArg);
    else
        Z = linkagemex(Y,method);
    end
else
    warning('stats:linkage:NoMexFilePresent',...
            '''mex'' file for linkage is not available, running ''m'' version.');
    if callPdist
        Y = pdist(Y,pdistArg{:});
    end
    % optional old linkage function (use if mex file is not present)
    Z = linkageold(Y,method);
end

% Check if the tree is monotonic and warn if not.  Z is built so that the rows
% are in non-decreasing height order, thus we can look at the heights in order
% to determine monotonicity, rather than having to explicitly compare each parent
% with its children.
zdiff = diff(Z(:,3));
if any(zdiff<0)
    % With distances that are computed recursively (average, weighted, median,
    % centroid, ward's), errors can accumulate.  Two nodes that are really
    % at the same height in the tree may have had their heights calculated in
    % different ways, making them differ by +/- small amounts.  Make sure that
    % doesn't produce false non-monotonicity warnings.
    negLocs = find(zdiff<0);
    if any(abs(zdiff(negLocs)) > eps(Z(negLocs,3))) % eps(the larger of the two values)
        warning('stats:linkage:NonMonotonicTree',...
                'Non-monotonic cluster tree -- the %s linkage is probably not appropriate.',methodStr);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%% OLD LINKAGE FUNCTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Z = linkageold(Y, method)
%LINKAGEOLD Create hierarchical cluster tree using only MATLAB code.

n = size(Y,2);
m = ceil(sqrt(2*n)); % (1+sqrt(1+8*n))/2, but works for large n
if isa(Y,'single')
   Z = zeros(m-1,3,'single'); % allocate the output matrix.
else
   Z = zeros(m-1,3); % allocate the output matrix.
end

% during updating clusters, cluster index is constantly changing, R is
% a index vector mapping the original index to the current (row, column)
% index in Y.  N denotes how many points are contained in each cluster.
N = zeros(1,2*m-1);
N(1:m) = 1;
n = m; % since m is changing, we need to save m in n.
R = 1:n;

% Square the distances so updates are easier.  The cluster heights will be
% square-rooted back to the original scale after everything is done.
if ~isempty(strmatch(method,['ce';'me';'wa']))
   Y = Y .* Y;
end

for s = 1:(n-1)
   if strcmp(method,'av')
      p = (m-1):-1:2;
      I = zeros(m*(m-1)/2,1);
      I(cumsum([1 p])) = 1;
      I = cumsum(I);
      J = ones(m*(m-1)/2,1);
      J(cumsum(p)+1) = 2-p;
      J(1)=2;
      J = cumsum(J);
      W = N(R(I)).*N(R(J));
      [v, k] = min(Y./W);
   else
      [v, k] = min(Y);
   end

   i = floor(m+1/2-sqrt(m^2-m+1/4-2*(k-1)));
   j = k - (i-1)*(m-i/2)+i;

   Z(s,:) = [R(i) R(j) v]; % update one more row to the output matrix A

   % Update Y. In order to vectorize the computation, we need to compute
   % all the indices corresponding to cluster i and j in Y, denoted by I
   % and J.
   I1 = 1:(i-1); I2 = (i+1):(j-1); I3 = (j+1):m; % these are temp variables
   U = [I1 I2 I3];
   I = [I1.*(m-(I1+1)/2)-m+i i*(m-(i+1)/2)-m+I2 i*(m-(i+1)/2)-m+I3];
   J = [I1.*(m-(I1+1)/2)-m+j I2.*(m-(I2+1)/2)-m+j j*(m-(j+1)/2)-m+I3];

   switch method
   case 'si' % single linkage
      Y(I) = min(Y(I),Y(J));
   case 'co' % complete linkage
      Y(I) = max(Y(I),Y(J));
   case 'av' % average linkage
      Y(I) = Y(I) + Y(J);
   case 'we' % weighted average linkage
      Y(I) = (Y(I) + Y(J))/2;
   case 'ce' % centroid linkage
      K = N(R(i))+N(R(j));
      Y(I) = (N(R(i)).*Y(I)+N(R(j)).*Y(J)-(N(R(i)).*N(R(j))*v)./K)./K;
   case 'me' % median linkage
      Y(I) = (Y(I) + Y(J))/2 - v /4;
   case 'wa' % Ward's linkage
      Y(I) = ((N(R(U))+N(R(i))).*Y(I) + (N(R(U))+N(R(j))).*Y(J) - ...
	  N(R(U))*v)./(N(R(i))+N(R(j))+N(R(U)));
   end
   J = [J i*(m-(i+1)/2)-m+j];
   Y(J) = []; % no need for the cluster information about j.

   % update m, N, R
   m = m-1;
   N(n+s) = N(R(i)) + N(R(j));
   R(i) = n+s;
   R(j:(n-1))=R((j+1):n);
end

if ~isempty(strmatch(method,['ce';'me';'wa']))
   Z(:,3) = sqrt(Z(:,3));
end

Z(:,[1 2])=sort(Z(:,[1 2]),2);
