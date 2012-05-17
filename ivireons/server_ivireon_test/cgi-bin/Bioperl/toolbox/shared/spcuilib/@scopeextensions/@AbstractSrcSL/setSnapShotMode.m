function setSnapShotMode(this, action)
%SETSNAPSHOTMODE Callback for snapshot mode change
%   Change between snapshot on and off
%   Action may be one of:
%     'on', 'off', 'button', or 'menu'

% Copyright 2004-2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2010/03/31 18:41:08 $

% This fcn is usually called due to a change in snapshot-mode
% button state, but we could be called to explicitly set snapshot
% mode as well.  So current-, button-, and/or menu-
% state may all match or differ.
%
% If action is 'button' or 'menu', map
% to 'on' or 'off' actions
%
switch action
    case 'button'
        % Toggle button indicates the desired state
        if local_isSnapshotButtonPressed(this)
            desiredState = 'on';
        else
            desiredState = 'off';
        end
        
    case 'menu'
        % Menu callback means "toggle my state"
        % Find current state then request opposite
        if this.SnapShot
            desiredState = 'off';
        else
            desiredState = 'on';
        end
        
    case {'on','off'}
        desiredState = action;
        
    otherwise
        error(generatemsgid('InvalidSnapshotState'), ...
            'Unrecognized snapshot state: %s', action);
end

local_SetSnapshotMode(this,desiredState);

% --------------------------------------------
function local_SetSnapshotMode(this,state)
%SnapshotMode Change current MPlayer to snapshot mode.
%   If it is already in snapshot mode, no actions are taken.

% Take care of button bar
%
% Always make sure button is in proper state
% Note: this could be called before playbackControls are instantiated
%       (e.g., when first instantiating a dcsObj, but before installing
%       it into MPlay) ... so hSnapButton may be empty.
controls = this.controls;
hSnapButton = this.Application.getGUI.findwidget(...
    'Toolbars','Playback','SimButtons','PlaybackModes','Snapshot');
set(hSnapButton, 'enable','on', 'state',state);

% Take care of menu item
%
hSnapMenu = this.Application.getGUI.findwidget(...
    'Menus','Playback','Playback','PlaybackModes','Snapshot');
set(hSnapButton, 'enable','on', 'state',state);
set(hSnapMenu,'checked',state);

% Set snapshot state:
this.SnapShotMode = strcmpi(state,'on');

% Adjust status text; relies on .SnapShot property
if this.Application.DataSource == this
    update(controls);
end

% --------------------------------------------
function buttonInSnapMode = local_isSnapshotButtonPressed(this)
% Return state of snapshot-mode button and button handle

hSnapButton = this.Controls.UIMgr.findwidget('Toolbars','Playback','SimButtons','PlaybackModes','Snapshot');
buttonInSnapMode = strcmpi(get(hSnapButton,'state'),'on');

% [EOF]
