function continueEventHandler(this, event)
%CONTINUEEVENTHANDLER React to the ContinueEvent.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2010/03/31 18:42:11 $

% Note: if we attach to a model already in the pause state then continue
%       the simulation, we never execute the runFcn and never fully attach
%       (you'll see the "no data available" message always).
% Solution:
%   when continueFcn runs, see if we've ever run the runFcn
%   if not, call it now.
% Implementation:
%   if RTO is empty, we likely need to try the runFcn
%   if that's not the issue, no matter - no harm
%
%   If we are floating and the signal selected has changed, call the runFcn

startVisualUpdater(this);

if ~isempty(this.InstallOnRun)
    % If InstallOnRun is true, we need to perform the connect operation.
    selectChangeEventHandler(this, event);
elseif isempty(this.SLConnectMgr.getSignalData.rto)
    
    % If there are no RTOs installed, continue is the same as run.
    runEventHandler(this, event);
elseif strcmp(this.ConnectionMode, 'floating')
    
    % Construct the default SignalSelect and see if it matches the current
    % state of the source.
    h = slmgr.SignalSelectMgr;
    if ~isequal(h.commandLineArgs, this.commandLineArgs) || isempty(this.SLConnectMgr.hDataSink)
        runEventHandler(this, event);
    end
end

% If continue coming from Simulink model itself,
% turn off step-forward behavior.  The MPlay buttons
% take care of this themselves in slPlayPause
if ~this.PlayPauseButton
    this.StepFwd = false;
end


% [EOF]
