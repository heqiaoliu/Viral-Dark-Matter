function runprop = decodeLsfSingleTask(runprop)

% Copyright 2005-2010 The MathWorks, Inc.

JOB_ID  = getenv('LSB_JOBID');
TASK_ID = getenv('LSB_JOBINDEX');
% Get a function handle to set status messages for lsf on this particular
% task - this will set the default message handler to be lsfSet
if ~isempty(getenv('MDCE_DEBUG'))
    setSchedulerMessageHandler(lsfMessageHandler(JOB_ID, TASK_ID));
end
dctSchedulerMessage(2, 'In decodeLsfSingleTask with JOB_ID : %s and TASK_ID : %s', JOB_ID, TASK_ID);


storageConstructor = getenv('MDCE_STORAGE_CONSTRUCTOR');
storageLocation    = getenv('MDCE_STORAGE_LOCATION');
jobLocation        = getenv('MDCE_JOB_LOCATION');
taskLocation       = [jobLocation filesep 'Task' TASK_ID];
    

% Need to tell the job runner where it's dependency directory is
dependencyDir = [tempdir JOB_ID '.' TASK_ID '.mdce.temp'];

set(runprop, ...
    'StorageConstructor', storageConstructor, ...
    'StorageLocation', storageLocation, ...
    'JobLocation', jobLocation, ....
    'TaskLocation', taskLocation, ...
    'DependencyDirectory', dependencyDir,...
    'LocalSchedulerName', 'lsf');

