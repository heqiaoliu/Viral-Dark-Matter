function sgeNonSharedSimpleSubmitFcn(scheduler, job, props, ...
                                        clusterHost, remoteDataLocation)
%SGENONSHAREDSIMPLESUBMITFCN Submits a MATLAB job to a SGE scheduler in the
% absence of a shared file system between the MATLAB client and the
% SGE scheduler.
%
% See also sgeNonSharedSimpleDecodeFcn.

% Copyright 2006-2009 The MathWorks, Inc.

if ~ischar(clusterHost)
    error('distcomp:genericsceduler:SubmitFcnError', ...
        'Hostname must be a string');
end
if ~ischar(remoteDataLocation)
    error('distcomp:genericsceduler:SubmitFcnError', ...
        'Remote Data Location must be a string');
end

remoteDataLocation = [ remoteDataLocation '/' getenv('USER') '/' ];
% Make sure that the remote data location exists.
runCmdOnCluster([ 'mkdir -p ' remoteDataLocation ], clusterHost);

scheduler.UserData = { clusterHost ; remoteDataLocation };
localDataLocation = scheduler.DataLocation;

% Set the name of the decode function which will be executed by
% the worker. The decode function must be on the path of the MATLAB
% worker when it starts up. This is typically done by placing the decode
% function in MATLABROOT/toolbox/local on the cluster nodes, or by
% prefixing commandToRun (created below) with a command to cd to the
% directory where the decode function's file exists.
decodeFcn = 'sgeNonSharedSimpleDecodeFcn';

% Read the number of tasks which are to be created. This property
% cannot be changed.
numberOfTasks = props.NumberOfTasks;

% A unique file and directory name for the job. This is used to create
% files and a directory under scheduler.DataLocation
jobLocation = props.JobLocation;

% A cell array of unique file names for tasks. These are used to create
% files under jobLocation
taskLocations = props.TaskLocations;

% Since SGE jobs will be submitted from a UNIX host on the cluster, 
% a single quoted string will protect the MATLAB command.
quote = '''';

% The name of the script that will run the job.
wrapperScriptName = 'sgeWrapper.sh';
% The wrapper script is in the same directory as this file
[dirpart] = fileparts( mfilename( 'fullpath' ) );
wrapperScript = fullfile( dirpart, wrapperScriptName );

% Copy the matlab_metadata.mat file to the remote host.
localMetaDataFile = [ localDataLocation '/matlab_metadata.mat' ];
copyDataToCluster(localMetaDataFile, remoteDataLocation, clusterHost);

% Copy the local job directory to the remote host.
localJobDirectory = [ localDataLocation '/' jobLocation ];
copyDataToCluster(localJobDirectory, remoteDataLocation, clusterHost);

% Copy the local job files to the remote host.
localJobFiles = [ localDataLocation '/' jobLocation '.*' ];
copyDataToCluster(localJobFiles, remoteDataLocation, clusterHost);


% Submit tasks which the scheduler will execute by starting MATLAB workers.
for i = 1:numberOfTasks
    taskLocation = taskLocations{i};
    remoteJobDir = [ remoteDataLocation '/' jobLocation ];

    % The command that will be executed to run the job.
    commandToRun = [ remoteJobDir '/' wrapperScriptName ];
    
    % Create a script to submit an SGE job.
    localScript = createSGESubmitScript(commandToRun, decodeFcn, ...
                        props.StorageConstructor, remoteDataLocation, ...
                        jobLocation, taskLocation, props.MatlabExecutable, ...
                        props.MatlabArguments, quote, job, i);
    [path, scriptName] = fileparts(localScript);

    % Copy the script to the remote host.
    copyDataToCluster(localScript, remoteJobDir, clusterHost);
    
    % Copy the wrapper script to the remote host.
    % The wrapper script is in the same directory as this file.
    copyDataToCluster(wrapperScript, remoteJobDir, clusterHost);
    
    % Create the command to run on the remote host.
    remoteScriptLocation = [ remoteJobDir '/' scriptName ];
    remoteCommand = sprintf('sh %s', remoteScriptLocation);
    
    % Execute the submit command on the remote host.
    runCmdOnCluster(remoteCommand, clusterHost);
    
    % Delete the local copy of the script
    delete(localScript);
end


function filename = createSGESubmitScript(commandToRun, decodeFunction, ...
        storageConstructor, remoteDataLocation, jobLocation, ...
        taskLocation, matlabExe, matlabArgs, quote, job, taskIndex)
% Create a script that sets the correct environment variables and then 
% executes the SGE qsub command.

% Provide the name of a unique log file for this task. Use quotes
% in case there is a space in scheduler.DataLocation. If SGE fails
% to write to the log file, an e-mail will be sent to the user.
logFileLocation = [ remoteDataLocation '/' taskLocation '.log' ];

% Specify Shell to use
shellString = sprintf('#!/bin/sh\n');

% Create the command to set the environment variables.
setEnv = sprintf([ ...
    'MDCE_DECODE_FUNCTION=', decodeFunction, '\n', ...
    'MDCE_STORAGE_CONSTRUCTOR=', storageConstructor, '\n', ...
    'MDCE_STORAGE_LOCATION=', remoteDataLocation, '\n', ...
    'MDCE_JOB_LOCATION=', jobLocation, '\n', ...
    'MDCE_TASK_LOCATION=', taskLocation, '\n', ...
    'MDCE_DEBUG=', 'true', '\n', ...
    'MDCE_MATLAB_EXE=', matlabExe, '\n', ...
    'MDCE_MATLAB_ARGS=', matlabArgs, '\n', ...
    'export MDCE_DECODE_FUNCTION\n', ...
    'export MDCE_STORAGE_CONSTRUCTOR\n', ...
    'export MDCE_STORAGE_LOCATION\n', ...
    'export MDCE_JOB_LOCATION\n', ...
    'export MDCE_TASK_LOCATION\n', ...
    'export MDCE_DEBUG\n', ...
    'export MDCE_MATLAB_EXE\n', ...
    'export MDCE_MATLAB_ARGS\n', ...
    ]);

% Create the command for task submission.
submitString = sprintf(...
    'qsub -N Job%d.%d -j yes -o "%s" "%s"\n' , ...
    job.ID, ...
    job.Tasks(taskIndex).ID, ...
    logFileLocation, ...
    commandToRun);

% Content of script.
scriptContent = sprintf('%s%s%s', shellString, setEnv, submitString);

% Create script.
filename = tempname;
% Open file in binary mode to make it cross-platform.
fid = fopen(filename, 'w');
fprintf(fid, scriptContent);
fclose(fid);
