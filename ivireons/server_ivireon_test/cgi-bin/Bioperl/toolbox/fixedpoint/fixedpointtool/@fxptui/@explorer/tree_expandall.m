function tree_expandall(h)
%TREE_EXPANDALL

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:59:51 $

children = h.getRoot.getHierarchicalChildren;
h.tree_expandnodes(children);

% [EOF]