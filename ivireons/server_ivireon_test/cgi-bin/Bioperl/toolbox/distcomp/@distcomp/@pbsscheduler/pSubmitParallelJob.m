function pSubmitParallelJob( pbs, job )
; %#ok Undocumented
%pSubmitParallelJob submit a parallel job to PBS
%
%  pSubmitParallelJob(SCHEDULER, JOB)

%  Copyright 2007-2010 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $    $Date: 2010/03/22 03:41:57 $ 

tasks = job.Tasks;

pbs.pPreSubmissionChecks( job, tasks );

% Duplicate the tasks for parallel execution
job.pDuplicateTasks;

% Ensure that the job has been prepared
job.pPrepareJobForSubmission;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generic things to do with setting up environment variables

% Define the function that will be used to decode the environment variables
setenv('MDCE_DECODE_FUNCTION', 'decodePbsSimpleParallelTask');
storage = job.pReturnStorage;
% Ask the storage object how it would like to serialize itself and be
% reconstructed at the far end
[stringLocation, stringConstructor] = storage.getSubmissionStrings;
setenv('MDCE_STORAGE_LOCATION', stringLocation);
setenv('MDCE_STORAGE_CONSTRUCTOR', stringConstructor);

% Get the location of the storage
jobLocation = job.pGetEntityLocation;
setenv('MDCE_JOB_LOCATION', jobLocation);

% For parallel execution, we simply forward ClusterMatlabRoot to the cluster
% using an environment variable. This means we don't need to worry about
% quoting it here.
if ~isempty( pbs.ClusterMatlabRoot )
    setenv( 'MDCE_CMR', pbs.ClusterMatlabRoot );
else
    setenv( 'MDCE_CMR', '' );
end

% For parallel execution, the wrapper script chooses which matlab executable
% to launch via mpiexec, so we only pass the options that need to be added
% to the MATLAB command-line.
[junk, matlabExe, matlabArgs] = pbs.pCalculateMatlabCommandForJob( job );

setenv( 'MDCE_MATLAB_EXE', matlabExe );
if ispc && isempty( matlabArgs )
    % Work around problem whereby an empty setting for this causes PBS to think
    % that it cannot send the environment
    matlabArgs = ' ';
end
setenv( 'MDCE_MATLAB_ARGS', matlabArgs );
setenv( 'MDCE_TOTAL_TASKS', num2str( numel( job.Tasks ) ) );
setenv( 'MDCE_REMSH', pbs.RshCommand );
if pbs.UsePbsAttach
    setenv( 'MDCE_USE_ATTACH', 'on' );
else
    setenv( 'MDCE_USE_ATTACH', 'off' );
end

% Store the scheduler type so the runprop on the far end can be correctly
% constructed. Ensure it's lower case for distcomp.getSchedulerUDDConstructor.
setenv( 'MDCE_SCHED_TYPE', lower( pbs.Type ) );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Everything to do with setting up the qsub command-line arguments
if ~isempty( pbs.ResourceTemplate )
    selectStr = strrep( pbs.ResourceTemplate, '^N^', num2str( length( job.Tasks ) ) );
else
    error( 'distcomp:pbsscheduler:noResourceTemplate', ...
           ['Please fill out a ResourceTemplate for the PBS scheduler, using the ', ...
            'syntax "^N^" to represent the number of tasks'] );
end

% Define the location for logs to be returned
[logLocation, relLog, absLog] = pbs.pChooseLogLocation( storage, job );

if strcmp( pbs.ClusterOsType, 'pc' )
    directive = '-C "REM PBS"';
else
    directive = ''; % use the default
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copy the submission script into the storage, and submit it directly from
% there. Under PBS, it doesn't matter if the submission script is not
% available on the cluster.

if isa( storage, 'distcomp.filestorage' )
    % All the work here will be done by pJobSpecificFile
else
    error( 'distcomp:pbsscheduler:NotFileStorage', ...
           'The PBS scheduler may only use file storage for executing parallel jobs' );
end

% Deal with the copying the wrapper script into the job subdirectory. 
if exist( pbs.ParallelSubmissionWrapperScript, 'file' )

    [junk, shortPart, ext] = fileparts( pbs.ParallelSubmissionWrapperScript ); %#ok
    
    clientWrapper = pbs.pJobSpecificFile( job, [shortPart, ext], false );
    
    [success, message] = copyfile( pbs.ParallelSubmissionWrapperScript, ...
                                   clientWrapper );
    if ~success
        error( 'distcomp:pbsscheduler:copyerror', ...
               'An error occurred while copying "%s" to "%s". The message was: \n%s', ...
               pbs.ParallelSubmissionWrapperScript, clientWrapper, message );
    end

    % We want to append to the file, so ensure it's writable
    [success, message] = fileattrib( clientWrapper, '+w' );
    doAppend = success;
    if ~success
        warning( 'distcomp:pbsscheduler:cantWriteToWrapper', ...
                 ['Couldn''t make the wrapper script writable - the ', ...
                  'qsub command line will not be appended. \n', ...
                  'The reason was: %s'], message );
    end
    
else
    error( 'distcomp:pbsscheduler:NoWrapperScript', ...
           ['Could not find the wrapper script file "%s". \n', ...
            'The wrapper script must exist on the client machine prior to submission'], ...
           pbs.ParallelSubmissionWrapperScript );
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Actual submission

pbsJobName = pbs.pChoosePBSJobName( sprintf( 'Job%d', job.ID ) );

submitString = sprintf( ['qsub -h ', ... held
                    '%s ', ... directive
                    '%s ', ... select clauses
                    '%s ', ... submit args
                    '%s ', ... log location
                    '-N %s ', ... job name
                    '"%s" '], ...
                        directive, ...
                        selectStr, pbs.SubmitArguments, ...
                        logLocation, pbsJobName, clientWrapper );

% Append the actual submission string to the wrapper
if doAppend
    pbs.pAppendSubmitString( clientWrapper, submitString );
end

storedEnv = distcomp.pClearEnvironmentBeforeSubmission();

try
    % Make the shelled out call to bsub.
    [FAILED, out] = pbs.pPbsSystem( submitString );
catch err
    FAILED = true;
    out = err.message;
end

distcomp.pRestoreEnvironmentAfterSubmission( storedEnv );

if FAILED
    error('distcomp:pbsscheduler:UnableToFindService', ...
          'Error executing the PBS script command ''qsub''. The reason given is \n %s', out);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Build the scheduler data
pbsJobId = pbs.pExtractJobId( out );

schedulerData = struct('type', 'pbs', ...
                       'usingJobArray', false, ...
                       'skippedTaskIDs', [], ...
                       'pbsJobIds', {{ pbsJobId }}, ...
                       'absLogLocation', absLog, ...
                       'relLogLocation', relLog );

job.pSetJobSchedulerData(schedulerData);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now set the job actually running 

[FAILED, out] = dctSystem(sprintf('qalter -h n "%s"', pbsJobId));
if FAILED
    error('distcomp:pbsscheduler:UnableToFindService', ...
          'Error executing the PBS script command ''qalter''. The reason given is \n %s', out);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

