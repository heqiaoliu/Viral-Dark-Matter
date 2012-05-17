function state = getJobStateFcn(scheduler, job, state)
%GETJOBSTATEFCN Gets the state of a job from LSF
%
% Set your scheduler's GetJobStateFcn to this function using the following
% command:
%     set(sched, 'GetJobStateFcn', @getJobStateFcn);

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2010/03/31 18:14:17 $

% Store the current filename for the dctSchedulerMessages
currFilename = mfilename;
if scheduler.HasSharedFilesystem
    error('distcompexamples:LSF:SubmitFcnError', ...
        'The submit function %s is for use with nonshared filesystems.', currFilename)
end

 % Get the information about the actual scheduler used
data = scheduler.getJobSchedulerData(job);
if isempty(data)
    % This indicates that the job has not been submitted, so just return
    dctSchedulerMessage(1, '%s: Job scheduler data was empty for job with ID %d.', currFilename, job.ID);
    return
end
try
    hasDoneLastMirror = data.HasDoneLastMirror;
catch err
    ex = MException('distcompexamples:LSF:FailedToRetrieveRemoteParameters', ...
        'Failed to retrieve remote parameters from the job scheduler data.');
    ex = ex.addCause(err);
    throw(ex);
end
% Shortcut if the job state is already finished or failed
jobInTerminalState = strcmp(state, 'finished') || strcmp(state, 'failed');
% and we have already done the last mirror
if jobInTerminalState && hasDoneLastMirror
    return;
end
try
    clusterHost = data.RemoteHost;
    remoteDataLocation = data.RemoteDataLocation;
catch err
    ex = MException('distcompexamples:LSF:FailedToRetrieveRemoteParameters', ...
        'Failed to retrieve remote parameters from the job scheduler data.');
    ex = ex.addCause(err);
    throw(ex);
end
remoteConnection = getRemoteConnection(scheduler, clusterHost, remoteDataLocation);
try
    jobIDs = data.SchedulerJobIDs;
catch err
    ex = MException('distcompexamples:LSF:FailedToRetrieveJobID', ...
        'Failed to retrieve scheduler''s job IDs from the job scheduler data.');
    ex = ex.addCause(err);
    throw(ex);
end
  
commandToRun = sprintf('bjobs %s', sprintf('%d ', jobIDs{:}));
dctSchedulerMessage(4, '%s: Querying scheduler for job state using command:\n\t%s', currFilename, commandToRun);

try
    % We will ignore the status returned from the state command because
    % a non-zero status is returned if the job no longer exists
    % Execute the command on the remote host.
    [~, cmdOut] = remoteConnection.runCommand(commandToRun);
catch err
    ex = MException('distcompexamples:LSF:FailedToGetJobState', ...
        'Failed to get job state from scheduler.');
    ex = ex.addCause(err);
    throw(ex);
end

schedulerState = iExtractJobState(cmdOut, numel(jobIDs));
dctSchedulerMessage(6, '%s: State %s was extracted from scheduler output:\n\t%s', currFilename, schedulerState, cmdOut);

% If we could determine the scheduler's state, we'll use that, otherwise
% stick with MATLAB's job state.
if ~strcmp(schedulerState, 'unknown')
    state = schedulerState;
end
% Decide what to do with mirroring based on the scheduler's version of job state and whether or not
% the job is currently being mirrored:
% If job is not being mirrored, and job is not finished, resume the mirror
% If job is not being mirrored, and job is finished, do the last mirror
% If the job is being mirrored, and job is finished, do the last mirror.
% Otherwise (if job is not finished, and we are mirroring), do nothing
isBeingMirrored = remoteConnection.isJobUsingConnection(job.ID);
isJobFinished = strcmp(state, 'finished') || strcmp(state, 'failed');
if ~isBeingMirrored && ~isJobFinished
    % resume the mirror
    dctSchedulerMessage(4, '%s: Resuming mirror for job %d.', currFilename, job.ID);
    try
        remoteConnection.resumeMirrorForJob(job);
    catch err
        warning('distcompexamples:LSF:FailedToResumeMirrorForJob', ...
            'Failed to resume mirror for job %d.  Your local job files may not be up-to-date.\nReason: %s', ...
            err.getReport);
    end
elseif isJobFinished
    dctSchedulerMessage(4, '%s: Doing last mirror for job %d.', currFilename, job.ID);
    try
        remoteConnection.doLastMirrorForJob(job);
        % Store the fact that we have done the last mirror so we can shortcut in the future
        data.HasDoneLastMirror = true;
        scheduler.setJobSchedulerData(job, data);
    catch err
        warning('distcompexamples:LSF:FailedToDoFinalMirrorForJob', ...
            'Failed to do last mirror for job %d.  Your local job files may not be up-to-date.\nReason: %s', ...
            err.getReport);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function state = iExtractJobState(bjobsOut, numJobs)
% Function to extract the job state from the output of bjobs

% How many PEND, PSUSP, USUSP, SSUSP, WAIT
numPending = numel(regexp(bjobsOut, 'PEND|PSUSP|USUSP|SSUSP|WAIT'));
% How many RUN strings - UNKWN started running and then comms was lost
% with the sbatchd process.
numRunning = numel(regexp(bjobsOut, 'RUN|UNKWN'));
% How many DONE, EXIT, ZOMBI strings
numFailed = numel(regexp(bjobsOut, 'EXIT|ZOMBI'));
% How many DONE
numFinished = numel(regexp(bjobsOut, 'DONE'));

% If the number of finished jobs is the same as the number of jobs that we
% asked about then the entire job has finished.
if numFinished == numJobs
    state = 'finished';
    return;
end

% Any running indicates that the job is running
if numRunning > 0
    state = 'running';
    return
end
% We know numRunning == 0 so if there are some still pending then the
% job must be queued again, even if there are some finished
if numPending > 0
    state = 'queued';
    return
end
% Deal with any tasks that have failed
if numFailed > 0
    % Set this job to be failed
    state = 'failed';
    return
end

state = 'unknown';
