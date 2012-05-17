function removeDuplicatePorts(this)
%RemoveDuplicatePorts Remove duplicate port handles.
%
% Duplicates arise from having selected multiple "identical" signals,
% (due to selecting, say, branched signals in a model), then calling
% "gsl" to get all selected lines.

% Copyright 2005 The MathWorks, Inc.

% Find and remove duplicate port handles
%
% We unique-ify based on the port handles, not the objects themselves
% Why?  Turns out the ports are allocated in-order, numerically
%
% This should be equivalent to sorting on the Port.PortIndex property
%
porth = get(this.Signals, 'Port');

% If we do not have more than 1 port, we can't have duplicates.
if ~iscell(porth)
    return;
end

porth = [porth{:}];
for i=1:numel(porth)
    h(i) = porth(i).handle; %#ok
end
[h,idx] = unique(h);

% Remove the extra copies.
removeSignal(this, this.Signals(setdiff(1:numel(porth), idx)));

% [EOF]
