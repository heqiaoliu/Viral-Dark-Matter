function restoreDataNode(h,objectlist,Action,newName)
% Restore the child nodes of the parentnode h with the data objects in
% objectlist.
% This method is called by undo/redo methods of @nodetransaction.
% h: parent node handle whos children are being added or removed
% objectlist: a cell array of data objects.
% Action: This is read from the @nodetransaction.
%             It is a string inicating if the transaction was recorded was
%             a node deletion ('removed' for undo) or addition ('added' for undo).

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2005/05/27 14:18:56 $

switch lower(Action)
    case 'removed'
        %members were removed; so add them back
        for k = 1:length(objectlist)
            childnode = createtstoolNode(objectlist{k},h);
            h.addnode(childnode);
        end

        % send tsstructure change event for the benefit of the views
        ed = tsexplorer.tstreeevent(h.getRoot,'add',childnode);
        h.getRoot.fireTsStructureChangeEvent(ed);       
    case 'added'
        % new members were added by transaction; so delete them
        for k = 1:length(objectlist)
            % assume that the node label is same as the data object name
            % this is true except for Simulink data nodes. For Simulink data
            % nodes, modification of nodes is not allowed anyway.
            ChildNodes = h.getChildren;
            NodeToBeDeleted = find(ChildNodes,'Label',objectlist{k}.Name);
            nodepath = constructNodePath(NodeToBeDeleted);
            if ~isempty(NodeToBeDeleted)
                h.removeNode(NodeToBeDeleted);
            end
        end
        ed = tsexplorer.tstreeevent(h.getRoot,'remove',NodeToBeDeleted);
        h.getRoot.fireTsStructureChangeEvent(ed,nodepath);  
    case 'renamed'
        %members were renamed; so change their names back
        %<no op> ..implemented in @tscollectionNode/restoreDataNode
end
