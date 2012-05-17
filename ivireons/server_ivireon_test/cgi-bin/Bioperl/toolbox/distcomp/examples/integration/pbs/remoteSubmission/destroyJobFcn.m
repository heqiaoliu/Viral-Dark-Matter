function destroyJobFcn(scheduler, job)
%DESTROYJOB Destroys a job on PBS
%
% Set your scheduler's DestroyJobFcn to this function using the following
% command:
%     set(sched, 'DestroyJobFcn', @destroyJobFcn);

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2010/03/31 18:14:15 $

% Store the current filename for the dctSchedulerMessages
currFilename = mfilename;
if ~scheduler.HasSharedFilesystem
    error('distcompexamples:PBS:SubmitFcnError', ...
        'The submit function %s is for use with shared filesystems.', currFilename)
end
 % Get the information about the actual scheduler used
data = scheduler.getJobSchedulerData(job);
if isempty(data)
    % This indicates that the job has not been submitted, so just return
    dctSchedulerMessage(1, '%s: Job scheduler data was empty for job with ID %d.', currFilename, job.ID);
    return
end
try
    clusterHost = data.RemoteHost;
catch err
    ex = MException('distcompexamples:PBS:FailedToRetrieveRemoteParameters', ...
        'Failed to retrieve remote parameters from the job scheduler data.');
    ex = ex.addCause(err);
    throw(ex);
end
remoteConnection = getRemoteConnection(scheduler, clusterHost);
try
    jobIDs = data.SchedulerJobIDs;
catch err
    ex = MException('distcompexamples:PBS:FailedToRetrieveJobID', ...
        'Failed to retrieve scheduler''s job IDs from the job scheduler data.');
    ex = ex.addCause(err);
    throw(ex);
end

% Only ask the scheduler to destroy the job if it is hasn't reached a terminal
% state.  
erroredJobs = cell(size(jobIDs));
jobState = job.State;
if ~(strcmp(jobState, 'finished') || strcmp(jobState, 'failed'))
    % Get the scheduler to destroy the job
    for ii = 1:length(jobIDs)
        jobID = jobIDs{ii};
        commandToRun = sprintf('qdel "%s"', jobID);
        dctSchedulerMessage(4, '%s: Destroying job on scheduler using command:\n\t%s.', currFilename, commandToRun);
        % Keep track of all jobs that were not destroyed successfully - either through
        % a bad exit code or if an error was thrown.  We'll report these later on.
        try
            % Execute the command on the remote host.
            [cmdFailed, cmdOut] = remoteConnection.runCommand(commandToRun);
        catch err
            cmdFailed = true;
            cmdOut = err.message;
        end
        if cmdFailed
            erroredJobs{ii} = jobID;
            dctSchedulerMessage(1, '%s: Failed to destroy job %d on scheduler.  Reason:\n\t%s', currFilename, jobID, cmdOut);
        end
    end
end


% Now warn about those jobs that we failed to destroy.
erroredJobs = erroredJobs(~cellfun(@isempty, erroredJobs));
if ~isempty(erroredJobs)
    warning('distcompexamples:PBS:FailedToDestroyJob', ...
        'Failed to destroy the following jobs on the scheduler:\n%s', ...
        sprintf('\t%s\n', erroredJobs{:}));
end
