function client2lab(obj, transferSeqNumber, labidxes, labvarname) %#ok obj not used.
; %#ok Undocumented
%   Lab code to transfer a serializable variable onto a lab.
%   Caller should have made sure that labidxes is a vector of integers and
%   isvarname(labvarname) returns true.

%   Copyright 2006-2008 The MathWorks, Inc.

import com.mathworks.toolbox.distcomp.pmode.SessionFactory;

err = [];
value = [];
firstLab = min(labidxes);
%%
% firstLab reads the data from the client.  
if labindex == firstLab
    try
        try
            session = SessionFactory.getCurrentSession();
            transfer= session.getTransfer();
            receiver = transfer.getDataReceiver();
            manager = transfer.getTransferManager();
            monitor = manager.respondToTransferInitiation(receiver, ...
                                                          transferSeqNumber);
        catch
            error('distcomp:pmode:PmodeNotRunning', ...
                  'Pmode is currently not running');
        end
        value = distcomp.doInteractiveReceive(receiver, monitor);
    catch exception
        % doInteractiveReceive reports all of its M errors to the monitor, so 
        % we can simply rethrow the error.
        err = exception;
    end
end

%%
% All the labs need to know whether firstLab has value or not in order
% to determine whether to proceed.
err = labBroadcast(firstLab, err);
if ~isempty(err)
    if labindex == firstLab
        % doInteractiveReceive reported the error to the monitor, so we 
        % can simply bail out.
        rethrow(err);
    else
        return;
    end
end

%%
% Use MPI to send value from firstLab to the other labs and store it in 'base'.
try
    iSendVarAndDeserialize(labidxes, firstLab, value, labvarname);
catch err
    if labindex == firstLab
        monitor.setLocalMError(err.identifier, err.message);
    end
    rethrow(err);
end

%%
% We are now done, and have to wait till the remote side is done.
if labindex == firstLab
    monitor.setLocalFinished();
    iLoopUntilErrorOrTrue(monitor, @() monitor.isRemoteFinished()); 
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function iSendVarAndDeserialize(labidxes, firstLab, value, labvarname)
%iSendVarAndDeserialize Send value from firstLab to labidxes and assign to base.
%   Note: Does not report any M-errors to any error listeners.

% Send the serialized value from firstLab to all the other destination labs.
receiveLabs = setdiff(labidxes, firstLab);
mwTag = 31777;
if labindex == firstLab
    % Note that labSend with an empty set of destination labs is a noop,
    % so the labSend also works if firstLab is the only destination lab.
    labSend(value, receiveLabs, mwTag);
elseif any(receiveLabs == labindex)
    value = labReceive(firstLab, mwTag);
end

% Deserialize the value and assign in the base workspace.
if any(labidxes == labindex)
    try
        value = distcompdeserialize(value);
        assignin('base', labvarname, value);
    catch
        error('distcomp:pmode:TransferFailed', ...
              'Failed to store the variable %s on lab %d.', ...
              labvarname, labindex);
    end
end


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
end
