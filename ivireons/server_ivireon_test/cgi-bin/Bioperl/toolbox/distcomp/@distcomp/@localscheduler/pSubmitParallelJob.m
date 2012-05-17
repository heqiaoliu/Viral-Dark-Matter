function pSubmitParallelJob(local, job)
; %#ok Undocumented
%pSubmitParallelJob - submit a job
%
%  pSubmitParallelJob(SCHEDULER, JOB)

%  Copyright 2006-2010 The MathWorks, Inc.

%  $Revision: 1.1.6.12.4.1 $    $Date: 2010/06/24 19:32:56 $

USE_MPIEXEC = distcomp.feature( 'LocalUseMpiexec' );

if USE_MPIEXEC
    smpdPort = iGetSmpdPort();
    if smpdPort == -1
        warning( 'distcomp:localscheduler:NoSMPD', ...
                 'Couldn''t launch SMPD process manager, using fallback parallel mechanism' );
        USE_MPIEXEC = false;
    end
end

numTasks = numel(job.Tasks);
if numTasks < 1
    error('distcomp:localscheduler:InvalidState', 'A job must have at least one task to submit to a local scheduler');
end
% Get the maximum and minimum number of workers
minW = job.MinimumNumberOfWorkers;
maxW = min(job.MaximumNumberOfWorkers, local.MaximumNumberOfWorkers);

if minW > local.MaximumNumberOfWorkers
    error('distcomp:localscheduler:InvalidArgument',...
        ['You requested a minimum of %d workers but only %d workers '...
         'are allowed with the local scheduler.'], ...
          minW, local.MaximumNumberOfWorkers);

end
if minW > local.ClusterSize
    error('distcomp:localscheduler:InvalidArgument',...
        ['You requested a minimum of %d workers, but the scheduler''s '...
         'ClusterSize property is currently set to allow a maximum of %d workers. ' ...
         'The default value for ClusterSize with a local scheduler is the ' ...
         'number of cores on the local machine. To run a parallel job with more tasks ' ...
         'than this, increase the ClusterSize property setting in the local configuration.'], ...
          minW, local.ClusterSize);
end
if maxW < 1
    error('distcomp:localscheduler:InvalidArgument',...
        ['The job was not submitted to the local scheduler because the MaximumNumberOfWorkers\n' ...
         'property was set to 0. The job would never start running with this value.'], '');
end
% Duplicate the tasks for parallel execution
job.pDuplicateTasks;
% Ensure that the job has been prepared
job.pPrepareJobForSubmission;
% Get all the duplicated tasks
tasks = job.Tasks;
numTasks = numel(tasks);

storage = job.pReturnStorage;
logRoot = storage.StorageLocation;
% Ask the storage object how it would like to serialize itself and be
% reconstructed at the far end
[stringLocation, stringConstructor] = storage.getSubmissionStrings;

% URLEncode the stringLocation. Ultimately, we'd like to do this everywhere.
stringLocation = urlencode( stringLocation );

% Get the location of the storage
jobLocation = iCorrectSlash(job.pGetEntityLocation);

% Store the root directory of the job
jobRoot = fullfile( logRoot, jobLocation );

% Get the full matlab command to run
[~, mlcommand, mlargs] = local.pCalculateMatlabCommandForJob(job);
% Convert the args to a cell array of whitespace delimited strings
mlargs = strread(mlargs, '%s');
% Prepend the matlab command to create the array of strings for java to execute
commandArray = [{mlcommand} ; mlargs];
% Define where to write the logs to
logRelativeToRoot = fullfile(jobLocation, [jobLocation '.log']);
logLocation = fullfile(logRoot, logRelativeToRoot);

% envNames and values are all shared names AND values
envNames = {...
    'MDCE_STORAGE_LOCATION' ...
    'MDCE_STORAGE_CONSTRUCTOR' ...
    'MDCE_JOB_LOCATION' ...
    'MDCE_PID_TO_WATCH' ...
    'MDCE_PARALLEL' ...
    'MDCE_USE_ML_LICENSING', ....
    };

envValues = {...
    stringLocation ...
    stringConstructor ...
    jobLocation ...
    sprintf('%d',feature('getpid')) ...
    '1' ...
    'true' ...
    };

% Tell the ConnectionManager for pmode/matlabpool to connect us directly on
% the numeric localhost address
if isempty( getenv( 'MDCE_OVERRIDE_CLIENT_HOST' ) )
    envNames{end+1}  = 'MDCE_OVERRIDE_CLIENT_HOST'; % append these to envNames
    envValues{end+1} = '127.0.0.1';
end

% Tell MPICH2 to use 127.0.0.1 directly - thereby avoiding any problems that
% may occur on a machine that cannot resolve its own host name. We even do
% this for mpiexec, even though I'm not 100% sure if it's used.
if isempty( getenv( 'MPICH_INTERFACE_HOSTNAME' ) )
    envNames{end+1} = 'MPICH_INTERFACE_HOSTNAME';
    envValues{end+1} = '127.0.0.1';
