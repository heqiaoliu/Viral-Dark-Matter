function val = pSetClusterSize(obj, val)
; %#ok Undocumented

%  Copyright 2009 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $  $Date: 2009/04/15 22:58:02 $

if isempty(obj.ServerConnection)
    return;
end

% Tell the server connection what the MaximumNumberOfWorkersPerJob should be.
try
    obj.ServerConnection.MaximumNumberOfWorkersPerJob = val;
catch err
    % convert from a ServerConnection error to a ccsscheduler error, if necessary.
    % (Only actually required for distcomp:MicrosoftSchedulerConnection:InvalidNumberOfWorkers)
    throw(distcomp.MicrosoftSchedulerConnectionExceptionManager.convertToCCSSchedulerError(err));
end
