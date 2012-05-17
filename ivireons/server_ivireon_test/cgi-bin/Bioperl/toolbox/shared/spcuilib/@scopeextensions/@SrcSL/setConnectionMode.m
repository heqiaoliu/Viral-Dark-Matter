function setConnectionMode(this, action)
%SETCONNECTIONMODE Callback for connection mode change
%   Change between Persistent and Floating connection
%   Action may be one of:
%     'floating', 'persistent', 'button', or 'menu'

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/11/16 22:34:07 $

% This fcn is usually called due to a change in connection-mode
% button state, but we could be called to explicitly set floating
% or persistent mode as well.  So current-, button-, and/or menu-
% state may all match or differ.
%
% If action is 'button' or 'menu', map
% to 'floating' or 'persistent' actions
%

switch action
    case 'button'
        % Toggle button indicates the desired state
        if isConnModePressed(this)
            desiredState = 'persistent';
        else
            desiredState = 'floating';
        end
        
    case 'menu'
        % Menu callback means "toggle my state"
        % Find current state then request opposite
        if isFloating(this)
            desiredState = 'persistent';
        else
            desiredState = 'floating';
        end
        
    otherwise  % {'floating','persistent'}
        desiredState = action;
end

% Note: do NOT protect against changing to the 'same mode'
% Even if this.ConnectionMode is the same as currState,
% we run this code.  This is useful for "forcing" current state
% during initialization, to set button states, etc.
% Code paths are efficient when changing to same state.

switch desiredState
    case 'floating'
        % Change this instance to floating-mode

        % Turn off floating behavior from all mplayers connected
        % to this block diagram EXCEPT this instance
        m = findScopesSameBD(this, 'scopeextensions.SrcSL');
        for i=1:numel(m)
            persistentMode(m(i).DataSource);
        end
        % FloatingMode(dcsObj,true);  % set this instance to floating
        floatingMode(this);  % set this instance to floating

    case 'persistent'
        % Change this instance to persistent-mode
        %
        % Note: Since only one instance could be in floating mode
        % at a time, and we're turning off floating from this instance,
        % all other instances must be in persistent mode already.
        % No need to set them to persistent --- just this instance.
        %
        persistentMode(this); % set this instance to persistent
        
    otherwise
        % Assertion
        error(generatemsgid('InvalidConnectionMode'), ...
            'Unrecognized Simulink connection mode: %s', desiredState);
end

% --------------------------------------------
function persistentMode(this)
%PersistentMode Change current MPlayer to persistent connection mode.
%   If it is already in persistent mode, no actions are taken
%   unless FORCE is set.
%
%   We update the widgets first, so the user has positive
%   feedback on the change.

% Set new connection mode state:
this.ConnectionMode = 'persistent';

% Take care of buttons and menus
local_UpdateConnectModeWidgets(this);

this.SelectionChangeListener = [];

% --------------------------------------------
function floatingMode(this)
%FloatingMode Change current MPlayer to floating connection mode.
%   If it is already in floating mode, no actions are taken
%   unless FORCE is set.

was_floating = this.isFloating;

% Set new connection mode state:
this.ConnectionMode = 'floating';

% Take care of buttons and menus
local_UpdateConnectModeWidgets(this);

%If we were already in floating mode, nothing else to do
if ~was_floating
    hSigMgr = this.SLConnectMgr.hSignalSelectMgr;
    % Take actions to make this instance floating:
    hSigMgr.unselect('all');
    hSigMgr.select;
end

l = handle.listener(getSystemHandle(this.SLConnectMgr.hSignalSelectMgr), ...
    'SelectionChangeEvent', @(hco, ed) selectChangeEventHandler(this));
this.SelectionChangeListener = l;

% --------------------------------------------
function [buttonOn, hConnModeButton] = isConnModePressed(this)
% Return state of connection-mode button and button handle
hConnModeButton = this.Application.getGUI.findwidget('Toolbars','Playback','SimButtons','PlaybackModes','Floating');
buttonOn = strcmpi(get(hConnModeButton,'state'),'on');

% -----------------------------------------    
function local_UpdateConnectModeWidgets(this)
% Force update to pressed-state of button

switch this.ConnectionMode
    case 'floating'
        st_button='off';  % floating => button out
        st_menu='on';     %          => menu checked
    case 'persistent'
        st_button='on';   % persistent => button in
        st_menu='off';    %               menu unchecked
    otherwise
        error(generatemsgid('InvalidConnectionMode'),...
            'Unrecognized connection mode');
end
% Note: Click callback does NOT fire when manually setting state
% Note: button handle may be empty if toolbar not instantiated
hFloatButton = this.Application.getGUI.findwidget(...
    'Toolbars','Playback','SimButtons','PlaybackModes','Floating');
set(hFloatButton, 'state', st_button);

hFloatMenu = this.Application.getGUI.findwidget(...
    'Menus','Playback','SimMenus','PlaybackModes','Floating');
set(hFloatMenu, 'checked', st_menu);


% [EOF]
