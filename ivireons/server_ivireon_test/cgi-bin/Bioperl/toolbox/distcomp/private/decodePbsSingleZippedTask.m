function runprop = decodePbsSingleZippedTask( runprop )

%   Copyright 2007-2010 The MathWorks, Inc.

import com.mathworks.toolbox.distcomp.distcompobjects.SchedulerProxy

try
    TASK_ID = getenv('MDCE_TASK_ID');
    
    jobZipFile = 'Job.zip';
    taskZipFile = sprintf( 'Task.%s.zip', TASK_ID );
    
    unzip( jobZipFile, pwd );
    unzip( taskZipFile, pwd );
    
    delete(jobZipFile);
    delete(taskZipFile);
    
    storageConstructor = getenv('MDCE_STORAGE_CONSTRUCTOR');
    storageLocation    = getenv('MDCE_STORAGE_LOCATION');
    jobLocation        = getenv('MDCE_JOB_LOCATION');
    schedType          = getenv('MDCE_SCHED_TYPE');

    taskLocation = [jobLocation filesep 'Task' TASK_ID];

    dependencyDir = getenv( 'TMPDIR' );
    if ~isempty( dependencyDir )
        set( runprop, 'DependencyDirectory', fullfile( dependencyDir, 'mdce.tmp' ) );
    end
        
    set(runprop, ...
        'StorageConstructor', storageConstructor, ...
        'StorageLocation', storageLocation, ...
        'JobLocation', jobLocation, ....
        'TaskLocation', taskLocation, ...
        'LocalSchedulerName', schedType, ...    
        'HasSharedFilesystem', false);
catch err
    dctSchedulerMessage( 1, 'Caught error: %s', err.message );
end

