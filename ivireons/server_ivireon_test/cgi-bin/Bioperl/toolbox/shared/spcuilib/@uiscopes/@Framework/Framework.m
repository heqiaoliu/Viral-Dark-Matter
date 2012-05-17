function this = Framework(hScopeCfg, scopeIndex)
%FRAMEWORK Construct a FRAMEWORK object
%   FRAMEWORK(HCFG) construct a uiscopes.Framework object based on the
%   uiscopes.AbstractScopeCfg subclass provided by HCFG.
%
%   FRAMEWORK(HCFG, INDEX) control the waitbar growth with the 2 element
%   double vector INDEX.  The first element is the current scope being
%   loaded and the second element is the total number of scopes being
%   loaded.

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.29 $  $Date: 2010/03/31 18:44:22 $

% Check that the sources are valid before even creating an object.
checkSource(hScopeCfg.ScopeCLI);

this = uiscopes.Framework;

% Record desired scope configuration
this.ScopeCfg = hScopeCfg;

showWaitbar = hScopeCfg.getShowWaitbar;

% Set up multiple scope variables.
if nargin < 2
    scopeIndex = [1 1];
    waitOffset = 0;
    waitSlope  = 1;
else
    waitOffset = (scopeIndex(1)-1)/scopeIndex(2);
    waitSlope  = 1/scopeIndex(2);
end

if scopeIndex(2) == 1
    waitbarString = 'Initializing scope ...';
else
    waitbarString = sprintf('Initializing scope %d of %d...', ...
        scopeIndex(1), scopeIndex(2));
end

persistent hWait;
if showWaitbar
    if isempty(hWait) || ~ishghandle(hWait)
        hWait = waitbar(waitOffset, waitbarString, 'name', this.getDialogTitle(true));
    else
        % Make sure that the waitbar comes to the top so that any previous
        % scopes that were brought up do not obscure it.
        figure(hWait);
        waitbar(waitOffset, hWait, waitbarString);
    end
end

% Assign global instance number
this.initInstanceNumber('alloc');

% Instantiate and configure a Message Log object
% This is an instance-specific log, not a session-wide log
% (unlike the other one in hPrefs which is going away)
msgDlg = sprintf('%s - Message Log', getDialogTitle(this));
hMessageLog = uiservices.MessageLog(msgDlg,this);

% At first, we set this to 'for warn/fail messages', until
% a config is loaded and it gets reset to whatever is specified.
hMessageLog.AutoOpenMode = 'for warn/fail messages';
this.MessageLog = hMessageLog;

if showWaitbar
    if scopeIndex(2) == 1
        lclwaitbar(waitOffset+.2*waitSlope, hWait, ...
            sprintf('Building user interface ...'));
    else
        lclwaitbar(waitOffset+.2*waitSlope, hWait);
    end
end

localCreateGUI(this);


% Create extension driver
% The following can bring up the Message Log dialog, while extensions are
% registered and success/fail/warn messages are thrown:
if showWaitbar
    if scopeIndex(2) == 1
        lclwaitbar(waitOffset+.4*waitSlope, hWait, ...
            sprintf('Initializing extensions ...'));
    else
        lclwaitbar(waitOffset+.4*waitSlope, hWait);
    end
end

if isempty(hScopeCfg.CurrentConfiguration)
    this.ExtDriver = extmgr.Driver(this, 'scopext.m', ...
        hScopeCfg.getConfigurationFile, hMessageLog);
else
    this.ExtDriver = extmgr.Driver(this, 'scopext.m', hScopeCfg.getConfigurationFile, ...
        hScopeCfg.CurrentConfiguration, hMessageLog);
end
this.ExtDriver.HiddenTypes      = hScopeCfg.getHiddenTypes;
this.ExtDriver.HiddenExtensions = hScopeCfg.getHiddenExtensions;
connect(this, this.ExtDriver, 'down');

% Done with base additions to the UI
% Render (invisibly) all widgets in the UIMgr graph
if showWaitbar
    if scopeIndex(2) == 1
        lclwaitbar(waitOffset+.6*waitSlope, hWait, ...
            sprintf('Rendering GUI ...'));
    else
        lclwaitbar(waitOffset+.6*waitSlope, hWait);
    end
end
localRender(this);

