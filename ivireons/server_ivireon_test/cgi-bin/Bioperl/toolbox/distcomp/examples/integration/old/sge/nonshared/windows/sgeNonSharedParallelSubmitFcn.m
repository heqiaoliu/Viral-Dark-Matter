function sgeNonSharedParallelSubmitFcn(scheduler, job, props, ...
                                        clusterHost, remoteDataLocation)
%SGENONSHAREDPARALLELSUBMITFCN Submits a parallel MATLAB job to a SGE 
% scheduler in the absence of a shared file system between the MATLAB 
% client and the SGE scheduler.
%
% See also sgeNonSharedParallelDecodeFcn.

% Copyright 2006-2009 The MathWorks, Inc.

if ~ischar(clusterHost)
    error('distcomp:genericsceduler:SubmitFcnError', ...
        'Hostname must be a string');
end
if ~ischar(remoteDataLocation)
    error('distcomp:genericsceduler:SubmitFcnError', ...
        'Remote Data Location must be a string');
end

remoteDataLocation = [ remoteDataLocation '/' getenv('USERNAME') '/' ];
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
decodeFcn = 'sgeNonSharedParallelDecodeFcn';

% A unique file and directory name for the job. This is used to create
% files and a directory under scheduler.DataLocation
jobLocation = props.JobLocation;

% Since SGE jobs will be submitted from a UNIX host on the cluster, 
% a single quoted string will protect the MATLAB command.
quote = '''';

% Copy the matlab_metadata.mat file to the remote host.
localMetaDataFile = [ localDataLocation '/matlab_metadata.mat' ];
copyDataToCluster(localMetaDataFile, remoteDataLocation, clusterHost);

% Copy the local job directory to the remote host.
localJobDirectory = [ localDataLocation '/' jobLocation ];
copyDataToCluster(localJobDirectory, remoteDataLocation, clusterHost);

% Copy the local job files to the remote host.
localJobFiles = [ localDataLocation '/' jobLocation '.*' ];
copyDataToCluster(localJobFiles, remoteDataLocation, clusterHost);


% Directory on remote host where the submit script as well as the 
% parallel wrapper script will be written.
remoteJobDir = [ remoteDataLocation '/' jobLocation ];

% The name of the script that will run the parallel job.
parallelWrapperScriptName = 'sgeParallelWrapper.sh';
% The wrapper script is in the same directory as this file
[dirpart] = fileparts( mfilename( 'fullpath' ) );
parallelWrapperScript = fullfile( dirpart, parallelWrapperScriptName );

% Forward the total number of tasks we're expecting to launch
setenv( 'MDCE_TOTAL_TASKS', num2str( props.NumberOfTasks ) );

% The command that will be executed to run the paralle job.
commandToRun = [ remoteJobDir '/' parallelWrapperScriptName ];



% Choose a number of processors per node to use (you will need to customize
% this section to match your cluster)
procsPerNode = 1;
numberOfNodes = ceil( props.NumberOfTasks / procsPerNode );
             
% Create a script that will set environment variables and then submit 
% a parallel job to SGE.
localScript = createSGESubmitScript(commandToRun, decodeFcn, ...
    props.StorageConstructor, remoteDataLocation, jobLocation, ...
    scheduler.ClusterMatlabRoot, props.MatlabExecutable, ...
    props.MatlabArguments, props.NumberOfTasks, ...
    procsPerNode, numberOfNodes, quote, job);

[path, scriptName] = fileparts(localScript);

% Copy the submit script to the remote host.
copyDataToCluster(localScript, remoteJobDir, clusterHost);

% Copy the paraller wrapper script to the remote host.
% The wrapper script is in the same directory as this file.
copyDataToCluster(parallelWrapperScript, remoteJobDir, clusterHost);

% Create the command to run on the remote host.
remoteScriptLocation = [ remoteJobDir '/' scriptName ];
remoteCommand = sprintf('sh %s', remoteScriptLocation);

% Execute the submit command on the remote host.
runCmdOnCluster(remoteCommand, clusterHost);

% Delete the local copy of the script
delete(localScript);


function filename = createSGESubmitScript(commandToRun, decodeFunction, ...
        storageConstructor, remoteDataLocation, jobLocation, ...
        clusterMatlabRoot, matlabExecutable, matlabArguments, ...
        numberOfTasks, procsPerNode, numberOfNodes, quote, job)
% Create a SGE submit script that forwards the required environment
% variables and runs MATLAB workers.

% Remove leading whitespace from the MATLAB arguments.
[t, r] = strtok(matlabArguments);
matlabArguments = [t r];

% Provide the name of a unique log file for this job. Use quotes
% in case there is a space in scheduler.DataLocation.
logFileLocation = [ remoteDataLocation '/' jobLocation '/' ...
                   jobLocation '.log' ];

% Choose a number of processors per node to use (you will need to customise
% this section to match your cluster).
nodesArg = sprintf( '-pe matlab %d', numberOfNodes );

% Create the commands to set the environment variables.
% "-N Job#"  specifies the job name
% "-j oe" joins together output and error streams
% "-o ..." specifies where standard output goes to
% "-l nodes ... " specifies the number of nodes and processes per nodes
setEnv = sprintf([ ...
    'MDCE_DECODE_FUNCTION=', decodeFunction, '\n', ...
    'MDCE_STORAGE_CONSTRUCTOR=', storageConstructor, '\n', ...
    'MDCE_STORAGE_LOCATION=', remoteDataLocation, '\n', ...
    'MDCE_JOB_LOCATION=', jobLocation, '\n', ...
    'MDCE_DEBUG=', 'true', '\n', ...
    'MDCE_MATLAB_EXE=', matlabExecutable, '\n', ...
    'MDCE_MATLAB_ARGS=', matlabArguments, '\n', ...
    'MDCE_CMR=', clusterMatlabRoot, '\n', ...
    'MDCE_TOTAL_TASKS=', num2str(numberOfTasks),'\n', ...
    'export MDCE_DECODE_FUNCTION\n', ...
    'export MDCE_STORAGE_CONSTRUCTOR\n', ...
    'export MDCE_STORAGE_LOCATION\n', ...
    'export MDCE_JOB_LOCATION\n', ...
    'export MDCE_DEBUG\n', ...
    'export MDCE_MATLAB_EXE\n', ...
    'export MDCE_MATLAB_ARGS\n', ...
    'export MDCE_CMR\n', ...
    'export MDCE_TOTAL_TASKS\n', ...
    ]);

cmdLine = sprintf( 'qsub -N Job%d -j yes -o "%s" %s "%s"', ...
                   job.ID, logFileLocation, nodesArg, commandToRun );

% Content of script.
scriptContent = sprintf('%s%s', setEnv, cmdLine);

% Create script.
filename = tempname;
% Open file in binary mode to make it cross-platform.
fid = fopen(filename, 'w');
fprintf(fid, scriptContent);
fclose(fid);
