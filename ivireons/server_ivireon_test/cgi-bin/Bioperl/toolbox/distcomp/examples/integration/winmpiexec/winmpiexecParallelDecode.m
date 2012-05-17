function winmpiexecParallelDecode( runprop )
% This function is referenced by winmpiexecParallelSubmitFcn. 
% THIS FUNCTION MUST BE ON THE PATH OF THE MATLAB WORKERS;
% typically, this is accomplished by putting this function into 
% $MATLABROOT/toolbox/local on the workers, or changing 
% to the directory where this function is, before starting those 
% MATLAB workers.

% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $   $Date: 2006/12/27 20:41:06 $

% Read environment variables into local variables. The names of
% the environment variables were determined by the submit function.
storageConstructor = getenv( 'MDCE_STORAGE_CONSTRUCTOR' );
storageLocation    = getenv( 'MDCE_STORAGE_LOCATION' );
jobLocation        = getenv( 'MDCE_JOB_LOCATION' );

% For a parallel job, the task location is derived from labindex
taskLocation       = [jobLocation filesep 'Task' num2str( labindex ) ];

% Set runprop properties from the local variables:
set( runprop, ...
    'StorageConstructor', storageConstructor, ...
    'StorageLocation', storageLocation, ...
    'JobLocation', jobLocation, ....
    'TaskLocation', taskLocation );