% Notify extensions that the GUI is now rendered.  This is done here
% instead of uimgr.uifigure because there is no render method at the
% uifigure level, which means that every uigroup will throw the event.  It
% will also get thrown for each incremental render unless we put a check
% for the first time which will slow down rendering.
send(this, 'Rendered');

% Initialize GUI listeners
lclDefineListeners(this);

set(findchild(getGUI(this), 'Toolbars', 'Playback'), 'Visible', 'off');

% Update the title bar.
send(this, 'UpdateTitleBarevent');

% Install the data source.
if showWaitbar
    if scopeIndex(2) == 1
        lclwaitbar(waitOffset+.8*waitSlope, hWait, ...
            sprintf('Loading Data Source ...'));
    else
        lclwaitbar(waitOffset+.8*waitSlope, hWait);
    end
end

[success, errorMsg] = this.loadSource(hScopeCfg.ScopeCLI);

% Delete the waitbar.
if showWaitbar
    if scopeIndex(1) == scopeIndex(2)
        if ishghandle(hWait)
            delete(hWait);
        end
        hWait = [];
    end
end

if ~success
    send(this, 'DataLoadedEvent', uiservices.EventData(this, 'DataLoadedEvent', false));
    if ~isempty(errorMsg)
        this.screenMsg(errorMsg);
    end
end

% -------------------------------------------------------------------------
function lclwaitbar(progress, hWait, varargin)

if isempty(hWait) || ~ishghandle(hWait)
    return;
end
waitbar(progress, hWait, varargin{:});

% -------------------------------------------------------------------------
function lclDefineListeners(this)

% Property/event listeners for side-effects
% -----------------------------------------
hListeners.PrefSrcName = handle.listener(this, ...
    'UpdateTitleBarEvent', @(h,ev) this.updateTitleBar);

% Listen for a change in data source object
%  (data source influences title bar name)
%
hListeners.DataSource = handle.listener(this, ...
    'DataSourceChanged', @(hco, ev)updateTitleBar(this));

% Event listeners for synchronization
% -----------------------------------

% Held in listener: Stop
% Name of event we listen to: StopEvent
% Disable until needed
%
hListeners.Stop = handle.listener(this, ...
    'StopEvent', '');  % dummy method
hListeners.Stop.Enabled = 'off';

% Held in listener: Pause
% Name of event we listen to: PauseEvent
% Disable until needed
%
hListeners.Pause = handle.listener(this, ...
    'PauseEvent', '');  % dummy method
hListeners.Pause.Enabled = 'off';

% Held in listener: NewSource
% Name of event we listen to: NewSourceEvent
% Disable until needed
%
hListeners.NewSource = handle.listener(this, ...
    'NewSourceEvent', '');  % dummy method
hListeners.NewSource.Enabled = 'off';

this.Listeners = hListeners;

% -------------------------------------------------------------------------
function localCreateGUI(this)
%CREATEGUI create uimgr object for scope gui

persistent icons;

if isempty(icons)
    % Create base GUI buttons, menus, statusbar, etc
    icons = spcwidgets.LoadIconFiles('audiotoolbaricons.mat', 'mplay_icons.mat', 'uiscope_icons.mat');
end

this.UIMgr = uimgr.uifigure(this.getAppName, ...
    createBaseMenus(this), ...
    createBaseToolbars, ...
    createStatusBar,...
    createKeyHelp(this));
setappdata(this.UIMgr, icons);

pos = this.ScopeCfg.Position;
if isempty(pos)
    pos = local_getInstancePos(this.InstanceNumber);
end
pos = fitPosition(pos);
this.UIMgr.Visible = 'off'; % Make figure invisible
this.UIMgr.WidgetProperties = {...
    'tag','spcui_scope_framework', ...
    'NumberTitle','off', ...
    'MenuBar','none', ...
    'Renderer','painters', ...
    'HandleVisibility','callback', ...
    'CloseRequestFcn',getCloseRequestFcn(this.ScopeCfg, this), ...
    'DeleteFcn',      @(hco,ev)close(this), ...
    'Position',       pos, ...
    'BackingStore','off', ...
    'Interruptible', 'off', ...
    'userdata', this};

% Application help installation
hCfgUI = createGUI(this.ScopeCfg, this);
if ~isempty(hCfgUI)
    if ~isa(hCfgUI, 'uimgr.uiinstaller')
        hCfgUI = uimgr.uiinstaller({hCfgUI, 'Base/Menus/Help'});
    end
    install(hCfgUI, this.UIMgr);
end

