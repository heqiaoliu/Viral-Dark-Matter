function plugInGUI = createGUI(this)
%

% Author(s): A. Stothert 29-Jan-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.3.2.1 $ $Date: 2010/06/24 19:43:39 $

% CREATEGUI  create GUI components
%

%% Edit menu properties
mEdit = uimgr.uimenugroup('Edit',0,DAStudio.message('SLControllib:checkpack:menuEdit'));
grpUndoRedo = uimgr.uimenugroup('grpUndoRedo');
grpUndoRedo.Visible = 'off';
mUndo = uimgr.uimenu('Undo', 1, DAStudio.message('SLControllib:checkpack:menuUndo'));
mUndo.WidgetProperties = {'callback', @(hSrc, hData) localUndo(this)};
mUndo.Enable = 'off';
mRedo = uimgr.uimenu('Redo', 1, DAStudio.message('SLControllib:checkpack:menuRedo'));
mRedo.WidgetProperties = {'callback', @(hSrc, hData) localRedo(this)};
mRedo.Enable = 'off';
grpUndoRedo.add(mUndo, mRedo);
grpAxProp = uimgr.uimenugroup('grpAxProp',99);
mAxProp = uimgr.uimenu('AxesProp',1, DAStudio.message('SLControllib:checkpack:menuAxProp'));
mAxProp.WidgetProperties = {...
   'callback', @(hSrc,hData) localAxProp(this)};
grpAxProp.add(mAxProp);
grpAssert = uimgr.uimenugroup('grpAssertion');
mAssertProps = uimgr.uimenu('Properties', 1, DAStudio.message('SLControllib:checkpack:menuAssertionProperties'));
mAssertProps.WidgetProperties = {'callback', @(hSrc,hData) showDlgTab(this,'tabAssertion')};
grpAssert.add(mAssertProps)
mEdit.add(grpAssert,grpAxProp);

%% View menu properties
mOpenDlg = uimgr.uimenu('OpenDlg', inf, DAStudio.message('SLControllib:checkpack:menuOpenDlg'));
mOpenDlg.WidgetProperties = {'callback', @(hSrc, hData) localOpenDlg(this)};

%% Toolbar buttons
bOpenDlg = uimgr.uipushtool('OpenDlg', -2);
icons = getappdata(this.Application.UIMgr);
if ~isfield(icons,'open_check_block_dlg')
   icons.open_check_block_dlg = imread(fullfile(matlabroot,'toolbox','slcontrol','slctrlutil','resources','open_check_block_dlg.bmp'));
   setappdata(this.Application.UIMgr,icons);
end
bOpenDlg.IconAppData = 'open_check_block_dlg';
bOpenDlg.Enable = 'on';
bOpenDlg.WidgetProperties = { ...
   'tooltip', DAStudio.message('SLControllib:checkpack:menuOpenDlg'), ...
   'click',   @(hSrc, hData) localOpenDlg(this)};

% Create default GUI plan
plan = {...
   mEdit,    'Base/Menus'; ...
   mOpenDlg, 'Base/Menus/View'; ...
   bOpenDlg, 'Base/Toolbars/Playback'};

% Add any subclass GUI plans and widgets
[addPlan,addEdit] = this.createGUIPlan;
plan = vertcat(plan, addPlan);
if ~isempty(addEdit)
   mEdit.add(addEdit{:})
end

%Create plug-in installer from plan
plugInGUI = uimgr.uiinstaller(plan);
end

function localAxProp(this)
%Helper function to open axes property editor

propEditor(this);
end

function localUndo(this)
%Helper function to manage undo actions

disp('*** Undo');
end

function localRedo(this)
%Helper function to manage redo actions

disp('*** Redo')
end

function localOpenDlg(this)
%Helper function to open block dialog

blk = getFullName(this.Application.DataSource.BlockHandle);
open_system(blk,'mask')
end