function signal = findSignal(this, signal)
%FINDSIGNAL Find the signal in the database.
%   FINDSIGNAL(H, SIGNALINFO) Find the signal in the manager based on the
%   information provided in SIGNALINFO.  SIGNALINFO can be a
%   slmgr.SignalSelect object or the handle to a block or line.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/02/02 13:11:35 $

if isa(signal, 'slmgr.SignalSelect')

    % Verify that the passed signal is actually contained in THIS or at
    % least a version with the same settings.
    signal = find(this, '-isa', 'slmgr.SignalSelect', ...
        'System',    signal.System, ...
        'Block',     signal.Block, ...
        'PortIndex', signal.PortIndex, ...
        'Port',      signal.Port, ...
        'Line',      signal.Line);
else
    
    % Find the signal based on the value passed to us.  If a block is
    % passed, we will return all signals for that block.
    if iscell(signal)
        try
            % If the find hard errors it is because the signal is not
            % valid, which means it cannot be contained in the object.
            % This usually happens we try to create a SignalSelect for a
            % model that is not opened yet.
            signal = find(this, ...
                '-isa', 'slmgr.SignalSelect', ...
                'Block', handle(get_param(signal{1}, 'handle')), ...
                'PortIndex', signal{2});
        catch e %#ok
            signal = [];
        end
    elseif isempty(signal)
        signal = [];
    else
        try
            signal = find(this, ...
                '-isa', 'slmgr.SignalSelect', ...
                get(signal, 'Type'), handle(signal));
        catch e %#ok
            signal = [];
        end
    end
end

% [EOF]
