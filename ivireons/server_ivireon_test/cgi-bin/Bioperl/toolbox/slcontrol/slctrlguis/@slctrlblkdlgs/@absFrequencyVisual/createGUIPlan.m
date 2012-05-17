function [addPlan,addEdit] = createGUIPlan(this) 
% CREATEGUIPLAN create GUI components the visualization 
%
% This method is called by createGUI and allows subclasses to add their own
% widgets to the GUI
%
% [addPlan,addEdit] = createGUIPlan(this);
%
% Outputs:
%    addPlan - cell array with plug-in widgets to add to parent
%    addEdit - cell array of uimgr widgets to add to the edit menu item
%              added by the parent class
%

% Author(s): A. Stothert 11-Feb-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2010/05/10 17:58:12 $

%% Edit menu properties
grpLinProps = uimgr.uimenugroup('grpLinearizationProperties',1);
mLinProps = uimgr.uimenu('LinearizationProperties', 1, ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:menuLinearizationProperties'));
mLinProps.WidgetProperties = {'callback', @(hSrc, hData) showDlgTab(this,'tabLinearization')};
grpLinProps.add(mLinProps)
grpLogProps = uimgr.uimenugroup('grpLoggingProperties',1);
mLogProps = uimgr.uimenu('LoggingProperties', 1, ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:menuLoggingProperties'));
mLogProps.WidgetProperties = {'callback', @(hSrc, hData) showDlgTab(this,'tabLogging')};
grpLogProps.add(mLogProps)

%% Toolbar button for legend
bShowLegend = uimgr.uitoggletool('ShowLegend', 3);
icons = getappdata(this.Application.UIMgr);
if ~isfield(icons,'legend_check_block_dlg')
   iLegend = load(fullfile(matlabroot,'toolbox','matlab','icons','legend.mat'));
   icons.legend_check_block_dlg = iLegend.cdata;
   setappdata(this.Application.UIMgr,icons);
end
bShowLegend.IconAppData = 'legend_check_block_dlg';
bShowLegend.Enable = 'on';
bShowLegend.WidgetProperties = { ...
   'tooltip', DAStudio.message('Slcontrol:slctrlblkdlgs:tipToggleLegend'), ...
   'click',   @(hSrc, hData) localShowLegend(this)};

addPlan = {bShowLegend, 'Base/Toolbars/Playback'};
addEdit = {grpLinProps,grpLogProps};
end

function localShowLegend(this)
%Helper function to react to show legend toolbar button events

this.ShowLegend = ~this.ShowLegend;
this.updateLegend
end