connect(this, this.UIMgr, 'down');

% -------------------------------------------------------------------------
function hm = createBaseMenus(this)

hm = uimgr.uimenugroup('Menus', ...
    createFileMenu(this), ...
    createToolsMenu, ...
    createViewMenu(this), ...
    uimgr.uimenugroup('Playback', '&Playback'), ...
    createHelpMenu(this));

% -------------------------------------------------------------------------
function file = createFileMenu(this)

% File
file = uimgr.uimenugroup('File','&File');

% File->Sources group
%  all items load as plug-in's
mSrcs = uimgr.uimenugroup('Sources');
file.add(mSrcs);

% File->File sets
%   virtual group to hold InstSet, CfgSet, etc
%   basically, any non-source items accessing files
%
% Position just after File->New
fileSets = uimgr.uimenugroup('FileSets',1);
file.add(fileSets);

local_GroupName = [appName2VarName(this) 'Preferences'];

% File-> Export
fileExport = uimgr.uimenugroup('Export');
file.add(fileExport);

% % File -> Recent data source connections
% %
mRecentSrcsItems = uimgr.uimenugroup('RecentSourceItems','<dummy>');
file.add(mRecentSrcsItems);

% Attach recentitemslist object to items menu
mRecentSrcsRFL = uimgr.uirecentitemslist( ...
    local_GroupName, 'RecentSources');
mRecentSrcsItems.add(mRecentSrcsRFL);

% File->Close group
fileClose = uimgr.uimenu('Close','&Close');
fileClose.WidgetProperties = {...
    'accel','w', ...
    'callback', getCloseRequestFcn(this.ScopeCfg, this)};
fileCloseAll = uimgr.uimenu('CloseAll',sprintf('Close &All %s Windows', getAppName(this, true)));
fileCloseAll.WidgetProperties = {...
    'callback', @(hco,ev) uiscopes.close('all', this.ScopeCfg)};
fileClose = uimgr.uimenugroup('Close',fileClose,fileCloseAll);
add(file,fileClose);


% -------------------------------------------------------------------------
function mTools = createToolsMenu
%
% Setup of submenu system:
%
% Tools group
%   Standard group (pos 1)
%      VideoInfo
%      Colormap

% Main Tools menu
mTools = uimgr.uimenugroup('Tools','&Tools');


% -------------------------------------------------------------------------
function mView = createViewMenu(this)

% View
mView = uimgr.uimenugroup('View','&View');

% Wants its own separator:
mFwd = uimgr.uimenu('BringFwd', 5, sprintf('Bring All %s Windows &Forward', getAppName(this, true)));

mFwd.WidgetProperties = {...
    'accel','F', ...
    'callback', @(hco,ev)uiscopes.show('all', this.ScopeCfg)};
mView.add(mFwd);

% -------------------------------------------------------------------------
function mHelp = createHelpMenu(this)

mKeyCmd = uimgr.uimenu('KeyCmd', '&Keyboard Command Help');
mKeyCmd.WidgetProperties = {...,
    'callback', @(hco,ev)show(this.getGUI.findwidget('KeyMgr'))};

mMsgLog = uimgr.uimenu('MsgLog', '&Message Log');
mMsgLog.WidgetProperties = {...,
    'accel','m',...
    'callback', @(hco,ev) show(this.MessageLog) };

mHelp = uimgr.uimenugroup('Help', '&Help', ...
    uimgr.uimenugroup('Application'), ...
    uimgr.uimenugroup('Main', mKeyCmd,mMsgLog), ...
    uimgr.uimenugroup('Demo'), ...
    uimgr.uimenugroup('About'));


% -------------------------------------------------------------------------
function h = createBaseToolbars

h = uimgr.uitoolbargroup('Toolbars', ...
    createMainToolbar, ...
    createPlaybackToolbar);

% -------------------------------------------------------------------------
function hTB = createMainToolbar
% Define uitoolbar buttons

hTB = uimgr.uitoolbar('Main',...
    uimgr.uibuttongroup('Sources'), ...
    uimgr.uibuttongroup('Export'), ...
    uimgr.uibuttongroup('Tools', uimgr.uibuttongroup('Standard')));

% -------------------------------------------------------------------------
function hTB = createPlaybackToolbar

hTB = uimgr.uitoolbar('Playback');
hTB.WidgetProperties = {'Visible', 'off'};

% -------------------------------------------------------------------------
function hs = createStatusBar

