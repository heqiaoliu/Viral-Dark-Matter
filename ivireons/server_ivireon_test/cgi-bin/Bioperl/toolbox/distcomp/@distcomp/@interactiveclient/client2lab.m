function client2lab(obj, clientvarname, labidxes, labvarname) %#ok obj never used.
; %#ok Undocumented
%client2lab Client code to transfer a serializable variable to labs.
%   Caller should have made sure that:
%   - labidxes is a vector of integers
%   - isvarname(clientvarname) and isvarname(labvarname) return true
%   - pmode is currently running

%   Copyright 2006 The MathWorks, Inc.

import com.mathworks.toolbox.distcomp.pmode.SessionFactory;

% Verify that the variable exists in the base workspace.
if ~evalin('base', sprintf('exist(''%s'', ''var'')', clientvarname))
    error('distcomp:pmode:UndefinedVariable', ...
        'Variable %s is undefined.', clientvarname);
end

% Only send to one of the labs.  It will then use MPI to send to the others.
firstLab = min(labidxes);
try
    session = SessionFactory.getCurrentSession();
    labs = session.getLabs();
    transfer = session.getTransfer();
    sender = transfer.getDataSender();
    manager = transfer.getTransferManager();
    % Prepare the tracker and sender objects for the transfer.
    % Note: During debug sessions, you must overwrite the value of the following
    % variable, otherwise the labs will halt the transfer on your first
    % breakpoint.
    isDebugging = false;
    monitor = manager.initiateTransfer(sender, firstLab, isDebugging);
catch
    error('distcomp:pmode:PmodeNotRunning', 'Pmode is currently not running');
end

% Create error messages that are specific to a transfer from client to lab.
errorMsgStruct = struct('undefinedVariable', ...
                        sprintf('Variable %s is undefined in the MATLAB client.', ...
                                clientvarname), ...
                        'failedToSerialize', ...
                        sprintf('Could not serialize the variable %s.', ...
                                clientvarname));

% Execute distcomp.client2lab on all the labs.  This will cause firstLab to
% send us a "ok to start sending" message.
cmd = sprintf('distcomp.client2lab(%s, [ %s ], ''%s'');', ...
              num2str(monitor.getTransferSeqNumber()), ...
              num2str(labidxes), labvarname);
labs.eval(cmd, monitor.getLabsCompletionObserver()); 

% From this point onwards, the data send operation is identical to that when
% the client is sending data to a lab, so let a package method do the sending.
distcomp.doInteractiveSend(clientvarname, sender, monitor, errorMsgStruct);
