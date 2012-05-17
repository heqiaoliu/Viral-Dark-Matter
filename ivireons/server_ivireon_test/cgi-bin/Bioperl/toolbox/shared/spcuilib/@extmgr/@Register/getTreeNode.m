function node = getTreeNode(this)
%GETTREENODE Get the treeNode.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/13 19:46:52 $

node = sprintf('%s.%s', this.Type, this.Name);

if ~isempty(this.PropertyDb) && ~isEmpty(this.PropertyDb)
    propNodes = fevalChild(this.PropertyDb, @getTreeNode);
    node = {node, propNodes};
end

% node = uitreenode(this, ...
%     sprintf('%s.%s', this.Type, this.Name), ...
%     [], true);

% [EOF]
