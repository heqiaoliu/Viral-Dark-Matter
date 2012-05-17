function menu = getPopupSchema(this,manager)
% BUILDPOPUPMENU

% Author(s): John Glass
% Revised: 
% Copyright 2003-2005 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2008/12/04 23:27:13 $

[menu, Handles] = LocalDialogPanel(this);
h = this.Handles;
h.PopupMenuItems = Handles.PopupMenuItems;
this.Handles = h;

% --------------------------------------------------------------------------- %
function [Menu, Handles] = LocalDialogPanel(this)

Menu = javaObjectEDT('com.mathworks.mwswing.MJPopupMenu',sprintf('Custom Views'));
item1 = javaObjectEDT('com.mathworks.mwswing.MJMenuItem',sprintf('Add View'));

Menu.add(item1);
Handles.PopupMenuItems = item1;
h = handle(item1, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalAction, this};
h.MouseClickedCallback = {@LocalAction, this};

% --------------------------------------------------------------------------- %
function LocalAction(eventSrc, eventData, this)

% Get the handle to the explorer frame
ExplorerFrame = slctrlexplorer;

% Clear the status area
ExplorerFrame.clearText;

% Create the view settings node
ViewSettingsNode = GenericLinearizationNodes.ViewSettings(length(this.getChildren)+1);

% Add the view settings node to the tree
this.addNode(ViewSettingsNode);

% Expand the views nodes so the user sees the new result
ExplorerFrame.expandNode(this.getTreeNodeInterface);
ExplorerFrame.postText(sprintf(' - A new view has been added.'))