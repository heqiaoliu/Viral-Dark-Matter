function restoreDataNode(h,objectlist,Action,varargin)
% Restore the child nodes of the parentnode h with the data objects in
% objectlist. 
% This method is called by undo/redo methods of @nodetransaction.
% h: parent node handle whos children are being added or removed 
% objectlist: a cell array of data objects.
% Action: This is read from the @nodetransaction.
%             It is a string inicating if the transaction was recorded was
%             a node deletion ('removed' for undo) or addition ('added' for
%             undo).

%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2006/06/27 23:11:42 $
Tsc = h.Tscollection;
switch lower(Action)
    case 'removed'
        %members were removed: add them back
        for k = 1:length(objectlist)
            Tsc.addts(objectlist{k});
        end
        
        child = find(h.getChildren,'Label',objectlist{end}.Name);
        if ~isempty(child)
            h.getRoot.Tsviewer.TreeManager.reset
            h.getRoot.Tsviewer.TreeManager.Tree.expand(h.getTreeNodeInterface);
            h.getRoot.Tsviewer.TreeManager.Tree.setSelectedNode(child.getTreeNodeInterface);
            drawnow % Force the node to show seelcted
            h.getRoot.Tsviewer.TreeManager.Tree.repaint        
        end
        
    case 'added'
        % new members were added: remove them
        for k = 1:length(objectlist)
            Tsc.removets(objectlist{k}.Name);
        end
        h.getRoot.Tsviewer.TreeManager.reset
        h.getRoot.Tsviewer.TreeManager.Tree.setSelectedNode(h.getTreeNodeInterface);
        drawnow % Force the node to show seelcted
        h.getRoot.Tsviewer.TreeManager.Tree.repaint

    case 'renamed'
        % A member was renamed: restore the name
        % objectlist should have only one member
        newName = varargin{1};
        tsnodes = h.getChildren;
        for k=1:length(tsnodes)
            if strcmp(tsnodes(k).Label,objectlist{1}.Name)
                % Updating the timeseries name will cause listeners
                % to refresh the members table and tscollection
                tsnodes(k).Timeseries.Name = varargin{1};
                break;
            end
        end
end
