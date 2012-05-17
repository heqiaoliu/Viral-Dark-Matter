function enableGUI(this, enabState) %#ok<INUSD>
%ENABLEGUI Enable/disable the GUI widgets.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.3.2.1 $  $Date: 2010/06/17 14:13:38 $

%Get handle to visualization
hVis    = this.Application.Visual;

if ~hVis.canShowBounds
   %Nothing to do, quick return
   return
end

%Add context menus to the response plot
hMenuParent = hVis.hMenu.Requirements;
cmNewBound = uimenu(hMenuParent, ...
   'Tag', 'cmenuNewBound', ...
   'Label', DAStudio.message('SLControllib:checkpack:cmenuNewBound'), ...
   'Callback', @(hSrc, hData) launch(this, 'newbound'), ...
   'Enable', 'on');
cmEditBound = uimenu(hMenuParent, ...
   'Tag', 'cmenuEditBound', ...
   'Label', DAStudio.message('SLControllib:checkpack:cmenuEditBound'), ...
   'Callback', @(hSrc, hData) launch(this, 'editbound'), ...
   'Enable', 'on');
this.hContextMenus = struct(...
   'cmNewBound', cmNewBound, ...
   'cmEditBound', cmEditBound);
set(hMenuParent,'Visible','on');

%Add widgets to the visualization plot
hPlot     = hVis.hPlot;
hParent   = hVis.Application.getGUI.hVisParent;
hC        = uicontainer('Parent',hParent);
btnString = DAStudio.message('SLControllib:checkpack:btnReqToolApply');
hApply    = uicontrol(...
   'Parent', hC,...
   'Style','pushbutton', ...
   'Tag', 'btnReqToolApply', ...
   'String', btnString, ...
   'Callback', {@localApply this}, ...
   'Units', 'characters', ...
   'Position', [0 0 numel(btnString)+4 2], ...
   'TooltipString', DAStudio.message('SLControllib:checkpack:ttipReqToolApply'));
%Position button in top right
set(hParent,'units','characters');
set(hC,'units','characters');
pC = get(hParent,'Position');
pApply = get(hApply,'Position');
pNew = [pC(3)-pApply(3)-1, pC(4)-pApply(4)-1, pApply(3:4)];
set(hC,'Position',pNew);
set(hC,'units','normalized');
set(hParent,'units','normalized');

%Set callback for button
localSetApply([],[],this,hApply)
L = handle.listener(this,findprop(this,'isDirty'),'PropertyPostSet',{@localSetApply this hApply});
this.Listeners = [this.Listeners; L];
%Configure graphical requirement settings
if ~isfield(hPlot.Options,'RequirementColor')
   hPlot.Options.RequirementColor = [250   250   210]/255;
end
if ~isfield(hPlot.Options,'DisabledRequirementColor')
   hPlot.Options.DisabledRequirementColor = [230   230   230]/255;
end

%Create listener for model update diagram events (sim start, ctrl-D, etc.)
hBlk = this.Application.DataSource.BlockHandle;
hMdl = get_param(bdroot(hBlk.getFullName),'Object');
L = handle.listener(hMdl,'EnginePostCompChecksum', @(hSrc,hData) localSimStart(this));
this.Listeners = [this.Listeners; L];
%Create listener for visualization visible status changes
hFig = handle(this.Application.Parent);
addlistener(hFig,'Visible','PreSet', @(hSrc,hData) localVisVisible(this,hData));

%Create and editor dialog for all requirements managed by this tool
this.hEditDlg = editconstr.editdlg;

%Disable all widgets if block is in a linked subsystem
hPBlk = get_param(this.Application.DataSource.BlockHandle.Parent,'Object');
if hPBlk.isLinked
   set(hMenuParent,'Enable','off');
   this.isLocked = true;
end
end

function localSimStart(this)
%Helper function to manage model update diagram events

if this.isDirty
   %Requirement tool is dirty.
   name = this.Application.getAppName;
   error('SLControllib:checkpack:errVisualizationHasUnappliedChanges', ...
      DAStudio.message('SLControllib:checkpack:errVisualizationHasUnappliedChanges',name))
else
   %Requirement tool is not dirty but the bound values could have changed from
   %the dlg or a referenced workspace variable so update the visualization
   this.updateVisualizationBounds
end
end

function localVisVisible(this,hData)
%Helper function to manage visualization visibility change events

if strcmp(hData.Newvalue,'off')
   this.PreventVisUpdate = true;
else
   this.PreventVisUpdate = false;
   this.updateVisualizationBounds;
end
end

function localApply(~,~,this)
%Helper function to manage apply button events

if this.isDirty
   this.updateBlockBounds
end
end

function localSetApply(~,~,this,hApply)
%Helper function to set apply button status based on requirement isDirty
%setting

if ~ishghandle(hApply)
   %Could be called during visualization destruction and button no longer
   %exists
   return
end
   
if this.isDirty
   set(hApply,'Enable','on');
else
   set(hApply,'Enable','off');
end
end