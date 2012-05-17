function pSubmitJob(lsf, job)
; %#ok Undocumented
%pSubmitJob A short description of the function
%
%  pSubmitJob(SCHEDULER, JOB)

%  Copyright 2005-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.6 $    $Date: 2008/06/24 17:01:30 $ 


tasks = job.Tasks;
numTasks = numel(tasks);
if numTasks < 1
    error('distcomp:lsfscheduler:InvalidState', 'A job must have at least one task to submit to an LSF schdeuler');
end

% Warning to indicate that we are going to change CWD
if lsf.pCwdIsUnc 
    warning('distcomp:lsfscheduler:DirectoryChange', ...
        ['The current working directory is a UNC path. To correctly execute LSF commands we will\n' ...
         'have to change to the directory given by tempdir. We will change back afterwards.%s'],'');
end

% Ensure that the job has been prepared
job.pPrepareJobForSubmission;

% Do something radically different when the storage is not shared.
if ~lsf.HasSharedFilesystem
    lsf.pSubmitNonSharedJob(job, tasks);
    return
end

% Define the function that will be used to decode the environment variables
setenv('MDCE_DECODE_FUNCTION', 'decodeLsfSingleTask');

storage = job.pReturnStorage;
% Ask the storage object how it would like to serialize itself and be
% reconstructed at the far end
[stringLocation, stringConstructor] = storage.getSubmissionStrings;
setenv('MDCE_STORAGE_LOCATION', stringLocation);
setenv('MDCE_STORAGE_CONSTRUCTOR', stringConstructor);

% Get the location of the storage
jobLocation = job.pGetEntityLocation;

setenv('MDCE_JOB_LOCATION', jobLocation);

% Define the location for logs to be returned
logLocation = '';
if isa(storage, 'distcomp.filestorage')
    [clientLog, logLocation] = lsf.pJobSpecificFile( job, 'Task%I.log', true ); %#ok
    logRelToStorage = [job.pGetEntityLocation, '/Task%I.log'];
end
% Submit all the tasks in one go using a job array - the far end will pick
% up the task number automatically using the LSB_JOBINDEX environment
% variable. The submit string below says
% -H hold the job in the PSUSP state until we call bresume
% -J "name[1-N]" create a job array with 1-N sub tasks
% Add the lsf SubmitArguments as required
% Execute the command matlab -dmlworker -nodisplay -r distcomp_evaluate_filetask > logfile
matlabCommand = lsf.pCalculateMatlabCommandForJob(job);
% Need to see if we have been given a ClusterMatlabRoot and append
% \/bin\/matlab to the end of it.
clusterMatlabPath = lsf.ClusterMatlabRoot;
if ~isempty(clusterMatlabPath)
    matlabCommand = [clusterMatlabPath '/bin/' matlabCommand];
end
% On unix we need to protect the matlab command in a single quoted string
% but on windows we need to use double quotes (This is because the string
% might contain something like \\server on unix and the shell interprets
% the \\ as an escaped \ rather than \\ unless we use '. 
if ispc
    quote = '"';
else
    quote = '''';
end
matlabCommand = [quote matlabCommand quote];
% Check for non-empty logLocation and add the -o in front 
if ~isempty(logLocation)
    logLocation = ['-o ' quote logLocation quote];
end
% Create taskIDString from the ID's of the tasks in this job
taskIDString = lsf.pMakeTaskIDString(tasks);

submitString = sprintf(...
    'bsub -H -J "%s[%s]" %s  %s  %s'  , ...
    jobLocation, ...
    taskIDString, ...
    logLocation, ...
    lsf.SubmitArguments, ...
    matlabCommand);

% Before submitting we need to ensure that certain environment variables
% are no longer set otherwise LSF will copy them across and break the
% remote MATLAB startup - these are used by MATLAB startup to pick the
% matlabroot and toolbox path and they explicitly override any local
% settings.
storedEnv = distcomp.pClearEnvironmentBeforeSubmission();

try
    % Make the shelled out call to bsub.
    [FAILED, out] = dctSystem(submitString);
catch err
    FAILED = true;
    out = err.message;
end

distcomp.pRestoreEnvironmentAfterSubmission( storedEnv );

if FAILED
    error('distcomp:lsfscheduler:UnableToFindService', ...
        'Error executing the LSF script command ''bsub''. The reason given is \n %s', out);
end

% Now parse the output of bsub to extract the job number
jobNumberStr = regexp(out, 'Job <[0-9]*>', 'once', 'match');
lsfID = sscanf(jobNumberStr(6:end-1), '%d');
schedulerData = struct('type', 'lsf', 'lsfID', lsfID, 'logRelToStorage', logRelToStorage);
job.pSetJobSchedulerData(schedulerData);
% Now set the job actually running by moving it from the PSUSP state to the
% PEND state
[FAILED, out] = dctSystem(sprintf('bresume "%d[%s]"', lsfID, taskIDString));
if FAILED
    error('distcomp:lsfscheduler:UnableToFindService', ...
        'Error executing the LSF script command ''bresume''. The reason given is \n %s', out);
end

