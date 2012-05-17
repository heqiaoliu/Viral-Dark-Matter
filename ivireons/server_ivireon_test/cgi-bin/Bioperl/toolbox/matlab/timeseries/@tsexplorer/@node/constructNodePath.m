function nodepath = constructNodePath(node)
% given a node, construct the path all the way to its parent node, which
% would be TSNode or SimulinkTSNode.
%
% node: handle to the node whose "location" is sought.
% nodepath is returned as a path string: Parent/Child/Child/.../node

%   Copyright 2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $ $Date: 2005/05/27 14:14:24 $

nodepath = node.Label;
myParent = node.up;
myRoot = node.getParentNode;

if isequal(myRoot,node) %node is a parent itself
    return
end

% if node is not the root, then it must be a child.
while ~isequal(myParent,myRoot)
    nodepath = [myParent.Label,'/',nodepath];
    myParent = myParent.up;
end

nodepath = [myRoot.Label,'/',nodepath];