function node = getTreeNode(this)
%GETTREENODE Get the treeNode.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/04/09 19:04:44 $

node = fevalChild(this, @getTreeNode);

node = [{'Library'} {[node{:}]}];

% [EOF]