% Create status bar
hs = uimgr.uistatusbar('StatusBar',@status_mainbar);

% Create status options
ho2 = uimgr.uistatus('Rate', @status_opt_rate);
ho2.WidgetProperties = {'Tooltip', 'Frame rate'};
ho3 = uimgr.uistatus('Frame',@status_opt_frame);
hStdOpts = uimgr.uistatusgroup('StdOpts',ho2,ho3);
hs.add(hStdOpts);

% -------------------------------------------------------------------------
function h = status_mainbar(h)

% Turn off the grab bar for now.  The graphic does not actually allow you
% to "grab". g373221
h = spcwidgets.StatusBar(h.GraphicalParent, 'GrabBar', 'off', 'Tag', h.Name); 

% -------------------------------------------------------------------------
function y = status_opt_rate(h)
y = spcwidgets.Status(h.GraphicalParent, ...
    'Width', 80*getPixF, 'tag', [h.Name 'Status']);

% -------------------------------------------------------------------------
function y = status_opt_frame(h)
y = spcwidgets.Status(h.GraphicalParent, ...    
    'Width', 60*getPixF, 'tag', [h.Name 'Status']);

% -------------------------------------------------------------------------
function pixf = getPixF

if ispc
    pixf = 1;
else
    pixf = 1.3;
end
    

% -------------------------------------------------------------------------
function hKeyMgr = createKeyHelp(this)

hKeyMgr = uimgr.spckeymgr('KeyMgr');
hKeyCommon = uimgr.spckeygroup('Common');
hKeyMgr.add(hKeyCommon);
hKeyCommon.add(...
    uimgr.spckeybinding('configure','N',...
    @(h,ev) this.ExtDriver.editConfigSet, 'Change configuration'),...
    uimgr.spckeybinding('keyboardhelp', 'K',...
    @(h,ev)show(this.getGUI.findwidget('KeyMgr')), 'Display keyboard help'));

% -------------------------------------------------------------------------
function localRender(this)

% Render the UI (invisibly) before adding video display
% to flow container ... the video display is not a UIMgr
% component and does not work with deferred rendering
render(this.UIMgr);

set(this.UIMgr.hVisParent, 'ResizeFcn', makeOnVisualResizeFcn(this));

hFig = this.UIMgr.WidgetHandle;

% Handle docked/undocked figure creation
% Setup docking group name, in case window is docked
% at some point in the future
%
% Specify docking frame to be named 'Sinks'
 
% store the last warning thrown 
[lastWarnMsg lastWarnId ] = lastwarn; 
oldstate = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame'); 
jf = get(hFig,'javaframe');
warning(oldstate.state,'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame'); 
% restore the last warning thrown 
lastwarn(lastWarnMsg, lastWarnId); 

% For example running through Xoftware Java Figures are not present
if ~isempty(jf)
    jf.setGroupName('Scopes');
end

if isDocked(this.ScopeCfg)
    set(hFig,'WindowStyle','docked');
else
    set(hFig,'WindowStyle','normal');
end

addlistener(hFig, 'WindowStyle', 'PostSet', makeWindowStyleListenerCallback(hFig));

% -------------------------------------------------------------------------
function cb = makeOnVisualResizeFcn(this)

cb = @(h, ev) onVisualResize(this, h);

% -------------------------------------------------------------------------
function onVisualResize(this, h)

position = getpixelposition(h);

% Just get the width and the height, no need for the x and the y.
size = position(3:4);

send(this, 'VisualResized', ...
    uiscopes.VisualResizedEventData(this, 'VisualResized', h, size));

% -------------------------------------------------------------------------
function instancePos = local_getInstancePos(instance)
% Return position of new MPlay figure, in pixels,
% based on GUI instance number

% Define default position and size of GUI window when it first opens,
% in pixels
% Depending on the instance number, move the window position up/right,
% wrapping coords around the boundary of the screen

% Get screen size in pixels
origUnits = get(0,'units');
set(0,'units','pix');
screenSize = get(0,'screenSize');
screenSize = screenSize(3:4);  % [width height]
set(0,'units',origUnits);

% Define default size of MPlay window
% (that is, prior to the resize event changing window size
%  due to fit-to-view, magnification, etc)
defaultSize = [410 300];  % [width height]

