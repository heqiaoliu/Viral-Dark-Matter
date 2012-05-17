function runprop = decodeCcsSingleTask(runprop)

% Copyright 2004-2010 The MathWorks, Inc.

%  $Revision: 1.1.6.4 $    $Date: 2010/03/22 03:42:42 $

CCS_JOB_ID  = getenv('CCP_JOBID');
CCS_TASK_ID = getenv('CCP_TASKID');
% Get a function handle to set status messages for lsf on this particular
% task - this will set the default message handler to be lsfSet
dctSchedulerMessage(2, 'In decodeCcsSingleTask');


storageConstructor = getenv('MDCE_STORAGE_CONSTRUCTOR');
storageLocation = getenv('MDCE_STORAGE_LOCATION');
jobLocation = getenv('MDCE_JOB_LOCATION');
taskLocation = getenv('MDCE_TASK_LOCATION');
    

% Need to tell the job runner where it's dependency directory is
dependencyDir = [tempdir CCS_JOB_ID '.' CCS_TASK_ID '.mdce.temp'];

set(runprop, ...
    'StorageConstructor', storageConstructor, ...
    'StorageLocation', storageLocation, ...
    'JobLocation', jobLocation, ....
    'TaskLocation', taskLocation, ...
    'LocalSchedulerName', 'hpcserver', ...    
    'DependencyDirectory', dependencyDir);
