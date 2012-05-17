function setupForParallelExecution( lsf, type )
%setupForParallelExecution - set up options for submitting parallel jobs
%   setupForParallelExecution( lsf, 'pc' ) sets up the scheduler to expect
%   PC worker machines, and selects the wrapper script which expects to be
%   able to call "mpiexec -delegate" on the workers. Note that you will
%   still need to supply SubmitArguments to ensure that LSF schedules your
%   job to run only on PC workers. For example, including '-R type==NTX86'
%   in your SubmitArguments would select only 32-bit Windows workers.
%
%   setupForParallelExecution( lsf, 'pcNoDelegate' ) is similar to the 'pc'
%   mode, except that wrapper script does not attempt to call "mpiexec
%   -delegate", thereby assuming that you have installed some other means of
%   achieving passwordless authentication.
%
%   setupForParallelExecution( lsf, 'unix' ) sets up the scheduler to expect
%   UNIX worker machines, and selects the default wrapper script for UNIX
%   workers. Note that you will still need to supply SubmitArguments to
%   ensure LSF schedules your job to run only on UNIX workers. For example,
%   including '-R type==LINUX64' would select only 64-bit Linux workers.
%
%   Examples:
%
%   % From any client, set up the scheduler to work on PC workers
%   lsf = findResource( 'scheduler', 'Type', 'lsf' );
%   setupForParallelExecution( lsf, 'pc' );
%   lsf.SubmitArguments = '-R type==NTX86';
%   % Set up data location etc...
%
%   % From any client, set up the scheduler to work on UNIX workers
%   lsf = findResource( 'scheduler', 'Type', 'lsf' );
%   setupForParallelExecution( lsf, 'unix' );
%   lsf.SubmitArguments = '-R type==LINUX64';
%   % Set up data location etc...

% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.6.3 $   $Date: 2007/06/18 22:13:35 $

% Set both ClusterOsType and ParallelSubmissionWrapperScript
lsf.pSetupForParallelExecution( type, true, true );