function closeFile(this)
%CLOSEFILE Close the currently selected file.
%   If no file is selected, this routine is a no-op.
%
%   Function arguments
%   ------------------
%   THIS: the fileframe object instance.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/12/22 23:50:21 $

    % Find the selected node
    selectedNode = get(this.treeHandle,'SelectedNodes');

    if isempty(selectedNode)
        return
    end
    
    % Get the path of nodes which lead to the selected node.
    pathToNode = get(selectedNode(1),'Path');
    selectedRootNode = pathToNode(2);

    % Unselect and remove the node
    set(this.treeHandle,'SelectedNodes',[]);
    selectedModel = get(this.treeHandle,'Model');
    awtinvoke(selectedModel, 'removeNodeFromParent', selectedRootNode);
    % We need to call drawnow to make this removal take effect
    drawnow;
    
    % We should reload the model if all of the trees are gone.
    rootNode = get(this.treeHandle,'Root');
    if ~get(rootNode, 'ChildCount')
        awtinvoke(selectedModel,'reload()');
    end
    
    % Clear the panel.
    oldPanel = this.currentPanel;
    this.setMetadataText('default');
    this.setDatapanel('default');

    % Close the corresponding fileTree
    nodeStruct = hdftool.getTreeNode(selectedRootNode);
    close(nodeStruct.tree);
    if ishghandle(oldPanel) && oldPanel ~= this.noDataPanel
        delete(oldPanel);
    end
end
