function runprop = lsfNonSharedJobArrayDecodeFcn( runprop )
%LSFNONSHAREDJOBARRAYDECODEFCN Prepares a worker to run a MATLAB task.
% This function is referenced by lsfNonSharedJobArraySubmitFcn.
% THIS FUNCTION MUST BE ON THE PATH OF THE MATLAB WORKERS;
% typically, this is accomplished by putting this function into
% $MATLABROOT/toolbox/local on the workers, or changing
% to the directory where this function is, before starting those
% MATLAB workers.

% Copyright 2006 The MathWorks, Inc.

% Read environment variables into local variables. The names of
% the environment variables were determined by the submit function
storageConstructor = getenv('MDCE_STORAGE_CONSTRUCTOR');
storageLocation = getenv('MDCE_STORAGE_LOCATION');
jobLocation = getenv('MDCE_JOB_LOCATION');
taskLocationPrefix = getenv('MDCE_TASK_LOCATION_PREFIX');

% Get the index of this job in the LSF job array.
lsfTaskIndex = getenv('LSB_JOBINDEX');
taskLocation = [taskLocationPrefix lsfTaskIndex];

% Use the taskLocation appended to the current tempdir for the 
% dependency directory
dependencyDir = [tempdir taskLocation];

% Set runprop properties from the local variables:
set(runprop, ...
        'StorageConstructor', storageConstructor, ...
        'StorageLocation', storageLocation, ...
        'JobLocation', jobLocation, ...
        'TaskLocation', taskLocation, ...
        'DependencyDirectory', dependencyDir);
