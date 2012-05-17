function workerDecodeFunc(runprop)
% This function is referenced by SubmitFunc. If a generic
% scheduler has been created with SubmitFcn = 'submitFunc', this
% function will be called on the MATLAB workers started by that
% generic scheduler. 
% THIS FUNCTION MUST BE ON THE PATH OF THOSE MATLAB WORKERS;
% typically, this is accomplished by putting this function into 
% $MATLABROOT/toolbox/local on the workers, or changing 
% to the directory where this function is, before starting those 
% MATLAB workers.
%
% Read environment variables into local variables. The names of
% the environment variables were determined by submitFunc.
storageConstructor = getenv('MDCE_STORAGE_CONSTRUCTOR');
storageLocation = getenv('MDCE_STORAGE_LOCATION');
jobLocation = getenv('MDCE_JOB_LOCATION');
taskLocation = getenv('MDCE_TASK_LOCATION');
%
% Set runprop properties from the local variables:
set(runprop, ...
    'StorageConstructor', storageConstructor, ...
    'StorageLocation', storageLocation, ...
    'JobLocation', jobLocation, ....
    'TaskLocation', taskLocation);
