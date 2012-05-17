function menu = getPopupSchema(this,manager)
% BUILDPOPUPMENU

% Author(s): John Glass
% Revised: 
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $ $Date: 2008/12/04 23:27:32 $
%   % Revision % % Date %

[menu, Handles] = LocalDialogPanel(this,manager);
h = this.Handles;
h.PopupMenuItems = Handles.PopupMenuItems;
this.Handles = h;
                    
% --------------------------------------------------------------------------- %
function [Menu, Handles] = LocalDialogPanel(this, manager)

Menu = javaObjectEDT('com.mathworks.mwswing.MJPopupMenu',xlate('Operating Point'));

item1 = javaObjectEDT('com.mathworks.mwswing.MJMenuItem',xlate('Export to Workspace'));
Menu.add(item1);
h = handle(item1, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalExportAction, this};
h.MouseClickedCallback = {@LocalExportAction, this};

item2 = javaObjectEDT('com.mathworks.mwswing.MJMenuItem',xlate('Rename'));
Menu.add(item2);
h = handle(item2, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalRename, manager};
h.MouseClickedCallback = {@LocalRename, manager};

item3 = javaObjectEDT('com.mathworks.mwswing.MJMenuItem',xlate('Duplicate'));
Menu.add(item3);
h = handle(item3, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalDuplicateAction, this};
h.MouseClickedCallback = {@LocalDuplicateAction, this};

Handles.PopupMenuItems = [item1;item2;item3];

% --------------------------------------------------------------------------- %
function LocalExportAction(es,ed,this)

% Create the export dialog
defaultname = sprintf('op_%s',this.up.Model);
jDialogs.ExportSimulinkIC(this.Model,this.OpPoint,defaultname);

% --------------------------------------------------------------------------- %
function LocalDuplicateAction(es,ed,this)

% Create the new operating point 
optask = this.getRoot;
Label = optask.createDefaultName(this.Label, optask);
newpoint = OperatingConditions.OperConditionValuePanel(this.OpPoint,Label);

% Connect it to the explorer
addNode(optask,newpoint);

% --------------------------------------------------------------------------- %
function LocalRename(es,ed,manager)
Tree = manager.ExplorerPanel.getSelector.getTree;
Tree.startEditingAtPath(Tree.getSelectionPath);
