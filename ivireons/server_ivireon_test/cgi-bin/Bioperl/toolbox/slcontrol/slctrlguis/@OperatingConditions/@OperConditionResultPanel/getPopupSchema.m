function menu = getPopupSchema(this,manager)
% getPopupSchema

% Author(s): John Glass
% Revised: 
%   Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.10 $ $Date: 2008/12/04 23:27:29 $

[menu, Handles] = LocalDialogPanel(this,manager);
h = this.Handles;
h.PopupMenuItems = Handles.PopupMenuItems;
this.Handles = h;

%% --------------------------------------------------------------------------- %
function [Menu, Handles] = LocalDialogPanel(this,manager)
import com.mathworks.mwswing.*;

Menu = javaObjectEDT('com.mathworks.mwswing.MJPopupMenu',xlate('Operating Point Result'));

item1 = javaObjectEDT('com.mathworks.mwswing.MJMenuItem',xlate('Export to Workspace'));
Menu.add(item1);
h = handle(item1, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalExportAction, this};
h.MouseClickedCallback = {@LocalExportAction, this};

item2 = javaObjectEDT('com.mathworks.mwswing.MJMenuItem',xlate('Rename'));
Menu.add(item2);
h = handle(item2, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalRename, this, manager};
h.MouseClickedCallback = {@LocalRename, this, manager};

Handles.PopupMenuItems = [item1;item2];

%% --------------------------------------------------------------------------- %
function LocalExportAction(es,ed,this)

% Create the export dialog
defaultname = sprintf('op_%s',this.up.Model);
jDialogs.ExportSimulinkIC(this.up.Model,this.OpPoint,defaultname);

%% --------------------------------------------------------------------------- %
function LocalRename(es,ed,this, manager)
Tree = manager.ExplorerPanel.getSelector.getTree;
Tree.startEditingAtPath(Tree.getSelectionPath);
