function runprop = decodeLsfSingleZippedTask(runprop)

% Copyright 2005-2010 The MathWorks, Inc.

import com.mathworks.toolbox.distcomp.distcompobjects.SchedulerProxy

% We are being called with no shared file system - so we must unwrap and
% make the relevant directories for the file storage - we assume we are in
% something like /tmp where we have write access
JOB_ID  = getenv('LSB_JOBID');
TASK_ID = getenv('LSB_JOBINDEX');
% Get a function handle to set status messages for lsf on this particular
% task - this will set the default message handler to be lsfSet
if ~isempty(getenv('MDCE_DEBUG'))
    setSchedulerMessageHandler(lsfMessageHandler(JOB_ID, TASK_ID));
end
dctSchedulerMessage(2, 'In decodeLsfSingleZippedTask with JOB_ID : %s and TASK_ID : %s', JOB_ID, TASK_ID);

% Create a new directory to store the contents of this job - could be
% shared by several actual processes
storageLocation = [JOB_ID '.mdce'];

jobZipFile = [JOB_ID '.Job.zip'];
taskZipFile = [JOB_ID '.' TASK_ID '.Task.zip'];

if ~exist(storageLocation, 'dir')
    dctSchedulerMessage(2, 'About to create local storage location : %s and unzip Job zip file : %s', storageLocation, jobZipFile);
    % Make both the storageLocation and the jobLocation
    mkdir(storageLocation);
    % Unzip the Job info into the file - this should only happen on the
    % machine which creates the Job directory - subsequent tasks that
    % happen
    unzip(jobZipFile, storageLocation);    
end
dctSchedulerMessage(2, 'About to unzip Task zip file : %s', taskZipFile);
% Now add the tasks to storage
unzip(taskZipFile, storageLocation);
% Clean up the zip files ...
try
    dctSchedulerMessage(2, 'About to delete Job and Task zip files');
    delete(jobZipFile);
    delete(taskZipFile);
catch err %#ok<NASGU>
    dctSchedulerMessage(1, 'Failed to delete Job and Task zip files');    
end

% Need to tell the job runner where it's dependency directory is
dependencyDir = [tempdir JOB_ID '.' TASK_ID '.mdce.temp'];

storageConstructor = getenv('MDCE_STORAGE_CONSTRUCTOR');
jobLocation = getenv('MDCE_JOB_LOCATION');
taskLocation = [jobLocation filesep 'Task' TASK_ID];

set(runprop, ...
    'StorageConstructor', storageConstructor, ...
    'StorageLocation', storageLocation, ...
    'JobLocation', jobLocation, ....
    'TaskLocation', taskLocation, ...
    'DependencyDirectory', dependencyDir, ...
    'LocalSchedulerName', 'lsf', ...    
    'HasSharedFilesystem', false);

