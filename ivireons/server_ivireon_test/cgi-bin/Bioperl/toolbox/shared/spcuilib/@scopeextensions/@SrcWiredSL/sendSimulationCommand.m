function sendSimulationCommand(this, simcmd)
%SENDSIMULATIONCOMMAND sends a simulation command to the model.
%   OUT = SENDSIMULATIONCOMMAND(ARGS) <long description>

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/11/16 22:34:16 $

parentmdlObj = getParentModel(this);
parentmdl = parentmdlObj.Name;
% Process step-forward mode
% Note 1: always execute, even if snapshot is turned on
% Note 2: the "isa" check protects us from an empty Source that is "pulled
%         out from under us" if Scope is closed or Simulink Source is
%         disabled while connected and running with Simulink concurrently
%         the reason we check this one, and not the earlier access, is that
%         MATLAB can process code one when HG updates the image and the
%         only Source access after that point is here.


set_param(parentmdl,'SimulationCommand',simcmd);

% In External mode, finish the job for events that Simulink does not send
bd = getParentModel(this);
if strcmp(bd.SimulationMode,'external')
     SendEventsToAllSameBD(this, simcmd);
end
 
end
% [EOF]
