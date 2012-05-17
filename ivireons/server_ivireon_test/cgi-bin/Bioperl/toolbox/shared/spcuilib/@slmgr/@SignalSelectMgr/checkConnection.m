function [isValid, errorMsg] = checkConnection(this)
%CHECKCONNECTION Check the connections.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/03/31 18:43:25 $

% Clean up the manager by removing all duplicate ports.
%
% Duplicate ports arise from having selected multiple "identical" signals,
% (due to selecting, say, branched signals in a model), then calling
% "gsl" to get all selected lines.
removeDuplicatePorts(this);

signals = get(this, 'Signals');

% If there are no signals, return early.
if isempty(signals)
    isValid = false;
    if isempty(this.Selectedblk)
        errorMsg = 'No signal selected.';
    else
        errorMsg = sprintf('Selected block does not have an output signal to display.');
    end
    return;
end

% Check that the systems are homogenous.
system = get(signals, 'System');
if iscell(system)
    system = unique([system{:}]);
    if length(system) > 1
        isValid  = false;
        errorMsg = 'All systems must be homogenous.';
        return;
    end
end

isValid  = true;
errorMsg = '';

% Return the first error.
for indx = 1:length(signals)
    [thisValid, newMsg] = signals(indx).checkConnection;
    if ~thisValid
        errorMsg = newMsg;
        isValid  = false;
        return;
    end
end

% [EOF]
