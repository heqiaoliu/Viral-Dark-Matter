function distributedSubmitFcn(scheduler, job, props)
%DISTRIBUTEDSUBMITFCN Submit a MATLAB job to a PBS scheduler
%
% Set your scheduler's SubmitFcn to this function using the following
% command:
%     set(sched, 'SubmitFcn', @distributedSubmitFcn);
%
% See also parallel.cluster.generic.distributedDecodeFcn.
%

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2010/05/10 17:13:09 $

decodeFunction = 'parallel.cluster.generic.distributedDecodeFcn';
% Store the current filename for the dctSchedulerMessages
currFilename = mfilename;
if ~scheduler.HasSharedFilesystem
    error('distcompexamples:PBS:SubmitFcnError', ...
        'The submit function %s is for use with shared filesystems.', currFilename)
end
if ~strcmpi(scheduler.ClusterOsType, 'unix')
    error('distcompexamples:PBS:SubmitFcnError', ...
        'The submit function %s only supports clusters with unix OS.', currFilename)
end

% The job specific environment variables
% Remove leading and trailing whitespace from the MATLAB arguments
matlabArguments = strtrim(props.MatlabArguments);
variables = {'MDCE_DECODE_FUNCTION', decodeFunction; ...
    'MDCE_STORAGE_CONSTRUCTOR', props.StorageConstructor; ...
    'MDCE_JOB_LOCATION', props.JobLocation; ...
    'MDCE_MATLAB_EXE', props.MatlabExecutable; ... 
    'MDCE_MATLAB_ARGS', matlabArguments; ...
    'MDCE_DEBUG', 'true'; ...
    'MDCE_STORAGE_LOCATION', props.StorageLocation};
% Set the required environment variables
for ii = 1:size(variables, 1)
    setenv(variables{ii,1}, variables{ii,2});
end
% Which variables do we need to forward for the job?  Take all
% those that we have set and add the task location which will be 
% set for each task.
variablesToForward = [variables(:,1); {'MDCE_TASK_LOCATION'}];

% Deduce the correct quote to use based on the OS of the current machine
if ispc
    quote = '"';
else 
    quote = '''';
end

% The local job directory
localJobDirectory = fullfile(scheduler.DataLocation, props.JobLocation);


% The script name is distributedJobWrapper.sh
scriptName = 'distributedJobWrapper.sh';
% The wrapper script is in the same directory as this file
dirpart = fileparts(mfilename('fullpath'));
quotedScriptName = sprintf('%s%s%s', quote, fullfile(dirpart, scriptName), quote);

% Get the tasks for use in the loop
tasks = job.Tasks;
numberOfTasks = props.NumberOfTasks;
jobIDs = cell(numberOfTasks, 1);

% Loop over every task we have been asked to submit
for ii = 1:numberOfTasks
    taskLocation = props.TaskLocations{ii};
    % Set the environment variable that defines the location of this task
    setenv('MDCE_TASK_LOCATION', taskLocation);
    
    % Choose a file for the output. Please note that currently, DataLocation refers
    % to a directory on disk, but this may change in the future.
    logFile = fullfile(localJobDirectory, sprintf('Task%d.log', tasks(ii).ID));
    quotedLogFile = sprintf('%s%s%s', quote, logFile, quote);
    
    % Submit one task at a time
    jobName = sprintf('Job%d.%d', job.ID, tasks(ii).ID);
    % PBS jobs names must not exceed 15 characters
    maxJobNameLength = 15;
    if length(jobName) > maxJobNameLength
        jobName = jobName(1:maxJobNameLength);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% CUSTOMIZATION MAY BE REQUIRED %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % You may also with to supply additional submission arguments to 
    % the qsub command here.
    additionalSubmitArgs = '';
    dctSchedulerMessage(5, '%s: Generating command for task %i', currFilename, ii);
    commandToRun = getSubmitString(jobName, quotedLogFile, quotedScriptName, ...
        variablesToForward, additionalSubmitArgs);   
    
    
    % Now ask the cluster to run the submission command
    dctSchedulerMessage(4, '%s: Submitting job using command:\n\t%s', currFilename, commandToRun);
    try
        % Make the shelled out call to run the command.
        [cmdFailed, cmdOut] = system(commandToRun);
    catch err
        cmdFailed = true;
        cmdOut = err.message;
    end
    if cmdFailed
        error('distcompexamples:PBS:SubmissionFailed', ...
            'Submit failed with the following message:\n%s', cmdOut);
    end
    
    dctSchedulerMessage(1, '%s: Job output will be written to: %s\nSubmission output: %s\n', currFilename, logFile, cmdOut);
    jobIDs{ii} = extractJobId(cmdOut);
    
    if isempty(jobIDs{ii})
        warning('distcompexamples:PBS:FailedToParseSubmissionOutput', ...
            'Failed to parse the job identifier from the submission output: "%s"', ...
            cmdOut);
    end
end

% set the job ID on the job scheduler data
scheduler.setJobSchedulerData(job, struct('SchedulerJobIDs', {jobIDs}));

