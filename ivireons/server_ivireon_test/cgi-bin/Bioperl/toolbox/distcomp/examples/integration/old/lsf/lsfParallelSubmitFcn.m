function lsfParallelSubmitFcn( scheduler, job, props, varargin )
%lsfParallelSubmitFcn - parallel submission for LSF

% Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:04:08 $

% Set up the environment for the decode function - the wrapper shell script
% will ensure that all these are forwarded to the MATLAB workers.
setenv( 'MDCE_DECODE_FUNCTION', 'lsfParallelDecode' );
setenv( 'MDCE_STORAGE_LOCATION', props.StorageLocation );
setenv( 'MDCE_STORAGE_CONSTRUCTOR',props.StorageConstructor );
setenv( 'MDCE_JOB_LOCATION', props.JobLocation );
% Ask the workers to print debug messages by default:
setenv('MDCE_DEBUG', 'true');

% Set this so that the script knows where to find MATLAB, MW_SMPD and MW_MPIEXEC
% on the cluster. This might be empty - the wrapper script will deal with that
% eventuality.
setenv( 'MDCE_CMR', scheduler.ClusterMatlabRoot );

% Set this so that the script knows where to find MATLAB, SMPD and MPIEXEC on
% the cluster. This might be empty - the wrapper script must deal with that.
setenv( 'MDCE_MATLAB_EXE', props.MatlabExecutable );
setenv( 'MDCE_MATLAB_ARGS', props.MatlabArguments );

% The wrapper script is in the same directory as this file
[dirpart] = fileparts( mfilename( 'fullpath' ) );
scriptName = fullfile( dirpart, 'lsfParallelWrapper.sh' );

% Forward the total number of tasks we're expecting to launch
setenv( 'MDCE_TOTAL_TASKS', num2str( props.NumberOfTasks ) );

% Choose a file for the output. Please note that currently, DataLocation refers
% to a directory on disk, but this may change in the future.
logFile = fullfile( scheduler.DataLocation, ...
                    sprintf( 'Job%d.mpiexec.out', job.ID ) );

% Finally, submit to LSF. note the following:
% "-J Job#" - specifies the job name
% "-o ..." specifies where standard output and error goes to
cmdLine = sprintf( 'bsub -J Job%d -o "%s" -n %d "%s"', ...
                   job.ID, logFile, props.NumberOfTasks, scriptName );
[s, w] = system( cmdLine );

% Report an error if the script did not execute correctly.
if s
    warning( 'distcompexamples:generic:LSF', ...
             'Submit failed with the following message:\n%s', w);
else
    % The output of successful submissions shows the LSF job identifier%
    fprintf( 1, 'Job output will be written to: %s\nBSUB output: %s\n', logFile, w );
end

