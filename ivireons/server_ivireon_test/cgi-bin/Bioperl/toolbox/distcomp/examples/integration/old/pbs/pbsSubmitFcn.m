function pbsSubmitFcn(scheduler, job, props, varargin) 
%SUBMITFCN Submit a Matlab job to a PBS scheduler
%
% See also workerDecodeFunc.
%
% Assign the relevant values to environment variables, starting 
% with identifying the decode function to be run by the worker:

% Copyright 2006-2010 The MathWorks, Inc.

setenv('MDCE_DECODE_FUNCTION', 'pbsDecodeFunc'); 
% 
% Set the other job-related environment variables:
setenv('MDCE_STORAGE_LOCATION', props.StorageLocation); 
setenv('MDCE_STORAGE_CONSTRUCTOR', props.StorageConstructor);
setenv('MDCE_JOB_LOCATION', props.JobLocation); 
% Ask the workers to print debug messages by default:
setenv('MDCE_DEBUG', 'true');

% Tell the script what it needs to run. These two properties will
% incorporate ClusterMatlabRoot if it is set.
setenv( 'MDCE_MATLAB_EXE', props.MatlabExecutable );
setenv( 'MDCE_MATLAB_ARGS', props.MatlabArguments );

[dirpart] = fileparts( mfilename( 'fullpath' ) );
scriptName = fullfile( dirpart, 'pbsWrapper.sh' );

% Submit the wrapper script to PBS once for each task, supplying a different
% environment each time.
for i = 1:props.NumberOfTasks
    fprintf('Submitting task %i\n', i);
    setenv('MDCE_TASK_LOCATION', props.TaskLocations{i});
    % Choose a file for the output. Please note that currently, DataLocation refers
    % to a directory on disk, but this may change in the future.
    logFile = fullfile( scheduler.DataLocation, ...
                        sprintf( 'Job%d_Task%d.out', job.ID, job.Tasks(i).ID ) );
    % Finally, submit to PBS. note the following:
    % "-N Job#" - specifies the job name
    % "-j oe" joins together output and error streams
    % "-o ..." specifies where standard output goes to
    cmdLine = sprintf( 'qsub -N Job%d.%d -j oe -o "%s" "%s"', ...
                       job.ID, job.Tasks(i).ID, logFile, scriptName );
    [s, w] = system( cmdLine );

    if s ~= 0
        warning( 'distcompexamples:generic:PBS', ...
                 'Submit failed with the following message:\n%s', w);
    else
        % The output of successful submissions shows the PBS job identifier%
        fprintf( 1, 'Job output will be written to: %s\nQSUB output: %s\n', logFile, w );
    end
end
