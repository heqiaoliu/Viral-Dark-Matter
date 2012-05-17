function stopEventHandler(this, event) %#ok
%STOPEVENTHANDLER React to Simulink's StopEvent.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2010/03/31 18:42:25 $

this.RawDataCache = getRawData(this);

if ~isempty(this.SLConnectMgr)
    unsubscribeToData(this.SLConnectMgr);
end

% On model stop, we reset .StepFwd mode
% This way, the next "play" command causes the
% simulation to run without single-stepping
this.StepFwd = false;

% Turn off snapshot as well
% Keeping it on would provide an all-black screen
% when the model restarts
this.SnapShotMode = false;  % turn off snapshot explicitly

stopVisualUpdater(this);

% [EOF]
