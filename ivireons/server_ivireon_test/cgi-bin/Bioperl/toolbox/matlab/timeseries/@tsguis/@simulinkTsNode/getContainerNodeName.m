function Label = getContainerNodeName(this)
%getContainerNodeName returns the name of the model that this node belongs
%to. The model is an immediate child of simulinkTsParentNode.

%   Copyright 2005 The MathWorks, Inc.
%   % Revision: % % Date: %

node = this;
Label = [];

% If this simulinkTsNode is attached directly to the  Parent Node, return
% an empty label. There is no model name (and hence no model table in
% parent panel) in this case.
if strcmp(class(node.up),'tsguis.simulinkTsParentNode')
    return;
end

while ~strcmp(class(node.up),'tsguis.simulinkTsParentNode')
    node = node.up;
end

Label = node.Label;
