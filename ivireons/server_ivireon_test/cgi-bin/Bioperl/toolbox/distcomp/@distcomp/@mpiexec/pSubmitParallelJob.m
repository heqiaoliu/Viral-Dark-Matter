function pSubmitParallelJob(mpiexec, job)
; %#ok Undocumented
%pSubmitParallelJob - submit a job for mpiexec
%
%  pSubmitParallelJob(SCHEDULER, JOB)

%  Copyright 2005-2008 The MathWorks, Inc.
%  $Revision: 1.1.6.8 $    $Date: 2009/02/06 14:16:54 $ 

% mpiexec cannot handle a non-shared filesystem
if ~mpiexec.HasSharedFilesystem
    error( 'distcomp:mpiexec:nonsharedfs', ...
           'MPIEXEC scheduler cannot support non-shared file systems' );
end

% mpiexec cannot work with 'mixed' workers
if strcmp( mpiexec.ClusterOsType, 'mixed' )
    error( 'distcomp:mpiexec:badworkertype', ...
           'The mpiexec scheduler cannot operate with "mixed" worker types' );
end

% Choose a quote character
if ispc
    quote = '"';  % Quote for PC systems
else
    quote = ''''; % protect $ with single quotes
end

% Duplicate the tasks for parallel execution
job.pDuplicateTasks;

% Ensure that the job has been prepared
job.pPrepareJobForSubmission;

% Create a string for the environment variables
env_string = '';

% Define the function that will be used to decode the environment variables
env_string = iEnvSetting( mpiexec.EnvironmentSetMethod, ...
                          env_string, 'MDCE_DECODE_FUNCTION', 'decodeMpiexecSingleTask', ...
                          quote );

% Ask the storage object how it would like to serialize itself and be
% reconstructed at the far end
storage = job.pReturnStorage;
[stringLocation, stringConstructor] = storage.getSubmissionStrings;
env_string = iEnvSetting( mpiexec.EnvironmentSetMethod, ...
                          env_string, 'MDCE_STORAGE_LOCATION', stringLocation, ...
                          quote );
env_string = iEnvSetting( mpiexec.EnvironmentSetMethod, ...
                          env_string, 'MDCE_STORAGE_CONSTRUCTOR', stringConstructor, ...
                          quote );

% Get the location of the storage
jobLocation = job.pGetEntityLocation;
env_string = iEnvSetting( mpiexec.EnvironmentSetMethod, ...
                          env_string, 'MDCE_JOB_LOCATION', jobLocation, ...
                          quote );

% Store the expected size of MPI_COMM_WORLD
env_string = iEnvSetting( mpiexec.EnvironmentSetMethod, ...
                          env_string, 'MDCE_WORLD_SIZE', ...
                          num2str( job.MaximumNumberOfWorkers ), ...
                          quote );

[junk, mlcmd, args] = mpiexec.pCalculateMatlabCommandForJob(job);

% Change bad slashes to good ones - fullfile might have given us bad ones
matlabCommand = sprintf( '%s%s%s%s', quote, mlcmd, quote, args );
                     
% Create the mpiexec command string with appropriate quoting 
mpiexecCommand = sprintf( '%s%s%s', quote, mpiexec.MpiExecFileName, quote); 
                     
% We only support the "MaximumNumberOfWorkers" property
numTasks = job.MaximumNumberOfWorkers;

% Build the full submission string
submitString = sprintf( ...
    '%s %s -n %d %s %s', ...
    mpiexecCommand, mpiexec.SubmitArguments, numTasks, env_string, matlabCommand );

% Create a file for writing MPIEXEC's stdout to. Put the full command line in
% there too.
stdout_fname = mpiexec.pJobSpecificFile( job, '.mpiexec.out' );
fh = fopen( stdout_fname, 'wt' );
if fh==-1
    error( 'distcomp:mpiexec:cantwrite', ...
           'Couldn''t write to file: %s', stdout_fname );
end
fprintf( fh, '%s\n', submitString );
fclose( fh );

storedEnv = distcomp.pClearEnvironmentBeforeSubmission();

if ispc
    % Create a temporary BAT file
    batName = mpiexec.pJobSpecificFile( job, '.bat' );
    fh = fopen( batName, 'wt' );
    if fh == -1
        error( 'distcomp:mpiexec:openfailed', ...
               'Couldn''t write to temporary batch file: %s', ...
               batName );
    end
    fprintf( fh, '@echo Running mpiexec...\n' );
    fprintf( fh, '@%s >> "%s" 2>&1\n', submitString, stdout_fname );
    fprintf( fh, '@exit\n' );
    fclose( fh );

    pid = dct_psfcns( 'winlaunchproc', batName, '' );
    % Wait to allow the batch script to launch mpiexec
    pid = iGetChildPidWithTimeout( pid, 5 );
    
    % Nothing to ignore in the pid name
    pidNameIgnorePattern = '';
else
    % Set the environment variable MDCE_INPUT_REDIRECT. This is used by the
    % exec_redirect.sh script on UNIX clients. We must always redirect stdin on
    % mac, otherwise the mpiexec process does not work correctly. Otherwiwse, we
    % only redirect stdin if the machine type is PC to prevent repeated
    % prompting for credentials. Note that piping stdin to mpiexec causes it to
    % max out CPU usage on UNIX platforms other than MAC, so we avoid this
    % wherever possible.
    if strcmp( mpiexec.WorkerMachineOsType, 'pc' )
        setenv( 'MDCE_INPUT_REDIRECT', 'yes' );
    elseif ismac
        setenv( 'MDCE_INPUT_REDIRECT', 'null' );
    else
        setenv( 'MDCE_INPUT_REDIRECT', 'no' );
    end

    % Call helper shell script which deals with stdout and stderr redirection
    scriptTrail = fullfile( 'bin', 'util', 'exec_redirect.sh' );
    script = fullfile( toolboxdir('distcomp'), scriptTrail );

    % Pre-allocate pid to be an invalid PID
    pid = 0;

    [s, w] = dctSystem( sprintf( '%s "%s" %s', script, stdout_fname, submitString ) );
    if s == 0
        pid = str2double( w );
        if isnan( pid )
            warning( 'distcomp:mpiexec:launch', ...
                     'Couldn''t determine the mpiexec process PID from the output: %s', w );
        end
    else
        warning( 'distcomp:mpiexec:launch', ...
                 ['The mpiexec launching script returned the following exit code: %d, ', ...
                  'and output: "%s"'], s, strtrim( w ) );
    end
        
    % Unset MDCE_INPUT_REDIRECT now we're done with it
    setenv('MDCE_INPUT_REDIRECT', ''  );
    
    % Ignore the exec redirect pattern in the PID name.
    pidNameIgnorePattern = scriptTrail;
end

% Try to extract the process name
try
    % If we get through to checking the name of the child PID too soon, it's
    % just about possible to see the name of the exec_redirect script if
    % there's a delay between the fork and exec pieces of the background
    % mpiexec launching. Therefore, make sure that the pid name we extract
    % doesn't match exec_redirect. 
    pidname = iGetPidNameWithTimeout( pid, pidNameIgnorePattern, 5 );
catch E %#ok<NASGU> ignore this exception - we're going to warn.
    % We only get here if there was a problem extracting the name from a living
    % process
    pidname = '<Unknown>';
    warning( 'distcomp:mpiexec:launch', ...
             'Couldn''t calculate the process name for mpiexec process %d', pid );
end

% Create scheduler data so that we can retrieve stdout.
schedulerData = struct( 'type', 'mpiexec', ...
                        'pid', pid, ...
                        'pidname', pidname, ...
                        'pidhost', mpiexec.ClientHostName );
job.pSetJobSchedulerData( schedulerData );

distcomp.pRestoreEnvironmentAfterSubmission( storedEnv );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iGetPidNameWithTimeout - Get the name of a given PID, but ignore the name
% if it contains our wrapper script - at least until the timeout expires
function name = iGetPidNameWithTimeout( pid, pattern, timeout )

timeWaited = 0;
pause_amt  = 0.25;
name       = dct_psname( pid );

% Get here if there's no pattern to ignore (i.e. Windows)
if isempty( pattern )
    return;
end

while ~isempty( strfind( name, pattern ) ) && ...
        timeWaited < timeout
    
    name = dct_psname( pid );
    
    if isempty( strfind( name, pattern ) )
        break;
    else
        pause( pause_amt );
        timeWaited = timeWaited + pause_amt;
    end
end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iGetChildPidWithTimeout - wait for the given PID to launch a child
% process. If after the timeout, the parent is alive but we haven't found a
% child, then warn. If the parent dies and we never find the child, just
% return the parent process.
function child = iGetChildPidWithTimeout( parent, timeout )

timeWaited = 0;
child = [];

% Note that the condition on children is that we wait until the number of
% children found is 1 - very occasionally (i.e. once, ever) I've seen
% multiple children returned.
pause_amt = 0.25;
while dct_psfcns( 'isalive', parent ) && ...
        length( child ) ~= 1 && ...
        timeWaited < timeout
    pause( pause_amt );
    timeWaited = timeWaited + pause_amt;
    child = dct_psfcns( 'winchildren', parent );
end

if isempty( child )
    child = parent;
    if dct_psfcns( 'isalive', parent )
        warning( 'distcomp:mpiexec:nochildprocesses', ...
                 'The mpiexec wrapper script unexpectedly failed to launch the mpiexec process' );
    end
else
    if length( child ) ~= 1
        error( 'distcomp:mpiexec:multiplechildprocesses', ...
               'The mpiexec wrapper script unexpectedly launched multiple child processes' );
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% i_EnvSetting - set up the environment - either append to a string or call
% setenv
function str = iEnvSetting( env_method, old_str, varname, varval, quote )

% Always set the output argument
str = old_str;

switch env_method
    case '-env'
        str = sprintf( '%s -env %s %s%s%s ', old_str, varname, quote, varval, quote );
    case 'setenv'
        setenv( varname, varval );
    otherwise
        % Can't happen because of the enum!
        error( 'distcomp:mpiexec:unknownenvironmentmethod', ...
               'Unknown EnvironmentSetMethod: %s (must be either ''-env'' or ''setenv'')', env_method );
end