scheme = 'short_diagonal';
switch scheme
    case 'short_diagonal'
        % Use a grid of 6 coordinates in the screen.
        % Grid goes diagonal to the right and down.

        % 5-element grid, idx is [-2, 2]
        idx = rem(instance-1,5)-2;

        % Compute lower left corner of center UI location
        startForCenter = (screenSize-defaultSize)/2;

        % Nudge the vertical extent a bit
        % Why? The toolbars and menus take room that is
        % unaccounted for in the estimates
        startForCenter(2)=startForCenter(2)-46;

        % Nominal [50 -50] grid offset, [dhoriz dvert]
        instanceOffset = [50 -50];

        % Shrink vertical delta for small screen sizes
        %   (tested on 800x600, 1024x768, 1280x1024, and 1400x1050)
        %instanceOffset = [50 -min( ...
        %             (screenSize(2)-defaultSize(2)-100)/2/5, ...
        %             50)];

        % Perform a skew on the x,y coords and scale to pixels
        % Backup half the total number of figures in pattern,
        % to have center of screen lie on instance 3
        instanceXY = startForCenter + [idx idx].*instanceOffset;
        instancePos = [instanceXY defaultSize];

    case 'skew_grid'
        % Use a virtual 3x3 grid skewed grid centered in the screen,
        % with the 1st instance occupying the start of the 2nd row.
        % Grid skew goes right and down.

        % 3x3 grid yields 9 locations, with center at index 5 (using
        % 1-based indices).  We must offset the 1-based UI instance number
        % by 3 to get the 1st instance at index 4 - the start of the 2nd
        % row of this grid.  To do modulo-9, we decrement by 1 then add it
        % back - making the initial offset 2:
        idx = rem(instance+2,9)+1;  % 1 to 9, start at 4

        % Compute lower left corner of center UI location
        centerXY = (screenSize-defaultSize)/2;

        % Find XY of this instance
        [ix,iy] = ind2sub([3 3],idx);

        % Nominal [50 -50] grid offset, [dhoriz dvert]
        %   but shrink vertical delta for small screen sizes
        %   (tested on 800x600, 1024x768, 1280x1024, and 1400x1050)
        instanceOffset = [50 -min( ...
            (screenSize(2)-defaultSize(2)-100)/2/5, ...
            50)];
        % Perform a skew on the x,y coords and scale to pixels
        % instanceXY = centerXY + [(ix-3)+(iy-1) (ix-3)-1+(iy-1)*3].*instanceOffset;
        instanceXY = centerXY + [ix+iy-4 ix+3*iy-7].*instanceOffset;
        instancePos = [instanceXY defaultSize];

    case 'bottom_up'
        % Open in lower left, build up and right,
        % wrapping when we meet the screen edges
        %
        defaultXY   = [50 60]; % lower left corner of fig
        instanceOff = [40 40]; % how much to move each new instance
        instanceXY  = defaultXY + (instance-1).*instanceOff; % must wrap coords
        maxXY       = screenSize-defaultXY-defaultSize; % dx,dy
        instanceXY   = rem(instanceXY-1, maxXY)+1;
        instancePos = [instanceXY defaultSize];
end

% -------------------------------------------------------------------------
function figPos = fitPosition(figPos)

origUnits = get(0, 'Units');
set(0, 'Units', 'Pixels');
monitors = get(0, 'MonitorPositions'); % [left bottom width height] in pixels
set(0, 'Units', origUnits);   % restore the resolution settings

% Check that the scope fits into one of the monitors
fits = false;
for indx = 1:size(monitors, 1)
    if figPos(1) + figPos(3) > monitors(indx, 1) && ...
            figPos(1) < monitors(indx, 3) && ...
            figPos(2) + figPos(4) > monitors(indx, 2) && ...
            figPos(2) < monitors(indx, 4)
        fits = true;
    end
end

% If the window doesn't on any monitor, place it in the middle of the
% "main" monitor.
if ~fits
    figPos(1) = floor((monitors(1,3)-figPos(3))/2);
    figPos(2) = floor((monitors(1,4)-figPos(4))/2);
end

% -------------------------------------------------------------------------
function cb = makeWindowStyleListenerCallback(hFig)

cb = @(h, ev) windowStyleListenerCallback(hFig);

% -------------------------------------------------------------------------
function windowStyleListenerCallback(hFig)

if ~strcmp(get(hFig, 'WindowStyle'), 'docked')
    plotedit(hFig, 'off');
end

% [EOF]
