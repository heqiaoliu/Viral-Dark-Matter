function val = pSetJobDescriptionFile(ccs, val)
; %#ok Undocumented
% Sets the job description file on the server connection

%  Copyright 2009 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $  $Date: 2009/04/15 22:58:05 $

if isempty(ccs.ServerConnection)
    return;
end

% Ask the server connection to set the job description file.
% Both versions 1 and 2 support XML Description files
try 
    ccs.ServerConnection.JobDescriptionFile = val;
catch err
    % convert from a ServerConnection error to a ccsscheduler error, if necessary.
    % (Only actually required for distcomp:MicrosoftSchedulerConnection:InvalidJobDescriptionFile)
    throw(distcomp.MicrosoftSchedulerConnectionExceptionManager.convertToCCSSchedulerError(err));
end
