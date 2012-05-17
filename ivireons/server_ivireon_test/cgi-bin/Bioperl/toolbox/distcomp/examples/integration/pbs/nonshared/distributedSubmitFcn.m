function distributedSubmitFcn(scheduler, job, props, ...
    clusterHost, remoteDataLocation)
%DISTRIBUTEDSUBMITFCN Submit a MATLAB job to a PBS scheduler
%
% Set your scheduler's SubmitFcn to this function using the following
% command:
%     set(sched, 'SubmitFcn', {@distributedSubmitFcn, clusterHost, remoteDataLocation});
%
% See also parallel.cluster.generic.distributedDecodeFcn.
%

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2010/05/10 17:13:09 $

decodeFunction = 'parallel.cluster.generic.distributedDecodeFcn';
% Store the current filename for the dctSchedulerMessages
currFilename = mfilename;
if scheduler.HasSharedFilesystem
    error('distcompexamples:PBS:SubmitFcnError', ...
        'The submit function %s is for use with nonshared filesystems.', currFilename)
end
if ~strcmpi(scheduler.ClusterOsType, 'unix')
    error('distcompexamples:PBS:SubmitFcnError', ...
        'The submit function %s only supports clusters with unix OS.', currFilename)
end
if ~ischar(clusterHost)
    error('distcompexamples:PBS:IncorrectArguments', ...
        'Hostname must be a string');
end
if ~ischar(remoteDataLocation)
    error('distcompexamples:PBS:IncorrectArguments', ...
        'Remote data location must be a string');
end

remoteConnection = getRemoteConnection(scheduler, clusterHost, remoteDataLocation);

% The job specific environment variables
% Remove leading and trailing whitespace from the MATLAB arguments
matlabArguments = strtrim(props.MatlabArguments);
variables = {'MDCE_DECODE_FUNCTION', decodeFunction; ...
    'MDCE_STORAGE_CONSTRUCTOR', props.StorageConstructor; ...
    'MDCE_JOB_LOCATION', props.JobLocation; ...
    'MDCE_MATLAB_EXE', props.MatlabExecutable; ... 
    'MDCE_MATLAB_ARGS', matlabArguments; ...
    'MDCE_DEBUG', 'true'; ...
    'MDCE_STORAGE_LOCATION', remoteDataLocation};



% Get the correct quote and file separator for the Cluster OS.  
% This check is unnecessary in this file because we explicitly 
% checked that the ClusterOsType is unix.  This code is an example 
% of how your integration code should deal with clusters that 
% can be unix or pc.
if strcmpi(scheduler.ClusterOsType, 'unix')
    quote = '''';
    fileSeparator = '/';
else 
    quote = '"';
    fileSeparator = '\';
end

% The local job directory
localJobDirectory = fullfile(scheduler.DataLocation, props.JobLocation);
% How we refer to the job directory on the cluster
remoteJobDirectory = remoteConnection.getRemoteJobLocation(job.ID, scheduler.ClusterOsType);

% The script name is distributedJobWrapper.sh
scriptName = 'distributedJobWrapper.sh';
% The wrapper script is in the same directory as this file
dirpart = fileparts(mfilename('fullpath'));
localScript = fullfile(dirpart, scriptName);
% Copy the local wrapper script to the job directory
copyfile(localScript, localJobDirectory);

% The command that will be executed on the remote host to run the job.
remoteScriptName = sprintf('%s%s%s', remoteJobDirectory, fileSeparator, scriptName);
quotedScriptName = sprintf('%s%s%s', quote, remoteScriptName, quote);

% Get the tasks for use in the loop
tasks = job.Tasks;
numberOfTasks = props.NumberOfTasks;
jobIDs = cell(numberOfTasks, 1);
commandsToRun = cell(numberOfTasks, 1);
% Loop over every task we have been asked to submit
for ii = 1:numberOfTasks
    taskLocation = props.TaskLocations{ii};
    % Add the task location to the environment variables
    environmentVariables = [variables; ...
        {'MDCE_TASK_LOCATION', taskLocation}];
    
    % Choose a file for the output. Please note that currently, DataLocation refers
    % to a directory on disk, but this may change in the future.
    logFile = sprintf('%s%s%s', remoteJobDirectory, fileSeparator, sprintf('Task%d.log', tasks(ii).ID));
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
    % Create a script to submit a PBS job - this will be created in the job directory
    dctSchedulerMessage(5, '%s: Generating script for task %i', currFilename, ii);
    localScriptName = tempname(localJobDirectory);
    [~, scriptName] = fileparts(localScriptName);
    remoteScriptLocation = sprintf('%s%s%s', remoteJobDirectory, fileSeparator, scriptName);
    createSubmitScript(localScriptName, jobName, quotedLogFile, quotedScriptName, ...
        environmentVariables, additionalSubmitArgs);
    % Create the command to run on the remote host.
    commandsToRun{ii} = sprintf('sh %s', remoteScriptLocation);
end
dctSchedulerMessage(4, '%s: Starting mirror for job %d.', currFilename, job.ID);
% Start the mirror to copy all the job files over to the cluster
remoteConnection.startMirrorForJob(job);
for ii = 1:numberOfTasks
    commandToRun = commandsToRun{ii};
    
    % Now ask the cluster to run the submission command
    dctSchedulerMessage(4, '%s: Submitting job using command:\n\t%s', currFilename, commandToRun);
    % Execute the command on the remote host.
    [cmdFailed, cmdOut] = remoteConnection.runCommand(commandToRun);
    if cmdFailed
        % Stop the mirroring if we failed to submit the job - this will also
        % remove the job files from the remote location
        % Only stop mirroring if we are actually mirroring
        if remoteConnection.isJobUsingConnection(job.ID)
            dctSchedulerMessage(5, '%s: Stopping the mirror for job %d.', currFilename, job.ID);
            try
                remoteConnection.stopMirrorForJob(job);
            catch err
                warning('distcompexamples:PBS:FailedToStopMirrorForJob', ...
                    'Failed to stop the file mirroring for job %d.\nReason: %s', ...
                    job.ID, err.getReport);
            end
        end
        error('distcompexamples:PBS:FailedToSubmitJob', ...
            'Failed to submit job to PBS using command:\n\t%s.\nReason: %s', ...
            commandToRun, cmdOut);
    end
    jobIDs{ii} = extractJobId(cmdOut);
    
    if isempty(jobIDs{ii})
        warning('distcompexamples:PBS:FailedToParseSubmissionOutput', ...
            'Failed to parse the job identifier from the submission output: "%s"', ...
            cmdOut);
    end
end

% set the cluster host, remote data location and job ID on the job scheduler data
jobData = struct('SchedulerJobIDs', {jobIDs}, ...
    'RemoteHost', clusterHost, ...
    'RemoteDataLocation', remoteDataLocation, ...
    'HasDoneLastMirror', false);
scheduler.setJobSchedulerData(job, jobData);

