function menu = getPopupSchema(this,manager)
% BUILDPOPUPMENU

% Author(s): John Glass
% Revised: 
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $ $Date: 2008/12/04 23:27:38 $
%   % Revision % % Date %

[menu, Handles] = LocalDialogPanel(this);
h = this.Handles;
h.PopupMenuItems = Handles.PopupMenuItems;
this.Handles = h;

% -------------------------------------------------------------------------
function [Menu, Handles] = LocalDialogPanel(this)

Menu = javaObjectEDT('com.mathworks.mwswing.MJPopupMenu',xlate('Linear Analysis Result'));

item1 = javaObjectEDT('com.mathworks.mwswing.MJMenuItem',xlate('Export to Workspace'));
item2 = javaObjectEDT('com.mathworks.mwswing.MJMenuItem',xlate('Options...'));

Menu.add(item1);
h = handle(item1, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalExportAction, this};
h.MouseClickedCallback = {@LocalExportAction, this};

Menu.add(item2);
h = handle(item2, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalLinearizationSettings, this};
h.MouseClickedCallback = {@LocalLinearizationSettings, this};

Handles.PopupMenuItems = [item1;item2];

% -------------------------------------------------------------------------
function LocalExportAction(eventSrc, eventData, this)

% Export the lti object to the workspace
defaultnames = {sprintf('opspec_%s',this.Model)};
exporteddata = {this.OpSpecData};
export2wsdlg({'Operating Point Specification'},defaultnames,exporteddata)

% -------------------------------------------------------------------------
function LocalLinearizationSettings(es,ed,this)

dlg = slctrlguis.optionsdlgs.getLinearizationOperatingPointSearchDialog(this);
dlg.setSelectedTab('OperatingPoint')
dlg.show;
