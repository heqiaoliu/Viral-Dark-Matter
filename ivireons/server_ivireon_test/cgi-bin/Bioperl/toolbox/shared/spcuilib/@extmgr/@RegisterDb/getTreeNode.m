function node = getTreeNode(this)
%GETTREENODE Get the treeNode.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/13 19:47:03 $

node = iterator.visitImmediateChildren(this, @getTreeNode);

indx = 1;
while indx <= length(node)
    if iscell(node{indx})
        node = {node{1:indx-1} node{indx}{:} node{indx+1:end}};
        indx = indx+2;
    else
        indx = indx+1;
    end
end

if ~isempty(this.RegisterTypeDb)
    typeNodes = getTreeNode(this.RegisterTypeDb);
    node = {node{:}, typeNodes{:}};
end

node = {this.FileName, node};

% node = uitreenode(this, this.FileName, [], false);

% [EOF]
