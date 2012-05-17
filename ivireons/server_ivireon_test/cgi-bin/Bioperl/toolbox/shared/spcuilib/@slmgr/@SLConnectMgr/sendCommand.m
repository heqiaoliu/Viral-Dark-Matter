function sendCommand(this, cmd)
%SENDCOMMAND send simulation commands to simulink model
%   OUT = SENDCOMMAND(ARGS) <long description>

%   Author(s): J. Yu
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/01/25 22:47:08 $

%g347498 turn the warning off/on. The reduction mode will be captured later
warnstate = warning; warning('off'); %#ok
try 
    set_param(this.hSignalSelectMgr.getSystemHandle.handle, ...
        'simulationcommand',cmd);
catch e
    warning(warnstate);
    rethrow(e);
end
warning(warnstate);

% [EOF]
