function runprop = sgeDecodeFunc( runprop )
% This function is referenced by sgeSubmitFcn. 
% THIS FUNCTION MUST BE ON THE PATH OF THE MATLAB WORKERS;
% typically, this is accomplished by putting this function into 
% $MATLABROOT/toolbox/local on the workers, or changing 
% to the directory where this function is, before starting those 
% MATLAB workers.

% Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:05:16 $

% Read environment variables into local variables. The names of
% the environment variables were determined by the submit function
storageConstructor = getenv( 'MDCE_STORAGE_CONSTRUCTOR' );
storageLocation = getenv( 'MDCE_STORAGE_LOCATION' );
jobLocation = getenv( 'MDCE_JOB_LOCATION' );
taskLocation = getenv( 'MDCE_TASK_LOCATION' );

% Set runprop properties from the local variables:
set( runprop, ...
    'StorageConstructor', storageConstructor, ...
    'StorageLocation', storageLocation, ...
    'JobLocation', jobLocation, ....
    'TaskLocation', taskLocation );
