function lab2client(obj, labvarname, labidx, clientvarname) %#ok obj unused.
; %#ok Undocumented
%lab2client Client code to transfers a variable from lab to client.
%   Caller should have made sure that lab is an integer, and that
%   isvarname(clientvarname) and isvarname(labvarname) return true.

%   Copyright 2006-2008 The MathWorks, Inc.

import com.mathworks.toolbox.distcomp.pmode.SessionFactory;

try
    session = SessionFactory.getCurrentSession();
    labs = session.getLabs();
    transfer = session.getTransfer();
    manager = transfer.getTransferManager();
    receiver = transfer.getDataReceiver();
    % Prepare the tracker and receiver objects for the transfer.
    % Note: During debug sessions, you must overwrite the value of the following
    % variable, otherwise the labs will halt the transfer on your first
    % breakpoint.
    isDebugging = false;
    monitor = manager.initiateTransfer(receiver, labidx, isDebugging);
catch
    error('distcomp:pmode:PmodeNotRunning', 'Pmode is currently not running');
end

try 
    % Execute lab2client on all the labs to start the send.
    cmd = sprintf('distcomp.lab2client(%d, ''%s'', %d);', ...
                  monitor.getTransferSeqNumber(), labvarname, labidx);
    labs.eval(cmd, monitor.getLabsCompletionObserver());  
catch err
  monitor.setLocalMError(err.identifier, err.message);
  rethrow(err);
end
    
% At this point, the data receive operation is identical to that when
% the lab is sending data to a client, so let a package method do the receive.
serializedValue = distcomp.doInteractiveReceive(receiver, monitor);

try
    out = distcompdeserialize(serializedValue);
    assignin('base', clientvarname, out);
catch
    errID = 'distcomp:pmode:TransferFailed';
    errMsg = sprintf('Failed to store the variable %s on the client.', ...
                  clientvarname);
    monitor.setLocalMError(errID, errMsg);
    error(errID, errMsg); %#ok Using errMsg twice.
end

%
% We are now done, and have to wait till the remote side is done.
monitor.setLocalFinished();
iLoopUntilErrorOrTrue(monitor, @() monitor.isRemoteFinished());    

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function iLoopUntilErrorOrTrue(monitor, func)
% This function only returns normally when func returns true is true and there
% are no errors.
while true
    err = monitor.getOutsideLocalMError();
    if ~isempty(err)
        error(char(err.getErrorIdentifier()), char(err.getErrorMessage()));
    end
    if func()
        break;
    end
    pause(0.01);
end
