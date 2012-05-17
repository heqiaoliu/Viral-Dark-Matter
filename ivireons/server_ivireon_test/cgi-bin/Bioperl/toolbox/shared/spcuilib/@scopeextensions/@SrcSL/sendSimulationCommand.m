function sendSimulationCommand(this, cmd)
%SENDSIMULATIONCOMMAND 

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/03/31 18:42:22 $

if isempty(this.SLConnectMgr)
    return
end

this.SLConnectMgr.sendCommand(cmd);

% In External mode, finish the job for events that Simulink does not send
% move to base class later
bd = getParentModel(this);
if ~isempty(bd) && strcmp(bd.SimulationMode,'external')
     SendEventsToAllSameBD(this, cmd);
end
% [EOF]
