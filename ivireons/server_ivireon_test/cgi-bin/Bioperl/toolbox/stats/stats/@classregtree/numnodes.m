function n=numnodes(t)
%NUMNODES Number of nodes in tree.
%   N=NUMNODES(T) returns the number of nodes N in the tree T.
%
%   See also CLASSREGTREE.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:20:02 $

n = numel(t.node);
