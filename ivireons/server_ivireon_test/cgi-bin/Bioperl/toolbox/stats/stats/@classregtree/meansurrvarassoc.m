function ma=meansurrvarassoc(t,j)
%MEANSURRVARASSOC Mean predictive measure of association for surrogate splits in decision tree.
%   MA=MEANSURRVARASSOC(T) returns a p-by-p matrix with predictive measures
%   of association for p predictors. Element MA(I,J) is the predictive
%   measure of association averaged over surrogate splits on predictor J
%   for which predictor I is the optimal split predictor. This average is
%   computed by summing positive values of the predictive measure of
%   association over optimal splits on predictor I and surrogate splits on
%   predictor J and dividing by the total number of optimal splits on
%   predictor I, including splits for which the predictive measure of
%   association between predictors I and J is negative.
%
%   MA=MEANSURRVARASSOC(T,N) takes an array N of node numbers and returns
%   the predictive measure of association averaged over the specified
%   nodes.
%
%   See also CLASSREGTREE, CLASSREGTREE/SURRCUTVAR,
%   CLASSREGTREE/SURRCUTTYPE, CLASSREGTREE/SURRCUTCATEGORIES,
%   CLASSREGTREE/SURRCUTPOINT, CLASSREGTREE/SURRCUTFLIP,
%   CLASSREGTREE/SURRVARASSOC.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $

if nargin>=2 && ~validatenodes(t,j)
    error('stats:classregtree:meansurrvarassoc:InvalidNode',...
          'J must be an array of node numbers or a logical array of the proper size.');
end

if nargin<2
    j = 1:length(t.surrvar);
end

% Keep only branch nodes
isbr = isbranch(t,j);
j = j(isbr);

% Init
N = numel(j);
p = length(t.names);
ma = zeros(p);
nsplit = zeros(p,1);

% Get the association matrix and lists of best and surrogate predictors
a = t.varassoc(j);
[~,bestvar] = cutvar(t,j);
[~,surrvar] = surrcutvar(t,j);

% Loop over optimal splits. Increase the split count by 1 for every node.
for i=1:N
    n = bestvar(i);
    nsplit(n) = nsplit(n) + 1;
    m = surrvar{i};
    if ~isempty(m)
        ma(n,m) = ma(n,m) + a{i};
    end
end

% Loop over hidden variables. A(I,J) is computed for hidden predictor I at
% every node, and so the number of splits is equal to the number of nodes.
if ~isempty(t.hidevar)
    hidevar = t.hidevar;
    Nhide = numel(hidevar);
    hsurrvar = t.hidesurrvar(j,:);
    ha = t.hidevarassoc(j,:);
    nsplit(hidevar) = N;
    for i=1:N
        for ihide=1:Nhide
            n = hidevar(ihide);
            m = hsurrvar{i,ihide};
            if ~isempty(m)
                ma(n,m) = ma(n,m) + ha{i,ihide};
            end
        end
    end
end

% Divide cumulative association by the number of optimal splits on each
% predictor
gt0 = nsplit>0;
ma(gt0,:) = bsxfun(@rdivide,ma(gt0,:),nsplit(gt0));

% Make sure the diagonal elements are 1
ma(1:p+1:end) = 1;
