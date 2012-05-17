function Tree = treeprune(Tree,varargin)
%TREEPRUNE Obsolete function
%   
%   TREEPRUNE will be removed in a future release. Use CLASSREGTREE/PRUNE instead.
%
%   See also CLASSREGTREE/PRUNE.

%   Copyright 1993-2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:17:51 $

if isa(Tree,'struct')
    Tree = classregtree(Tree);
end

Tree = prune(Tree,varargin{:});
