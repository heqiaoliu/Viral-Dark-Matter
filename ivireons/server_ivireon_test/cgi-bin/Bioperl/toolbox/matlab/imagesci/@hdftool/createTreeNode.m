function treenode = createTreeNode(dispName, infoStruct, tree, value, icon, leaf)
%CREATETREENODE Construct an UITREENODE, storing associated data.
%   The data can be retrieved from the uitreenode after it is
%   returned from the uitree.
%
%   Function arguments
%   ------------------
%     DISPLAYNAME: the name that will be displayed in the tree.
%     NODEINFOSTRUCT: the structrue that contains the HDF node info..
%     TREE: the fileTree which contains this node.
%     VALUE: The name (asnd description) of the node in the tree.
%     ICON: the path of the icon that is to be used for this node.
%     LEAF: a boolean value that indicates it this node is a leaf.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/05/12 21:33:27 $

    % Create a UITREENODE, and store associated data.
    treenode = uitreenode('v0', value, value, icon, leaf);
    
    function s = getNodeData()
        s.displayname     = dispName;
        s.nodeinfostruct  = infoStruct;
        s.tree            = tree;
    end

    set(treenode ,'UserData', @getNodeData);

end
