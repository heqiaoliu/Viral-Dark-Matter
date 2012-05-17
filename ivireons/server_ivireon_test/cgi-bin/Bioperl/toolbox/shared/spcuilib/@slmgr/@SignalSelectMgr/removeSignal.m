function removeSignal(this, varargin)
%REMOVESIGNAL Remove the specified signal from the manager

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/12/27 21:29:38 $

if nargin < 2
    signal = {gsl};
else
    signal = varargin;
end

if length(signal) == 1 && ~iscell(signal{1})
    while length(signal{end}) > 1
        signal = {signal{1:end-1} signal{end}(1) signal{end}(2:end)};
    end
end

% Loop over each signal to remove and remove it.
for indx = 1:length(signal)
    signal{indx} = lclRemoveSignal(this, signal{indx});
end

% If at least one signal was removed, send an event.
signal = [signal{:}];
if ~isempty(signal)
    send(this, 'SignalRemoved', spcuddutils.EventData(this, 'SignalRemoved', signal));
end

% -------------------------------------------------------------------------
function signal = lclRemoveSignal(this, signal)

% If the passed signal is empty, we will not find any signals to remove.
% Simply return to avoid throwing a meaningless warning.
if isempty(signal)
    signal = [];
    return;
end

signal = findSignal(this, signal);

if isempty(signal)
    warning('spcuilib:slmgr:SignalSelectMgr:signalNotFound', ...
        'Signal not found in manager.');
    return;
end

disconnect(signal);

% [EOF]
