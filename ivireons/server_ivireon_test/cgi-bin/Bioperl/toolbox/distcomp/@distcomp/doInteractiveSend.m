function doInteractiveSend(varname, sender, monitor, errorMsgStruct)
; %#ok Undocumented
%doInteractiveSend Send a variable using a fully initialized DataSender.
%   varname         The name of the variable in the base workspace.
%   sender          A DataSender.
%   monitor         A TransferMonitor that we notify of all M errors.
%   errorMsgStruct  A struct whose fields undefiedVariable and failedToSerialize
%                   contain error messages.

%   Copyright 2006-2008 The MathWorks, Inc.

import com.mathworks.toolbox.distcomp.pmode.SessionConstants;

try
    %%
    % We are ready to start the transfer.
    monitor.setLocalReady();

    % Get the variable varname from the base workspace and serialize it.
    value = iGetVariableFromBase(varname, errorMsgStruct);

    % Send large variables in chunks.
    blockSize = SessionConstants.sMAX_TRANSFER_SIZE_IN_ONE_BLOCK;
    len = length(value);
    numBlocks = ceil(len/blockSize);

    % Don't start sending until the remote side is ready to start the transfer.
    iLoopUntilErrorOrTrue(monitor, @() monitor.isRemoteReady());
    
    %%
    % Perform the actual transfer.
    sender.setHeader(len, numBlocks);
    first = 1;
    for block = 1:numBlocks
        iLoopUntilErrorOrTrue(monitor, @() sender.isReadyForNextBlock());
        last = min(len, first + blockSize - 1);
        sender.sendNextBlock(value(first:last));
        first = last + 1;
    end

    %%
    % We are now done, and have to wait till the remote side is done.
    monitor.setLocalFinished();
    iLoopUntilErrorOrTrue(monitor, @() monitor.isRemoteFinished());

catch err
    if isempty(monitor.getOutsideLocalMError())
        % We caught an error that needs to be sent to the monitor.
        monitor.setLocalMError(err.identifier, err.message);
    end
    rethrow(err);
end
    
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

function value = iGetVariableFromBase(varname, errorMsgStruct)
value = [];
try
    value = evalin('base', varname);
catch
    error('distcomp:pmode:UndefinedVariable', errorMsgStruct.undefinedVariable);
end

try
    value = distcompserialize(value);
catch
    dctSchedulerMessage(1, sprintf('Could not serialize the variable %s.', varname));
    error('distcomp:pmode:TransferError', errorMsgStruct.failedToSerialize);
end

