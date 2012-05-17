function stopInteractiveLab()
; %#ok Undocumented
%stopInteractiveLab  Stop pmode on the labs.

%   Copyright 2006-2008 The MathWorks, Inc.

try
    serv = distcomp.getInteractiveObject();
    % Perform a complete cleanup of the Pmode M and java code on the lab.
    serv.stopLabAndDisconnect();
catch err
    dctSchedulerMessage(1, 'Error message from stopLabAndDisconnect: %s', ...
                        err.message);
end

try
    % In Pmode, we want to ensure that we don't leave anything lying around in the
    % base workspace. We do this at the end of the session to ensure that we
    % don't leave MATLAB processes with large workspaces. (NB that usual
    % behaviour is not to clear up the workspace)
    evalin('base', 'clear');
catch err
    dctSchedulerMessage(1, 'Error message from clearing base workspace: %s', ...
                        err.message);
end

% Return the worker back to the pool.
dctFinishInteractiveSession;

