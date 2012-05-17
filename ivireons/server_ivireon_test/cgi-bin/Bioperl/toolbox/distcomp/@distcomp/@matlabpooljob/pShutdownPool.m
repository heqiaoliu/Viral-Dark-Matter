function OK = pShutdownPool(job) 
; %#ok Undocumented
%pShutdownPool 
%
%  pShutdownPool(JOB)

% Copyright 2009 The MathWorks, Inc.


if ~job.IsPoolTask
    % Get the interactive client object
    obj = distcomp.getInteractiveObject;
    % Stop the labs if we are the client
    OK = obj.stopLabsAndDisconnect;
    job.PoolShutdownSuccessful = OK;
    % Delete the interactive object
    distcomp.clearInteractiveObject;
else
    OK = true;
end