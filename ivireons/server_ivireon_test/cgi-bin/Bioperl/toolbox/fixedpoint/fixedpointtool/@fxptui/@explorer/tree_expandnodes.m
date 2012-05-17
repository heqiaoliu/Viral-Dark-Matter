function tree_expandnodes(h, nodes)
%TREE_EXPANDNODES   

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:59:52 $

n = length(nodes);
for i = 1:n;
  child = nodes(i);
  if(child.isHierarchical)
    h.imme.expandTreeNode(child);
    childnodes = child.getHierarchicalChildren;
    if(length(childnodes) > 0)
      h.tree_expandnodes(childnodes);
    end
  end
end

% [EOF]