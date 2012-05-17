function runprop = distributedDecodeFcn(runprop)
% DISTRIBUTEDDECODEFUNCTION Prepares a worker to run a MATLAB task in a distributed job.

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2010/03/22 03:42:06 $

dctSchedulerMessage(2, 'In parallel.cluster.generic.distributedDecodeFcn');

% Read environment variables into local variables. The names of
% the environment variables were determined by the submit function
storageConstructor = getenv('MDCE_STORAGE_CONSTRUCTOR');
storageLocation = getenv('MDCE_STORAGE_LOCATION');
jobLocation = getenv('MDCE_JOB_LOCATION');
taskLocation = getenv('MDCE_TASK_LOCATION');

% Set runprop properties from the local variables:
set(runprop, ...
        'StorageConstructor', storageConstructor, ...
        'StorageLocation', storageLocation, ...
        'JobLocation', jobLocation, ...
        'TaskLocation', taskLocation);



