function pSubmitJobCommon(scheduler, job, submitFcn)
; %#ok Undocumented
%pSubmitJob A short description of the function
%
%  pSubmitJob(SCHEDULER, JOB)

%  Copyright 2005-2008 The MathWorks, Inc.

%  $Revision: 1.1.6.6 $    $Date: 2008/05/19 22:45:06 $ 

% Ensure that the job has been prepared
job.pPrepareJobForSubmission;

storage = job.pReturnStorage;
% Ask the storage object how it would like to serialize itself and be
% reconstructed at the far end
[storageLocation, storageConstructor] = storage.getSubmissionStrings;

% Get the location of the storage
jobLocation = job.pGetEntityLocation;
tasks = job.Tasks;
taskLocations = cell(size(tasks));
for i = 1:numel(tasks)
    taskLocations{i} = tasks(i).pGetEntityLocation;
end

storedEnv = distcomp.pClearEnvironmentBeforeSubmission();

[submitFcn, args] = pGetFunctionAndArgsFromCallback(scheduler, submitFcn);

% Set the input data for the submit function call
setprop = distcomp.setprop;
setprop.pSetStorageStrings(storageLocation, ...
    storageConstructor, ...
    jobLocation, ...
    taskLocations);

% Set MatlabCommandToRun based on ClusterOsType and job type
[scheduler.MatlabCommandToRun, matlabExe, matlabArgs] = scheduler.pCalculateMatlabCommandForJob(job);
setprop.pSetExecutableStrings(matlabExe, matlabArgs);

% Test for an error during submission and throw later
errorToThrow = [];
% Pre-set the job scheduler data before the user gets called - so that it is
% correct in advance of the user function being called
scheduler.setJobSchedulerData(job, []);
try
    feval(submitFcn, scheduler, job, setprop, args{:});
catch submit_error
    % Create a new MException that includes the report from the
    % submit_error. This means the stack trace for the original error is
    % displayed to the user.
    errorToThrow = MException( 'distcomp:genericscheduler:SubmitFcnError',...
        'Job submission did not occur because the user supplied SubmitFcn (%s) errored.\n\n%s',...
        scheduler.pFunc2Str( submitFcn ), submit_error.getReport() );
end

% Restore the environment variable we unset earlier
distcomp.pRestoreEnvironmentAfterSubmission( storedEnv );

% Restore the job scheduler data if the submit function errored
if ~isempty( errorToThrow )
    job.pSetJobSchedulerData([]);
    throw( errorToThrow );
end

