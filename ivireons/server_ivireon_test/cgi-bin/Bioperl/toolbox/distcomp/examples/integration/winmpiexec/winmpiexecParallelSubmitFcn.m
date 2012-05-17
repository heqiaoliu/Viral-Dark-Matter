function winmpiexecParallelSubmitFcn( scheduler, job, props, varargin )
%winmpiexecParallelSubmitFcn - parallel submission for mpiexec on Windows
%   This runs using the "-localonly" argument on windows to run MATLAB on the
%   local machine.

% Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.8.3 $   $Date: 2010/03/22 03:42:23 $

% Ensure that the cluster size is consistent with the job's 
% minimum number of workers
minProcessors = job.MinimumNumberOfWorkers;
if minProcessors > scheduler.ClusterSize
    error('distcompexamples:WINMPIEXEC:ResourceLimit', ...
        ['You requested a minimum of %d workers, but the scheduler''s ClusterSize property ' ...
        'is currently set to allow a maximum of %d workers.  ' ...
        'To run a parallel job with more tasks than this, increase the value of the ClusterSize ' ...
        'property for the scheduler.'], ...
        minProcessors, scheduler.ClusterSize);
end

% Set up the environment for the decode function - the wrapper shell script
% will ensure that all these are forwarded to the MATLAB workers.
setenv( 'MDCE_DECODE_FUNCTION', 'winmpiexecParallelDecode' );
setenv( 'MDCE_STORAGE_LOCATION', props.StorageLocation );
setenv( 'MDCE_STORAGE_CONSTRUCTOR',props.StorageConstructor );
setenv( 'MDCE_JOB_LOCATION', props.JobLocation );
% Ask the workers to print debug messages by default:
setenv('MDCE_DEBUG', 'true');

% These properties will already incorporate ClusterMatlabRoot if necessary.
matlabExe = props.MatlabExecutable;
matlabArgs = props.MatlabArguments;

% We find the local mpiexec since we're calling mpiexec on the client machine.
mpiexec = fullfile( matlabroot, 'bin', 'mw_mpiexec.bat' );

% Ask mpiexec to forward the environment variables:
envArg = '-genvlist MDCE_DECODE_FUNCTION,MDCE_STORAGE_LOCATION,MDCE_STORAGE_CONSTRUCTOR,MDCE_JOB_LOCATION,MDCE_DEBUG';

% Choose where to put the output from the mpiexec command
logFile = fullfile( scheduler.DataLocation, ...
                    sprintf( 'Job%d.mpiexec.out', job.ID ) );

% Build the command to be executed
cmdLine = sprintf( '%s -noprompt %s -localonly %d "%s" %s> "%s" 2>&1 & exit &', ...
                   mpiexec, envArg, props.NumberOfTasks, matlabExe, matlabArgs, logFile );

% Execute the command line
[s, w] = system( cmdLine );

if s
    % Report an error if the command did not execute correctly.
    warning( 'distcompexamples:generic:WINMPIEXEC', ...
             'Submit failed with the following message:\n%s', w);
else
    fprintf( 1, 'Job output will be written to: %s\n', logFile );
end


