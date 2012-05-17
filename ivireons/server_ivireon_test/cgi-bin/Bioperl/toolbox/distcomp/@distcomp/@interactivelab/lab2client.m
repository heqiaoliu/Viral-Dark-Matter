function lab2client(obj, transferSeqNumber, labvarname, labidx) %#ok obj not used.
; %#ok Undocumented
%lab2client Lab code to transfer a variable from lab to client.
%   Caller should have made sure that lab is an integer, and that
%   isvarname(labvarname) returns true.

%   Copyright 2006 The MathWorks, Inc.

import com.mathworks.toolbox.distcomp.pmode.SessionFactory;

if labindex ~= labidx
    return;
end

% Initialize the transfer objects.
try
    session = SessionFactory.getCurrentSession();
    transfer = session.getTransfer();
    manager = transfer.getTransferManager();
    sender = transfer.getDataSender();
    % Prepare the manager and sender objects for the transfer.
    monitor = manager.respondToTransferInitiation(sender, transferSeqNumber);
catch
    error('distcomp:pmode:PmodeNotRunning', 'Pmode is currently not running');
end

% Create error messages that are specific to a transfer from a lab to a client.
errorMsgStruct = struct('undefinedVariable', ...
                        sprintf('Variable %s is undefined on lab %d.', ...
                                labvarname, labindex), ...
                        'failedToSerialize', ...
                        sprintf('Could not serialize the variable %s.', ...
                                labvarname));

% From this point onwards, the data send operation is identical to that when
% the client is sending data to a lab, so let a package method do the sending.
distcomp.doInteractiveSend(labvarname, sender, monitor, errorMsgStruct);
