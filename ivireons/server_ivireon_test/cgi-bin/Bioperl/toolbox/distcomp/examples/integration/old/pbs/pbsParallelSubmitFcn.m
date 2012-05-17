function pbsParallelSubmitFcn( scheduler, job, props, varargin )
%pbsParallelSubmitFcn - parallel submission for PBS

% Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:04:45 $

% Set up the environment for the decode function - the wrapper shell script
% will ensure that all these are forwarded to the MATLAB workers.
setenv( 'MDCE_DECODE_FUNCTION', 'pbsParallelDecode' );
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
scriptName = fullfile( dirpart, 'pbsParallelWrapper.sh' );

% Forward the total number of tasks we're expecting to launch
setenv( 'MDCE_TOTAL_TASKS', num2str( props.NumberOfTasks ) );

% Choose a file for the output. Please note that currently, DataLocation refers
% to a directory on disk, but this may change in the future.
logFile = fullfile( scheduler.DataLocation, ...
                    sprintf( 'Job%d.mpiexec.out', job.ID ) );

% Choose a number of processors per node to use (you will need to customise
% this section to match your cluster)
procsPerNode = 2;
nodes = ceil( props.NumberOfTasks / procsPerNode );
nodesArg = sprintf( '-l nodes=%d:ppn=%d', nodes, procsPerNode );

% Finally, submit to PBS. note the following:
% "-N Job#" - specifies the job name
% "-j oe" joins together output and error streams
% "-o ..." specifies where standard output goes to
cmdLine = sprintf( 'qsub -N Job%d -j oe -o "%s" %s "%s"', ...
                   job.ID, logFile, nodesArg, scriptName );
[s, w] = system( cmdLine );

% Report an error if the script did not execute correctly.
if s
    warning( 'distcompexamples:generic:PBS', ...
             'Submit failed with the following message:\n%s', w);
else
    % The output of successful submissions shows the PBS job identifier%
    fprintf( 1, 'Job output will be written to: %s\nQSUB output: %s\n', logFile, w );
end

