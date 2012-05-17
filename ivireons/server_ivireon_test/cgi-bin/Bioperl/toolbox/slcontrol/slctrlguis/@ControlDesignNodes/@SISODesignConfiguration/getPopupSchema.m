function menu = getPopupSchema(this,manager)
% BUILDPOPUPMENU

% Author(s): John Glass
% Revised: 
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/12/04 23:26:51 $

[menu, Handles] = LocalDialogPanel(this,manager );
h = this.Handles;
h.PopupMenuItems = Handles.PopupMenuItems;
this.Handles = h;

% --------------------------------------------------------------------------- %
function [Menu, Handles] = LocalDialogPanel(this,manager)

Menu = javaObjectEDT('com.mathworks.mwswing.MJPopupMenu',...
                    sprintf('Linear Analysis Result'));

item1 = javaObjectEDT('com.mathworks.mwswing.MJMenuItem',sprintf('Delete'));
item2 = javaObjectEDT('com.mathworks.mwswing.MJMenuItem',sprintf('Rename'));

Menu.add(item1);
Menu.add(item2);

h = handle(item1, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalDelete, this};
h.MouseClickedCallback = {@LocalDelete, this};

h = handle(item2, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalRename, this, manager};
h.MouseClickedCallback = {@LocalRename, this, manager};

Handles.PopupMenuItems = [item1;item2];

% --------------------------------------------------------------------------- %
function LocalDelete(eventSrc, eventData, this)

% Delete the current node
parent = this.up;
parent.removeNode(this);

% Make the parent node the selected node
F = slctrlexplorer;
F.setSelected(parent.getTreeNodeInterface);

% --------------------------------------------------------------------------- %
function LocalRename(hSrc, hData, this, manager)
Tree = manager.ExplorerPanel.getSelector.getTree;
Tree.startEditingAtPath(Tree.getSelectionPath);
