function pSubmitParallelJob(ccs, job)
%pSubmitParallelJob A short description of the function
%
%  pSubmitParallelJob(SCHEDULER, JOB)

%  Copyright 2006-2010 The MathWorks, Inc.

%  $Revision: 1.1.6.7 $    $Date: 2010/04/21 21:13:59 $

% Check the job is in a state to be submitted
ccs.pPreSubmissionChecks(job);

% Ensure we have enough cores on the cluster
minProcessors = job.MinimumNumberOfWorkers;
if minProcessors > ccs.ClusterSize
    error('distcomp:ccsscheduler:ResourceLimit', ...
        ['You requested a minimum of %d workers, but the scheduler''s ClusterSize property ' ...
        'is currently set to allow a maximum of %d workers.  ' ...
        'To run a parallel job with more tasks than this, increase the value of the ClusterSize ' ...
        'property for the scheduler.'], ...
        minProcessors, ccs.ClusterSize);
end

% Duplicate the tasks for parallel execution
job.pDuplicateTasks;
% Ensure that the job has been prepared
job.pPrepareJobForSubmission;

% Get the submission arguments that are common to all jobs
jobSubmissionArguments = ccs.pGetCommonJobSubmissionArguments(job);
% Add the correct decode function to the job environment variables
jobEnvironmentVariables = [jobSubmissionArguments.jobEnvironmentVariables; ...
    {'MDCE_DECODE_FUNCTION',     'decodeCcsSingleParallelTask'; ...
     'MDCE_FORCE_MPI_OPTION',    'msmpi'}];

% Work out which command line we need to use for this job
[~, matlabExe, matlabArgs] = ccs.pCalculateMatlabCommandForJob(job);
matlabCommand = sprintf('"%s" %s', matlabExe,  matlabArgs);
genvlist = '-genvlist MDCE_DECODE_FUNCTION,MDCE_FORCE_MPI_OPTION,MDCE_STORAGE_LOCATION,MDCE_STORAGE_CONSTRUCTOR,MDCE_JOB_LOCATION,CCP_NODES,CCP_JOBID';
commandLine = ['mpiexec -l ' genvlist ' -hosts %CCP_NODES% ' matlabCommand];

try
    % Ask the server connection to submit the job
    [schedulerJobIDs, schedulerTaskIDs] = ccs.ServerConnection.submitParallelJob(job, commandLine, ...
        jobEnvironmentVariables, jobSubmissionArguments.fullLogLocation, ...
        jobSubmissionArguments.username, jobSubmissionArguments.password);
catch err
    % convert from a ServerConnection error to a ccsscheduler error, if necessary.
    % (Only actually required for distcomp:HPCServerSchedulerConnection:FailedToCreateJobFromXML, 
    % distcomp:CCSSchedulerConnection:FailedToCreateJobFromXML and
    % distcomp:HPCServerSchedulerConnection:FailedToUseJobTemplate)
    throw(distcomp.MicrosoftSchedulerConnectionExceptionManager.convertToCCSSchedulerError(err));
end

% Now store the returned values in the job scheduler data
% Parallel jobs never need to know the job name
schedulerJobName = '';
% Parallel jobs are never SOA jobs
isSOAJob = false;
% non-SOA jobs never have an additional job ID
schedulerAdditionalJobID = [];
matlabTaskIDs = cell2mat(get(job.Tasks, {'ID'}));
schedulerData = distcomp.MicrosoftJobSchedulerData(ccs.ServerConnection.getAPIVersion, ...
    ccs.ServerConnection.SchedulerVersion, ccs.ServerConnection.SchedulerHostname, ...
    isSOAJob, schedulerJobName, schedulerJobIDs(1), schedulerAdditionalJobID, ...
    schedulerTaskIDs, matlabTaskIDs, jobSubmissionArguments.logRelativeToRoot, jobSubmissionArguments.logTaskIDToken);
job.pSetJobSchedulerData(schedulerData);