end

% MPIEXEC or not variance here
if USE_MPIEXEC
    % Just define extraNames /values in one go here
    extraNames  = { 'MDCE_DECODE_FUNCTION' };
    extraValues = { 'decodeLocalMpiexecParallelTask' };
else
    % Use the connect/accept decode function, and force the "sock" MPI build.
    extraNames  = { 'MDCE_DECODE_FUNCTION', ...
                    'MDCE_SENTINAL_LOCATION', ...
                    'MDCE_FORCE_MPI_OPTION' };

    extraValues = { 'decodeLocalParallelTask', ...
                    fullfile(logRoot, jobLocation, 'mpi'), ...
                    'sock' };
end

% The full environment to inject
envNames  = [ envNames, extraNames ];
envValues = [ envValues, extraValues ];

% Fill out the environment with other stuff that has changed.
[envNames, envValues] = local.pCreateEnvironmentVariableArrays(envNames, envValues);

if USE_MPIEXEC
    import com.mathworks.toolbox.distcomp.local.MpiexecJobCommand;
    mpiexecCmdArray = iMpiexecArgs( smpdPort, envNames );
    javaTask = MpiexecJobCommand.getNewInstance( mpiexecCmdArray, commandArray, envNames, envValues, ...
                                                              jobRoot, logLocation, [minW maxW] );
else
    import com.mathworks.toolbox.distcomp.local.ParallelJobCommand;
    javaTask = ParallelJobCommand.getNewInstance(commandArray, envNames, envValues, logLocation, [minW maxW]);
end

% Data returned from local -
% localTaskUUIDs : the local task ID for each task - NOTE for parallel jobs where
%                  there is only one actual task every real task will map to
%                  the same local task
% taskIDs        : the ID of the distcomp.abstracttask associated with a local
%                  task in the field above. It is an error for taskIDs and
%                  localTaskUUIDs to be of different lengths.
schedulerData = struct('type', 'local', ...
                       'taskUUIDs', {repmat({javaTask.getUUID}, numTasks, 1)} , ...
                       'taskIDs', {1:numTasks}, ...
                       'submitProcInfo', local.ProcessInformation, ...
                       'logRelToStorage', {logRelativeToRoot});
job.pSetJobSchedulerData(schedulerData);

javaTask.submit;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function string = iCorrectSlash(string)
persistent goodSlash;
persistent badSlash;

if isempty(goodSlash)
    % Need to define what a good and bad slash looks like to ensure that we get everything correct
    if isunix
        badSlash  = '\';
        goodSlash = '/';
    else
        badSlash  = '/';
        goodSlash = '\';
    end
end
string = strrep(string, badSlash, goodSlash);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate a passphrase to use for the SMPD daemon
function x = iPassPhrase()

persistent PHRASE
if isempty( PHRASE )
    PHRASE = sprintf( 'MATLAB_%d', feature( 'getpid' ) );
end
x = PHRASE;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function port = iGetSmpdPort()

% Get the java-side process manager
mgr = com.mathworks.toolbox.distcomp.local.SmpdDaemonManager.getManager();

% Choose the full path to smpd(.exe)
cmd = fullfile( matlabroot, 'bin', dct_arch, 'smpd' );

% Give smpd a temp filename to write stuff into if it sees fit.
smpdFile = [tempname '.smpd'];

% The full smpd command-line:
%   "-anyport" says open any port - we're only expecting loopback connections,
%     so this should be fine.
%   "-phrase MATLAB_<pid>" keeps things unique
%   "-smpdfile <tempname>.smpd" tells smpd to dump stuff in there if needed
%   "-d 0" says run in the foreground, printing nothing as debug info.
cmdAndArgs = { cmd, '-anyport', '-phrase', iPassPhrase(), '-smpdfile', ...
               smpdFile, '-d', '0' };

% Additions to the environment injected here: 
names = { 'MPICH_PID_SENTINEL' };
values = { num2str( system_dependent( 'getpid' ) ) };

% The java code will attempt to delete the smpdfile at a later stage.
port = mgr.getSmpdPort( cmdAndArgs, names, values, smpdFile );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Build the full MPIEXEC command line
function cmdArray = iMpiexecArgs( port, envNames )

% Calculate the full path to the mpiexec executable
cmd = fullfile( matlabroot, 'bin', dct_arch, 'mpiexec' );

% Build the genvlist portion
eNames = sprintf( '%s,', envNames{:} );
eArgs = { '-genvlist', eNames(1:end-1) };

% Concoct the complete argument list
cmdArray = [cmd, eArgs, {'-phrase', iPassPhrase(), '-port', num2str( port ), '-l'  }];

end
