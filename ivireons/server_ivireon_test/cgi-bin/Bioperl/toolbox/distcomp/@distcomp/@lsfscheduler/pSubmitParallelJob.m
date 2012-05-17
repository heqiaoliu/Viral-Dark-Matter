function pSubmitParallelJob( lsf, job )
; %#ok Undocumented
%pSubmitParallelJob submit a parallel job to LSF
%
%  pSubmitParallelJob(SCHEDULER, JOB)

%  Copyright 2005-2008 The MathWorks, Inc.

%  $Revision: 1.1.6.5 $    $Date: 2008/06/24 17:01:32 $ 

if ~lsf.HasSharedFilesystem
    error( 'distcomp:lsfscheduler:parallelshared', ...
           'Parallel execution requires a shared filesystem' );
end

% Warning to indicate that we are going to change CWD
if lsf.pCwdIsUnc 
    warning('distcomp:lsfscheduler:DirectoryChange', ...
        ['The current working directory is a UNC path. To correctly execute LSF commands we will\n' ...
         'have to change to the directory given by tempdir. We will change back afterwards.%s'],'');
end

% Duplicate the tasks for parallel execution
job.pDuplicateTasks;

% Ensure that the job has been prepared
job.pPrepareJobForSubmission;

% Define the function that will be used to decode the environment variables
setenv('MDCE_DECODE_FUNCTION', 'decodeLsfSimpleParallelTask');
storage = job.pReturnStorage;
% Ask the storage object how it would like to serialize itself and be
% reconstructed at the far end
[stringLocation, stringConstructor] = storage.getSubmissionStrings;
setenv('MDCE_STORAGE_LOCATION', stringLocation);
setenv('MDCE_STORAGE_CONSTRUCTOR', stringConstructor);

% Get the location of the storage
jobLocation = job.pGetEntityLocation;
setenv('MDCE_JOB_LOCATION', jobLocation);

% On unix we need to protect the matlab command in a single quoted string
% but on windows we need to use double quotes (This is because the string
% might contain something like \\server on unix and the shell interprets
% the \\ as an escaped \ rather than \\ unless we use '. 
if ispc
    quote = '"';
else
    quote = '''';
end

% For parallel execution, we simply forward ClusterMatlabRoot to the cluster
% using an environment variable. This means we don't need to worry about
% quoting it here.
if ~isempty( lsf.ClusterMatlabRoot )
    setenv( 'MDCE_CMR', lsf.ClusterMatlabRoot );
else
    setenv( 'MDCE_CMR', '' );
end

% For parallel execution, the wrapper script chooses which matlab executable
% to launch via mpiexec, so we only pass the options that need to be added
% to the MATLAB command-line.
matlabCommand = lsf.pCalculateMatlabCommandForJob(job);


% Copy the wrapper script to somewhere we know it will be accessible on the
% cluster - i.e. put it within the job subdirectory. This relies on
% filestorage. To support some other sort of storage, we could simply pipe
% the contents of the wrapper script into the bsub command
if isa( storage, 'distcomp.filestorage' )
    % All the work here will be done by pJobSpecificFile
else
    error( 'distcomp:lsfscheduler:NotFileStorage', ...
           'The LSF scheduler may only use file storage for executing parallel jobs' );
end

if strcmp( lsf.ClusterOsType, 'mixed' )
    error( 'distcomp:lsfscheduler:BadClusterType', ... 
           ['The LSF scheduler cannot operate on ''mixed'' worker machines. Please configure ', ...
            'the scheduler to have ClusterOsType ''pc'' or ''unix'''] );
end

% Deal with the copying the wrapper script into the job subdirectory. 
if exist( lsf.ParallelSubmissionWrapperScript, 'file' )

    [junk, shortPart, ext] = fileparts( lsf.ParallelSubmissionWrapperScript ); %#ok
    
    [clientWrapper, scriptOnCluster] = lsf.pJobSpecificFile( job, [shortPart, ext], false );
    
    [success, message] = copyfile( lsf.ParallelSubmissionWrapperScript, ...
                                           clientWrapper );
    if ~success
        error( 'distcomp:lsfscheduler:copyerror', ...
               'An error occurred while copying "%s" to "%s". The message was: \n%s', ...
               lsf.ParallelSubmissionWrapperScript, clientWrapper, message );
    end
    
    % We are actually testing the client here - whereas it's really the worker
    % OS type that matters. But, PC workers don't care about the execute
    % bit, and windows clients default to copying files with "+x" set for
    % UNIX workers.
    if isunix
        [success, message] = fileattrib( clientWrapper, '+x' );
        if ~success
            error( 'distcomp:lsfscheduler:copyerror', ...
                   'An error occurred while making the file "%s" executable. The message was: \n%s', ...
                   clientWrapper, message );
        end
    end
    
    [clientLogLocation, clusterLogLocation] = lsf.pJobSpecificFile( job, 'Job.mpiexec.out', false ); %#ok
    logRelToStorage = [job.pGetEntityLocation, '/Job.mpiexec.out'];
    logLocation = ['-o ', quote, clusterLogLocation, quote];
else
    error( 'distcomp:lsfscheduler:NoWrapperScript', ...
           ['Could not find the wrapper script file "%s". \n', ...
            'The wrapper script must exist on the client machine prior to submission'], ...
           lsf.ParallelSubmissionWrapperScript );
end

% Here, we need to quote the scriptOnCluster in such a way that LSF will
% correctly execute that script. We need to quote the script name twice to
% protect against the system command AND LSF's execution of that command.
if ispc
    % Use a backslash-protected double-quote
    quotedScript = ['"\"', scriptOnCluster, '\""'];
else
    % Use a single-quote-protected double-quote
    quotedScript = ['''"', scriptOnCluster, '"'''];
end

submitString = sprintf( 'bsub -H -J %s -n %d,%d %s %s %s %s', ...
                        jobLocation, job.MinimumNumberOfWorkers, ...
                        job.MaximumNumberOfWorkers, ...
                        logLocation, ...
                        lsf.SubmitArguments, ...
                        quotedScript, matlabCommand );

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
schedulerData = struct('type', 'lsf', 'lsfID', lsfID, 'logRelToStorage', logRelToStorage );
job.pSetJobSchedulerData(schedulerData);
% Now set the job actually running by moving it from the PSUSP state to the
% PEND state
[FAILED, out] = dctSystem(sprintf('bresume "%d"', lsfID));
if FAILED
    error('distcomp:lsfscheduler:UnableToFindService', ...
        'Error executing the LSF script command ''bresume''. The reason given is \n %s', out);
end
