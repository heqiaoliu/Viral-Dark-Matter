function runprop = decodeLocalMpiexecParallelTask(runprop)

% Copyright 2004-2010 The MathWorks, Inc.

%  $Revision: 1.1.6.2.2.1 $    $Date: 2010/06/24 19:32:57 $

% Get a function handle to set status messages for lsf on this particular
% task - this will set the default message handler to be lsfSet
dctSchedulerMessage(2, 'In decodeLocalMpiexecParallelTask');

labIndexStr         = num2str( labindex );
storageConstructor  = getenv('MDCE_STORAGE_CONSTRUCTOR');
storageLocation     = urldecode( getenv('MDCE_STORAGE_LOCATION') );
jobLocation         = getenv('MDCE_JOB_LOCATION');
taskLocation        = [jobLocation filesep 'Task' labIndexStr ];
    
set(runprop, ...
    'StorageConstructor', storageConstructor, ...
    'StorageLocation', storageLocation, ...
    'JobLocation', jobLocation, ....
    'TaskLocation', taskLocation);

% Ensure that on unix we mask SIGINT and SIGSTOP as the shell 
% will send these signals to all members of the main MATLAB
% process group. Thus we will replace the handlers with functions
% that do nothing so we are unaffected by these signals
if isunix
    dctInstallLocalSignalHandler
end

