function disconnectState(this,skipPersistent)
%DISCONNECTSTATE Disconnect a Simulink persistent connection

% Copyright 2004-2010 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2010/03/31 18:42:12 $

% Stop simulator event callbacks (run/stop/etc)
if ~isempty(this.SLConnectMgr)
    if this.StepFwd        
        % If we are stepping forward, but we have a bad setup, enable the
        % RTO listeners and disconnect on the next update.  During that
        % update, perform the pause and call back into this function to
        % perform the actual disconnect.  If there are no RTO listeners
        % then the block we are connected to is not supported.  In this
        % case, add a listener to the Running event on the model and pause
        % as soon as we start running.
        if isempty(this.SLConnectMgr.hSignalData.rtoListeners)

            % If the model is already running just do the fix up now,
            % otherwise use a listener.
            if strcmp(get(this.SLConnectMgr.getSystemHandle, 'SimulationStatus'), 'running')
                stepFixUp(this);
            else
                this.EngineSimStatusRunningListener = ...
                    handle.listener(this.SLConnectMgr.hSignalSelectMgr.getSystemHandle, ...
                    'EngineSimStatusRunning', @(h,ev) stepFixUp(this));
            end
        else
            enableData(this);
        end
        return;
    else
        this.SLConnectMgr.unsubscribeToEvent;
        
        % Stop data stream
        this.SLConnectMgr.unsubscribeToData;
    end
end

% Reset the connection mode back to persistent, in
% case it was floating.  Prevents unintentional reconnects
% to the currently selected object after the disconnect.
if (nargin<2) || ~skipPersistent
    this.setConnectionMode('persistent');
end

% Disable the simulink tools (buttons/menus)
enable(this.controls, false);
updateConnectButton(this,'disconnect');

% -------------------------------------------------------------------------
function stepFixUp(this)

% Pause the model to give the impression of a step.
pause(this.Controls);

disconnectState(this);

% Clear out the listener.
this.EngineSimStatusRunningListener = [];

% [EOF]
