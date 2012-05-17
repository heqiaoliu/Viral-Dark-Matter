function plugInGUI = createGUI(this)
%CreateGUI Build and cache UI plug-in for base UserIntfExt plug-in.
%   UserIntfExt takes care of the following GUI elements:
%     - Configuration edit/save/load (menu and toolbar)

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.11 $ $Date: 2010/01/25 22:47:48 $

% Create UI elements
showNewAction = this.findProp('ShowNewAction').Value;

% File->New
appName = this.Application.getAppName(true);

if showNewAction
    mNew = uimgr.uimenu('New', ['&New ', appName]);
    mNew.Placement = -inf;
    mNew.WidgetProperties = {...
        'accel',    'n',...
        'callback', @(hco,ev) createInstance(this.Application)};
    
    % New toolbar button
    tNew = uimgr.uipushtool('New',0);
    tNew.Placement = -inf;
    tNew.IconAppData = 'newdoc';
    tNew.WidgetProperties = { ...
        'tooltip', ['New ' appName], ...
        'click',   @(hco,ev) createInstance(this.Application)};

    str = ['Open new ',this.Application.getAppName(true)];
    kNew = uimgr.spckeybinding('new','insert',...
        @(h,ev)createInstance(this.Application), str);
    kNew.Placement = -10;

end

% Create File->Configuration menus
%
%  Edit | Load, Save | <recent sets>
%
% Setup top-level Configuration menu
% Position before Instrumentation Sets (which is 1)
mCfgSet = uimgr.uimenugroup('Configs', 0, uiscopes.message('ConfigurationCascadeMenu'));

mCfgSetEdit = uimgr.uimenu('CfgSetEdit','&Edit ...');
% call editCfgSet(hExtDriver) when invoked:
% call showPropDialog(hExtDriver) when invoked:
mCfgSetEdit.WidgetProperties = { ...
    'Interruptible', 'off', ...
    'callback', @(hco,ev)editConfigSet(this.Application.ExtDriver) };

mCfgSetLoad = uimgr.uimenu('CfgSetLoad','&Load ...');
% call loadCfgSet(hExtDriver) when invoked:
mCfgSetLoad.WidgetProperties = {...
    'callback', @(hco,ev)lclLoadConfigSet(this)};

mCfgSetSave = uimgr.uimenu('CfgSetSave','Save &As...');
% call saveCfgSet(hExtDriver) when invoked:
mCfgSetSave.WidgetProperties = {...
    'callback', @(hco,ev) lclSaveConfigSetAs(this)};

% Setup group just for Load/Save
mCfgSetLoadSave = uimgr.uimenugroup('CfgSetLoadSave',mCfgSetLoad, mCfgSetSave);

% Setup group for containing multiple recent config set items
mCfgSetItems = uimgr.uimenugroup('CfgSetItems','<dummy>');  % just one for now
mCfgSetRecentFiles = uimgr.uimenugroup('CfgSetRecentFiles',mCfgSetItems);

% Put all of config-set-handling items together and add to MATLAB file menu
mCfgSet.add(mCfgSetEdit,mCfgSetLoadSave,mCfgSetRecentFiles);

% Attach recentfileslist object to items menu
mCfgSetRFL = uimgr.uirecentitemslist('ConfigPreferences','CfgSetRecentSets');
mCfgSetItems.add(mCfgSetRFL);

% Create toolbar visibility menu controls
mViewTbar = uimgr.spctogglemenu('ShowMainToolbar',1,'Toolbar');
mViewTbar.WidgetProperties = {...,
    'checked', logical2checked(this.findProp('ShowMainToolbar').Value),...
    'callback',@(hco,ev)mainToolbarToggle(this)};

mViewPlayTbar = uimgr.spctogglemenu('ShowPlaybackToolbar',2,'Playback Toolbar');
mViewPlayTbar.WidgetProperties = {...
    'checked', logical2checked(this.findProp('ShowPlaybackToolbar').Value),...
    'callback',@(hco,ev)playbackToolbarToggle(this)};

if this.Application.ScopeCfg.hideStatusBar
    visState = 'off';
else
    visState = 'on';
end
mViewStatusTbar = uimgr.spctogglemenu('ShowStatusBar',3, 'Status Bar');
mViewStatusTbar.Visible = visState;
mViewStatusTbar.WidgetProperties = {...,
    'checked', logical2checked(this.findProp('ShowStatusbar').Value),...
    'callback',@(hco,ev)statusbarToggle(this)};

mViewTbar = uimgr.uimenugroup(...
    'ViewBars', mViewTbar,mViewPlayTbar,mViewStatusTbar);

plan = {...
    mCfgSet,   'Base/Menus/File/FileSets'; ...
    mViewTbar, 'Base/Menus/View'};

if showNewAction
    plan = [{...
        mNew, 'Base/Menus/File'; ...
        tNew, 'Base/Toolbars/Main'; ...
        kNew, 'Base/KeyMgr/Common'};
        plan];
end

plugInGUI = uimgr.uiinstaller(plan);

% -------------------------------------------------------------------------
function lclSaveConfigSetAs(this)

try
    hDriver = this.Application.ExtDriver;
    [saved, config] = saveConfigSetAs(hDriver);
    if saved
        this.addRecentConfig(config);
    end
catch e
    uiscopes.errorHandler(uiservices.cleanErrorMessage(e));
end

% -------------------------------------------------------------------------
function lclLoadConfigSet(this)

try
    hDriver = this.Application.ExtDriver;
    [loaded, config] = loadConfigSet(hDriver);
    if loaded
        this.addRecentConfig(config);
    end
catch e
    uiscopes.errorHandler(uiservices.cleanErrorMessage(e));
end

% -------------------------------------------------------------------------
function mainToolbarToggle(this)
%MAINTOOLBARTOGGLE Turn on/off main toolbar

hProp = this.findProp('ShowMainToolbar');
hProp.Value = ~hProp.Value;

% -------------------------------------------------------------------------
function playbackToolbarToggle(this)
%PLAYBACKTOOLBARTOGGLE Turn on/off options toolbar

hProp = this.findProp('ShowPlaybackToolbar');
hProp.Value = ~hProp.Value;

% -------------------------------------------------------------------------
function statusbarToggle(this)
%STATUSBARTOGGLE Turn on/off status toolbar

hProp = this.findProp('ShowStatusbar');
hProp.Value = ~hProp.Value;

% -------------------------------------------------------------------------
function checkState = logical2checked(value)

if value
    checkState = 'on';
else
    checkState = 'off';
end

% [EOF]
