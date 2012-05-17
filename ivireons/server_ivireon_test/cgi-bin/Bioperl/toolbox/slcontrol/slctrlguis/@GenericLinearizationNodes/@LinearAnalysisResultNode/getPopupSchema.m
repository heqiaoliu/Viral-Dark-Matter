function Menu = getPopupSchema(this,manager)
% BUILDPOPUPMENU

% Author(s): John Glass
% Revised: 
%   Copyright 2003-2008 The MathWorks, Inc.
% $Revision: 1.1.6.18 $ $Date: 2008/12/04 23:27:03 $

Menu = javaObjectEDT('com.mathworks.mwswing.MJPopupMenu',...
                    sprintf('Linear Analysis Result'));

item1 = javaObjectEDT('com.mathworks.mwswing.MJMenuItem',sprintf('Delete'));
item2 = javaObjectEDT('com.mathworks.mwswing.MJMenuItem',sprintf('Rename'));
item3 = javaObjectEDT('com.mathworks.mwswing.MJMenuItem',sprintf('Export'));
item4 = javaObjectEDT('com.mathworks.mwswing.MJMenuItem',sprintf('Highlight Blocks in Linearization'));
item5 = javaObjectEDT('com.mathworks.mwswing.MJMenuItem',sprintf('Remove Highlighting'));

Menu.add(item1);
Menu.add(item2);
Menu.add(item3);
if ~isempty(this.InspectorNode)
    Menu.add(item4);
    Menu.add(item5);
    Handles.PopupMenuItems = [item1; item2; item3; item4; item5];
else
    Handles.PopupMenuItems = [item1; item2; item3];
end


h = handle(item1, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalDelete,this};
h.MouseClickedCallback = {@LocalDelete,this};

h = handle(item2, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalRename,manager};
h.MouseClickedCallback = {@LocalRename,manager};

h = handle(item3, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalExportAction,this};
h.MouseClickedCallback = {@LocalExportAction,this};

if ~isempty(this.InspectorNode)
    h = handle(item4, 'callbackproperties' );
    h.ActionPerformedCallback = {@LocalHiliteAction,this};
    h.MouseClickedCallback = {@LocalHiliteAction,this};
    
    h = handle(item5, 'callbackproperties' );
    h.ActionPerformedCallback = {@LocalRemoveHiliteAction,this};
    h.MouseClickedCallback = {@LocalRemoveHiliteAction,this};
end

h = this.Handles;
h.PopupMenuItems = Handles.PopupMenuItems;
this.Handles = h;

%% --------------------------------------------------------------------------- %
function LocalDelete(es,ed,this)

% Delete the current node
parent = this.up;
parent.removeNode(this);

% Make the parent node the selected node
F = slctrlexplorer;
F.setSelected(parent.getTreeNodeInterface);

%% --------------------------------------------------------------------------- %
function LocalExportAction(es,ed,this)

this.exportToWorkspace;

% --------------------------------------------------------------------------- %
function LocalHiliteAction(eventSrc, eventData, this)
LocalRemoveHiliteAction(eventSrc, eventData, this);
this.HiliteBlocksInLinearization('find');

% --------------------------------------------------------------------------- %
function LocalRemoveHiliteAction(eventSrc, eventData, this)

set_param(this.Model,'HiliteAncestors','off');

%% --------------------------------------------------------------------------- %
function LocalRename(es,ed,manager)

Tree = manager.ExplorerPanel.getSelector.getTree;
Tree.startEditingAtPath(Tree.getSelectionPath);
