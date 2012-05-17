function runprop = decodePbsSingleTask( runprop )

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2007/11/09 20:08:05 $

storageConstructor = getenv('MDCE_STORAGE_CONSTRUCTOR');
storageLocation    = getenv('MDCE_STORAGE_LOCATION');
jobLocation        = getenv('MDCE_JOB_LOCATION');
schedType          = getenv('MDCE_SCHED_TYPE');
taskLocation       = [jobLocation filesep 'Task' getenv( 'MDCE_TASK_ID' ) ];

% Need to tell the job runner where it's dependency directory is - use PBS's
% TMPDIR if it exists
dependencyDir = getenv( 'TMPDIR' );
if ~isempty( dependencyDir )
    dependencyDir = fullfile( dependencyDir, 'mdce.temp' );
    set( runprop, 'DependencyDirectory', dependencyDir );
end

set(runprop, ...
    'StorageConstructor', storageConstructor, ...
    'StorageLocation', storageLocation, ...
    'JobLocation', jobLocation, ....
    'TaskLocation', taskLocation, ...
    'LocalSchedulerName', schedType);
