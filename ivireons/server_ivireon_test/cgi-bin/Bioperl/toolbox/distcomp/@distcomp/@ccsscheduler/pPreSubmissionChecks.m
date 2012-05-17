function pPreSubmissionChecks(ccs, job)
; %#ok Undocumented
% Checks on the job that need to made before it is actually submitted

%  Copyright 2009 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $  $Date: 2009/04/15 22:58:00 $

numTasks = numel(job.Tasks);
if numTasks < 1
    error('distcomp:ccsscheduler:InvalidState', 'A job must have at least one task to submit to an HPC Server scheduler');
end

% CCS doesn't support non-shared files system
if ~ccs.HasSharedFilesystem
    error('distcomp:ccsscheduler:NotSupported', 'Submission to an HPC Server scheduler requires that the file system be shared');
end

% Check we are connected to a scheduler and it is the correct one
if isempty(ccs.ServerConnection) || ~ccs.ServerConnection.IsConnected || ~ccs.ServerConnection.isConnectedToScheduler(ccs.SchedulerHostname)
    error('distcomp:ccsscheduler:UnableToContactService', ...
        'You are not connected to an HPC Server scheduler on machine: %s\nTry setting the SchedulerHostname of the scheduler object to the name of an HPC Server scheduler machine', ...
        ccs.SchedulerHostname);
end

