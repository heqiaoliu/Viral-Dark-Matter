function pSubmitNonSharedJob(lsf, job, tasks)
; %#ok Undocumented
%pSubmitNonSharedJob 
%
%  pSubmitNonSharedJob(SCHEDULER, JOB)

%  Copyright 2005-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.8 $    $Date: 2008/06/24 17:01:31 $ 


numTasks = numel(tasks);

storage = lsf.Storage;
% Ensure we are only doing this with file storage 
if ~isa(storage, 'distcomp.filestorage')
    error('distcomp:lsfscheduler:InvalidStorage', 'Currently the only supported storage type for non-shared filesystems is filestorage');
end


% Define the function that will be used to decode the environment variables
setenv('MDCE_DECODE_FUNCTION', 'decodeLsfSingleZippedTask');

% Ask the storage object how it would like to serialize itself and be
% reconstructed at the far end - note that the storage object will be
% reconstructed in CWD at the far end
[stringLocation, stringConstructor] = storage.getSubmissionStrings;
setenv('MDCE_STORAGE_CONSTRUCTOR', stringConstructor);

% Get the location of the storage
jobLocation = job.pGetEntityLocation;
setenv('MDCE_JOB_LOCATION', jobLocation);


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
% Reduce the job in question to a series of zip files for compactness
storageLocation = storage.StorageLocation;

% Currently LSF doesn't correctly transfer files if we place a space in
% the -f argument to bsub so we need to throw an error rather than 
% proceed if this is the case - see GECK 322231
if any(isspace(storageLocation))
    error('distcomp:lsfscheduler:UnableToSubmit', ...
    ['LSF cannot copy files to the remote machine if the DataLocation contains any whitespace characters\n' ...
    'Please use a DataLocation that does not contain spaces or whitespace%s'], '.');
end

localJobLoc   = [storageLocation filesep jobLocation];
remoteJobLoc  = ['%J.mdce/' jobLocation];
localTaskLoc  = [localJobLoc filesep 'Task%I'];
remoteTaskLoc = [remoteJobLoc '/Task%I'];
logRelToStorage = [jobLocation, '/Task%I.log'];
% Create taskIDString from the ID's of the tasks in this job
taskIDString = lsf.pMakeTaskIDString(tasks);
% And create the correct file transfer commands - we are going to copy
% the Job zip file and the Task zip file to the relevant host - they
% will be named LSB_JOBID.Job.zip and LSB_JOBID.LSB_JOBINDEX.Task.zip.
% The far end will then unzip them into a directory called
% LSB_JOBID.mdce. We will then need to
filesToCopy = {...
    ['-f "' localJobLoc '.zip > %J.Job.zip"'] ...
    ['-f "' localJobLoc filesep 'Task%I.zip > %J.%I.Task.zip"'] ...
    ['-f "' localJobLoc  '.common.mat  < ' remoteJobLoc  '.common.mat"'] ...
    ['-f "' localJobLoc  '.out.mat     < ' remoteJobLoc  '.out.mat"'] ...
    ['-f "' localJobLoc  '.state.mat   < ' remoteJobLoc  '.state.mat"'] ...    
    ['-f "' localTaskLoc '.common.mat  < ' remoteTaskLoc '.common.mat"'] ...
    ['-f "' localTaskLoc '.out.mat     < ' remoteTaskLoc '.out.mat"'] ...
    ['-f "' localTaskLoc '.state.mat   < ' remoteTaskLoc '.state.mat"'] ...
    ['-f "' localTaskLoc '.log         < ' remoteTaskLoc '.log"'] ...
    };
filesToCopy = sprintf('%s ', filesToCopy{:});

% Check for non-empty logLocation and add the -o in front 
logLocation = ['-o ' quote remoteTaskLoc '.log' quote];

submitString = sprintf(...
    'bsub -H -J "%s[%s]" %s  %s  %s  %s'  , ...
    jobLocation, ...
    taskIDString, ...
    logLocation, ...
    filesToCopy, ...
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
% Zip up the out going files after we have finished modifying the common file
storage.serializeForSubmission(job);
% Now set the job actually running by moving it from the PSUSP state to the
% PEND state
[FAILED, out] = dctSystem(sprintf('bresume "%d[%s]"', lsfID, taskIDString));
if FAILED
    error('distcomp:lsfscheduler:UnableToFindService', ...
        'Error executing the LSF script command ''bresume''. The reason given is \n %s', out);
end
