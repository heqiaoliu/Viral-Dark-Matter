function closeAllFiles(this)
%CLOSEALLFILES closes all of the open files.
%   This method removes all files from the tree.
%
%   Function arguments
%   ------------------
%   THIS: the fileframe object instance.

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/10/02 18:59:09 $

    rootNode = get(this.treeHandle,'Root');
    node = getNextChild(rootNode);
    while ~isempty(node)
        % Select the first node
        ja = javaArray('com.mathworks.hg.peer.UITreeNode',1);
        ja(1) = node;
        set(this.treeHandle,'SelectedNodes',ja);
        % delete the first node

		% Force a screen update before we try to close the file.
		% g485451
		drawnow;

        closeFile(this);
        % Make the changes take effect
        drawnow;
        node = getNextChild(rootNode);
    end

end

function node = getNextChild(rootNode)
    node = [];
    if get(rootNode, 'ChildCount')
        node = rootNode.getFirstChild();
    end
end
