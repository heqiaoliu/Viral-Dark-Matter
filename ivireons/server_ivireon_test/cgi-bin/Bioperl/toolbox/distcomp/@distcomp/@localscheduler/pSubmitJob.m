function pSubmitJob(local, job)
; %#ok Undocumented
%pSubmitJob - submit a job for local scheduler
%
%  pSubmitJob(SCHEDULER, JOB)

%  Copyright 2006-2009 The MathWorks, Inc.

%  $Revision: 1.1.6.4 $    $Date: 2009/07/14 03:53:01 $


tasks = job.Tasks;
numTasks = numel(tasks);
if numTasks < 1
    error('distcomp:localscheduler:InvalidState', 'A job must have at least one task to submit to a local schdeuler');
end
% Ensure that the job has been prepared
job.pPrepareJobForSubmission;
storage = job.pReturnStorage;

logRoot = storage.StorageLocation;
% Define the logLocationTemplate to use - remove the ID from the end of
% the first tasks name
logRelativeToRootTemplate = iCorrectSlash(regexprep(tasks(1).pGetEntityLocation, '[0-9]*$', ''));

% Ask the storage object how it would like to serialize itself and be
% reconstructed at the far end
[stringLocation, stringConstructor] = storage.getSubmissionStrings;
% Get the location of the storage
jobLocation = iCorrectSlash(job.pGetEntityLocation);

[~, mlcommand, mlargs] = local.pCalculateMatlabCommandForJob(job);
% Convert the args to a cell array of whitespace delimited strings
mlargs = strread(mlargs, '%s');
% Prepend the matlab command to create the array of strings for java to execute
commandArray = [{mlcommand} ; mlargs];

% Non-overridable variables
envNames = {...
    'MDCE_DECODE_FUNCTION' ...
    'MDCE_STORAGE_LOCATION' ...
    'MDCE_STORAGE_CONSTRUCTOR' ...
    'MDCE_JOB_LOCATION' ...
    'MDCE_TASK_LOCATION' ...
    'MDCE_PID_TO_WATCH' ...    
    'MDCE_USE_ML_LICENSING', ....
    };

envValues = {...
    'decodeLocalSingleTask' ...
    stringLocation ...
    stringConstructor ...
    jobLocation ...
    '' ...
    sprintf('%d',feature('getpid')) ...    
    'true' ...
    };

[envNames, envValues] = local.pCreateEnvironmentVariableArrays(envNames, envValues);

taskLocationIndex = strcmp(envNames, 'MDCE_TASK_LOCATION');

% Have we been asked to add any extra environment variables to the list
% of variables we are sending to the workers?

taskUUIDs = cell(numTasks, 1);
javaTasks = cell(numTasks, 1);
taskIDs = zeros(numTasks, 1);

for i = 1:numTasks
    logRelativeToRoot = sprintf('%s%d.log', logRelativeToRootTemplate, tasks(i).ID);
    logLocation = fullfile(logRoot, logRelativeToRoot);
    % Set the task location environment variable correctly
    taskLocation = iCorrectSlash(tasks(i).pGetEntityLocation);
    envValues{taskLocationIndex} = taskLocation;

    javaTask = com.mathworks.toolbox.distcomp.local.TaskCommand.getNewInstance(commandArray, envNames, envValues, logLocation);
    javaTasks{i} = javaTask;
    % Mechanism to track the UUID against the actual task
    taskUUIDs{i} = javaTask.getUUID;
    taskIDs(i) = tasks(i).ID;    
end

% Data returned from local -
% localTaskUUIDs : the local task ID for each task - NOTE for parallel jobs where
%                  there is only one actual task every real task will map to
%                  the same local task
% taskIDs        : the ID of the distcomp.abstracttask associated with a local
%                  task in the field above. It is an error for taskIDs and
%                  localTaskUUIDs to be of different lengths.
schedulerData = struct('type', 'local', ...
    'taskUUIDs', {taskUUIDs} , ...
    'taskIDs', {taskIDs}, ...
    'submitProcInfo', local.ProcessInformation, ...
    'logRelToStorage', {logRelativeToRootTemplate});
job.pSetJobSchedulerData(schedulerData);

% Now submit the actual java tasks
for i = 1:numTasks
    javaTasks{i}.submit;
end


function string = iCorrectSlash(string)
persistent goodSlash;
persistent badSlash;

if isempty(goodSlash)
    % Need to define what a good and bad slash looks like to ensure that we get everything correct
    if isunix
        badSlash  = '\';
        goodSlash = '/';
    else
        badSlash  = '/';
        goodSlash = '\';
    end
end
string = strrep(string, badSlash, goodSlash);