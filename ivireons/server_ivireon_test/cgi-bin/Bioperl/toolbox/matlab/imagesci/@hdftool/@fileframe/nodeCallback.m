function nodeCallback(this)
%NODECALLBACK A callback function for a node when it is selected.
%   This function is called when the user selects a given node in the tree.
%
%   Function arguments
%   ------------------
%   THIS: the fileframe object instance.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/07/28 14:29:10 $

    % Prevent reentrant calls to this function (geck: 289940) 
    % Since the uitreenodes may call this function without waiting for it
    % to finish, we need to ignore reentrant function calls.  
    persistent inFunction;
    if isempty(inFunction) || ~inFunction
        inFunction = true;
    else
        return
    end

    % Find which node was selected.
    tree = this.treeHandle;
    selectedNode = get(tree,'SelectedNodes');
    oldSelectedNode = [];
    
    % Continue displaying panels until our display catches up with the 
    % user's selection (they might select faster than we can update).  In
    % other words, the selectedNode should eventually match the
    % oldSelectedNode.
    while ~isempty(selectedNode) && ...
            selectedNode ~= oldSelectedNode

        set(this.figureHandle, 'Pointer', 'watch');
        try
            hSelectedNode = handle(selectedNode(1));
            selectedNodeStruct = hdftool.getTreeNode(hSelectedNode);

            % Determine the parent node of the selected node.
            pathToNode = get(hSelectedNode,'Path');
            level = length(pathToNode);
            if level == 1
                this.setMetadataText('This node is not part of the tree.');
                this.setDatapanel('');
                set(this.figureHandle, 'Pointer', 'arrow');
                inFunction = false;
                return
            end
            parentNode = pathToNode(end-1);
            parentNode = handle(parentNode);
            parentNodeStruct = hdftool.getTreeNode(parentNode);

            % Display the information corresponding to the node.
            displayNodeInfo(selectedNodeStruct.tree,...
                            selectedNodeStruct, parentNodeStruct);
        catch myException
            set(this.figureHandle, 'Pointer', 'arrow');
            inFunction = false;
            rethrow(myException);
        end
        set(this.figureHandle, 'Pointer', 'arrow');

        oldSelectedNode = selectedNode;
        selectedNode = get(tree,'SelectedNodes');
    end
    
    inFunction = false;
end

