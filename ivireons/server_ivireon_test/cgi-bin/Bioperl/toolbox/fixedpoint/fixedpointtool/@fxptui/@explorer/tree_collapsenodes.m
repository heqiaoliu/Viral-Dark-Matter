function tree_collapsenodes(h, nodes)
%TREE_COLLAPSENODES   

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:59:50 $

n = length(nodes);
for i = 1:n;
  child = nodes(i);
  if(child.isHierarchical)
    h.imme.collapseTreeNode(child);
    childnodes = child.getChildren;
    if(length(childnodes) > 0)
      h.tree_collapsenodes(childnodes);
    end
  end
end

% [EOF]