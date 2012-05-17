function pSubmitJob(ccs, job)
%pSubmitJob A short description of the function
%
%  pSubmitJob(SCHEDULER, JOB)

%  Copyright 2006-2010 The MathWorks, Inc.

%  $Revision: 1.1.6.7 $    $Date: 2010/04/21 21:13:58 $

% Check the job is in a state to be submitted
ccs.pPreSubmissionChecks(job);

% Ensure that the job has been prepared
job.pPrepareJobForSubmission;

% Get the submission arguments that are common to all jobs
jobSubmissionArguments =  ccs.pGetCommonJobSubmissionArguments(job);

% Add the correct decode function to the job environment variables
if ccs.UseSOAJobSubmission
    jobEnvironmentVariables = [jobSubmissionArguments.jobEnvironmentVariables; ...
        {'MDCE_DECODE_FUNCTION',     'decodeCcsSoaTask'}];
else
    jobEnvironmentVariables = [jobSubmissionArguments.jobEnvironmentVariables; ...
        {'MDCE_DECODE_FUNCTION',     'decodeCcsSingleTask'}];
end
% The name of the environment variable that specifies the task location
taskLocationEnvironmentVariableName = 'MDCE_TASK_LOCATION';

[~, matlabExe, matlabArgs] = ccs.pCalculateMatlabCommandForJob(job);
try
    % Ask the server connection to submit the job.
    [schedulerJobIDs, schedulerTaskIDs, schedulerJobName] = ccs.ServerConnection.submitJob(job, matlabExe, matlabArgs, ...
        jobEnvironmentVariables, taskLocationEnvironmentVariableName, ...
        jobSubmissionArguments.fullJobLocation, jobSubmissionArguments.fullLogLocation, jobSubmissionArguments.logTaskIDToken, ...
        jobSubmissionArguments.username, jobSubmissionArguments.password);
catch err
    % convert from a ServerConnection error to a ccsscheduler error, if necessary.
    % (Only actually required for distcomp:HPCServerSchedulerConnection:FailedToCreateJobFromXML, 
    % distcomp:CCSSchedulerConnection:FailedToCreateJobFromXML and
    % distcomp:HPCServerSchedulerConnection:FailedToUseJobTemplate)
    throw(distcomp.MicrosoftSchedulerConnectionExceptionManager.convertToCCSSchedulerError(err));
end

% Now store the returned values in the job scheduler data
if length(schedulerJobIDs) == 2
    schedulerAdditionalJobID = schedulerJobIDs(2);
else
    schedulerAdditionalJobID = [];
end
matlabTaskIDs = cell2mat(get(job.Tasks, {'ID'}));
schedulerData = distcomp.MicrosoftJobSchedulerData(ccs.ServerConnection.getAPIVersion, ...
    ccs.ServerConnection.SchedulerVersion, ccs.SchedulerHostname, ...
    ccs.UseSOAJobSubmission, schedulerJobName, schedulerJobIDs(1), schedulerAdditionalJobID, ...
    schedulerTaskIDs, matlabTaskIDs, jobSubmissionArguments.logRelativeToRoot, jobSubmissionArguments.logTaskIDToken);
job.pSetJobSchedulerData(schedulerData);
