function runprop = parallelDecodeFcn(runprop)
%PARALLELDECODEFCN Prepares a worker to run a MATLAB task in a parallel job.

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2010/03/22 03:42:07 $

dctSchedulerMessage(2, 'In parallel.cluster.generic.parallelDecodeFcn');

% Read environment variables into local variables. The names of
% the environment variables were determined by the submit function
storageConstructor = getenv('MDCE_STORAGE_CONSTRUCTOR');
storageLocation = getenv('MDCE_STORAGE_LOCATION');
jobLocation = getenv('MDCE_JOB_LOCATION');
% For a parallel job, the task location is derived from labindex
taskLocation = fullfile(jobLocation, sprintf('Task%d', labindex));

% Set runprop properties from the local variables:
set(runprop, ...
        'StorageConstructor', storageConstructor, ...
        'StorageLocation', storageLocation, ...
        'JobLocation', jobLocation, ...
        'TaskLocation', taskLocation);
