function [v,n]=surrcutvar(t,j)
%SURRCUTVAR Variables used for surrogate splits in decision tree.
%   V=SURRCUTVAR(T) returns an N-element cell array V of the names of the
%   variables used for surrogate splits in each node of the tree T, where N
%   is the number of nodes in the tree. Every element of V is a cell array
%   with the names of the surrogate split variables at this node. The
%   variables are sorted by the predictive measure of association with the
%   optimal predictor in the descending order, and only variables with the
%   positive predictive measure are included. The optimal-split variable at
%   this node is not included. For non-branch (leaf) nodes, V contains an
%   empty cell.
%
%   V=SURRCUTVAR(T,J) takes an array J of node numbers and returns the
%   surrogate split variables for the specified nodes.
%
%   [V,NUM]=SURRCUTVAR(...) also returns a cell array NUM with indices for
%   each variable.
%
%   See also CLASSREGTREE, CLASSREGTREE/NUMNODES, CLASSREGTREE/CHILDREN,
%   CLASSREGTREE/CUTVAR. 

%   Copyright 2010 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $

if nargin>=2 && ~validatenodes(t,j)
    error('stats:classregtree:surrcutvar:InvalidNode',...
          'J must be an array of node numbers or a logical array of the proper size.');
end

if nargin<2
    j = 1:length(t.surrvar);
end

don = nargout>1;

N = numel(j);
v = repmat({{}},N,1);
if don
    n = repmat({[]},N,1);
end

names = t.names(:)';
for i=1:N
    node = j(i);
    thisn = abs(t.surrvar{node});
    if ~isempty(thisn)
        v{i} = names(thisn);
        if don
            n{i} = thisn;
        end
    end
end
