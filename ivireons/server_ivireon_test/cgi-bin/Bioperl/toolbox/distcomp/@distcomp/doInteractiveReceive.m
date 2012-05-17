function serializedValue = doInteractiveReceive(receiver, monitor)
; %#ok Undocumented.
%doInteractiveReceive Receive a variable using a fully initialized DataReceiver.
% receiver A DataReceiver.
% monitor  A TransferMonitor that we notify of all M errors.
%
% Returns the serialized variable as a uint8 vector.

%   Copyright 2006-2008 The MathWorks, Inc.

try 
    %%
    % We are ready to start the transfer.
    monitor.setLocalReady();
    
    % Don't start sending until the remote side is ready to start the transfer.
    iLoopUntilErrorOrTrue(monitor, @() monitor.isRemoteReady());

    %%
    % Perform the actual transfer.
    header = iLoopUntilErrorOrReturnValue(monitor, @() receiver.getHeader());
    serializedValue = zeros(1, header.fSerializedLength, 'uint8');
    first = 1;
    for block = 1:header.fNumberOfBlocks
        currVal = iLoopUntilErrorOrReturnValue(monitor, ...
                                               @() receiver.getNextBlock());
        % byte[] in Java is returned as int8, but we want uint8.
        currVal = typecast(currVal, 'uint8');
        last = first + length(currVal) - 1;
        serializedValue(first:last) = currVal;
        first = last + 1;
    end

    %%
    % The caller has to call monitor.setLocalFinished and wait for
    % monitor.setRemoteFinished to return true, we don't do it here.
catch err
  if isempty(monitor.getOutsideLocalMError())
      % We caught an error that needs to be sent to the error listener.
      monitor.setLocalMError(err.identifier, err.message);
  end
  rethrow(err);
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function val = iLoopUntilErrorOrReturnValue(monitor, func)
% Call func until it returns a non-empty value, or until 
% monitor.getOutsideLocalMError return non-empty.
while true
    err = monitor.getOutsideLocalMError();
    if ~isempty(err)
        error(char(err.getErrorIdentifier()), char(err.getErrorMessage()));
    end
    val = func();
    if ~isempty(val)
       return;
    end
    pause(0.01);
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
    pause(0.01);
end
