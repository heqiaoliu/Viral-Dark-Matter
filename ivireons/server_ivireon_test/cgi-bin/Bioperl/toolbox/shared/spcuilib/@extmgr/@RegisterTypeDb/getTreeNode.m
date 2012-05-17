function node = getTreeNode(this)
%GETTREENODE Get the treeNode.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/13 19:47:33 $

node = fevalChild(this, @getTreeNode);

node = {'Register Types', node};

% node = uitreenode(this, 'Register Types', [], false);

% [EOF]
