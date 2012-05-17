function menu = getPopupSchema(this,manager)
% BUILDPOPUPMENU

% Author(s): John Glass
% Revised: 
%   Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.10 $ $Date: 2008/12/04 23:27:18 $

[menu, Handles] = LocalDialogPanel(this);
h = this.Handles;
h.PopupMenuItems = Handles.PopupMenuItems;
this.Handles = h;

% -------------------------------------------------------------------------
function [Menu, Handles] = LocalDialogPanel(this)

Menu = javaObjectEDT('com.mathworks.mwswing.MJPopupMenu',xlate('Task Options'));
item1 = javaObjectEDT('com.mathworks.mwswing.MJMenuItem',xlate('Delete'));
item2 = javaObjectEDT('com.mathworks.mwswing.MJMenuItem',xlate('Options...'));

Menu.add(item1);
h = handle(item1, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalAction, this};
h.MouseClickedCallback = {@LocalAction, this};

Menu.add(item2);
h = handle(item2, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalLinearizationSettings, this};
h.MouseClickedCallback = {@LocalLinearizationSettings, this};

Handles.PopupMenuItems = [item1;item2];

% -------------------------------------------------------------------------
function LocalAction(eventSrc, eventData, this)

% Get the parent
parent = this.up;

% Clean up
this.cleanuptask;

% Remove the node
parent.removeNode(this);

% Make the parent node the selected node
F = slctrlexplorer;
F.setSelected(parent.getTreeNodeInterface);

% -------------------------------------------------------------------------
function LocalLinearizationSettings(es,ed,this)

dlg = slctrlguis.optionsdlgs.getLinearizationOperatingPointSearchDialog(this.getOpCondNode);
dlg.setSelectedTab('Linearization')
dlg.show;
