function sshParallelSubmitFcn( scheduler, job, props, varargin )
%sshParallelSubmitFcn - submit script example
%   This example is designed to run only on UNIX workers. It works by
%   calling a wrapper shell script which uses SSH to launch SMPD processes
%   on each worker. The workers to use are specified by a hosts file which
%   is supplied to the submit function as an extra input argument - i.e. the
%   generic scheduler's ParallelSubmitFcn property must be specified like
%   this:
% 
%   s.ParallelSubmitFcn = {@sshParallelSubmitFcn, '/path/to/hosts.file'};
%
%   After completion of the mpiexec command, the SMPD processes are
%   destroyed again using SSH.

% Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.8.3 $   $Date: 2010/03/22 03:42:21 $

% Ensure that the cluster size is consistent with the job's 
% minimum number of workers
minProcessors = job.MinimumNumberOfWorkers;
if minProcessors > scheduler.ClusterSize
    error('distcompexamples:SSH:ResourceLimit', ...
        ['You requested a minimum of %d workers, but the scheduler''s ClusterSize property ' ...
        'is currently set to allow a maximum of %d workers.  ' ...
        'To run a parallel job with more tasks than this, increase the value of the ClusterSize ' ...
        'property for the scheduler.'], ...
        minProcessors, scheduler.ClusterSize);
end

% Set up the environment for the decode function - the wrapper shell script
% will ensure that all these are forwarded to the MATLAB workers.
setenv( 'MDCE_DECODE_FUNCTION', 'sshParallelDecode' );
setenv( 'MDCE_STORAGE_LOCATION', props.StorageLocation );
setenv( 'MDCE_STORAGE_CONSTRUCTOR',props.StorageConstructor );
setenv( 'MDCE_JOB_LOCATION', props.JobLocation );

% Tell the script how many parallel processes to launch
setenv( 'MDCE_NUM_PROCS', num2str( props.NumberOfTasks ) );

% Choose the smpd port to use - base this on the job ID
setenv( 'MDCE_SMPD_PORT', num2str( 20000 + mod( job.ID, 10000 ) ) ); 

% Set this so that the script knows where to find MATLAB, SMPD and MPIEXEC on
% the cluster. This might be empty - the wrapper script must deal with that.
setenv( 'MDCE_CMR', scheduler.ClusterMatlabRoot );

% Tell the script what it needs to run under MPIEXEC. These two properties
% will incorporate ClusterMatlabRoot if it is set.
setenv( 'MDCE_MATLAB_EXE', props.MatlabExecutable );
setenv( 'MDCE_MATLAB_ARGS', props.MatlabArguments );

% Tell the script which hosts file to use
if nargin < 4 || ~exist( varargin{1}, 'file' )
    error( 'example:generic', ...
           ['This example parallel submission file requires an extra argument\n', ...
            'to specify the hosts file to use. Please specify the ParallelSubmitFcn\n', ...
            'property of this scheduler like this:\n\n', ...
            'scheduler.ParallelSubmitFcn = {@%s, ''/path/to/hosts.file''}'], ...
           mfilename );
end
setenv( 'MDCE_HOSTS_FILE', varargin{1} );

% Choose a file for the output. Please note that currently, DataLocation refers
% to a directory on disk, but this may change in the future.
logFile = fullfile( scheduler.DataLocation, ...
                    sprintf( 'Job%d.mpiexec.out', job.ID ) );
fprintf( 1, 'mpiexec output directed to: %s\n', logFile );

% Assume script is in the same directory as this file
[dirpart] = fileparts( mfilename( 'fullpath' ) );
scriptName = fullfile( dirpart, 'sshParallelWrapper.sh' );

% Then execute the wrapper script
[s,w] = system( sprintf( '"%s" > "%s" &', scriptName, logFile ) );

% Report an error if the script did not execute correctly.
if s
    warning( 'distcompexamples:generic:SSH', ...
             'Submit failed with the following message:\n%s', w );
else
    disp( w );
end
