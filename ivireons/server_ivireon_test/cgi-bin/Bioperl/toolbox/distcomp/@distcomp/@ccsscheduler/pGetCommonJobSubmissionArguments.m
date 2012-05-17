function jobSubmissionArguments = pGetCommonJobSubmissionArguments(~, job)
; %#ok Undocumented
% Get job related arguments that are common to distcomp.MicrosoftSchedulerConnection.SubmitJob
% and SubmitParallelJob

%  Copyright 2009 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $  $Date: 2009/04/15 22:57:51 $

storage = job.pReturnStorage;
% Ask the storage object how it would like to serialize itself and be
% reconstructed at the far end
[stringLocation, stringConstructor] = storage.getSubmissionStrings;

% Get the location of the storage
jobLocation = job.pGetEntityLocation;

% Job specific environment variables
jobEnvironmentVariables = { ...
    'MDCE_STORAGE_LOCATION',    stringLocation; ...
    'MDCE_STORAGE_CONSTRUCTOR', stringConstructor; ...
    'MDCE_JOB_LOCATION',        jobLocation};

% Define the location for logs to be returned
if isa(storage, 'distcomp.filestorage')
    logRoot = storage.StorageLocation;
    
    if ~isempty(logRoot)
        fullJobLocation = fullfile(logRoot, jobLocation);
    else
        fullJobLocation = jobLocation;
    end
    
    if isa(job, 'distcomp.simpleparalleljob')
        % There is a single log file for parallel jobs
        logTaskIDToken = '';
        logRelativeToRoot = iUnix2PC([fullfile(jobLocation,  sprintf('Job%d', job.ID )) '.mpiexec.out']);
    else
        % There is a log file for each task of a distributed job, so the logRelativeToRoot
        % will have a token that needs to be replaced with the actual task ID.
        % Define the logLocationTemplate to use - remove the ID from the end of
        % the first task's name and replace it with the token ^taskID^
        % The log file will be in JobXX\Task^taskID^.log
        logTaskIDToken = '^taskID^';
        logTemplate = sprintf('%s%s.log', regexprep(job.Tasks(1).pGetEntityLocation, '[0-9]*$', ''), logTaskIDToken);
        logRelativeToRoot = iUnix2PC(logTemplate);
    end
    fullLogLocation = fullfile(logRoot, logRelativeToRoot);
end

% Get the user details
net = actxserver('WScript.Network');
username = sprintf('%s\\%s', net.UserDomain, net.UserName);

% If we specify an empty password, the user should get prompted for a password
% by Windows
password = '';

jobSubmissionArguments = struct( ...
    'fullJobLocation', fullJobLocation, ...
    'fullLogLocation', fullLogLocation, ...
    'logRelativeToRoot', logRelativeToRoot, ...
    'logTaskIDToken', logTaskIDToken, ...
    'username', username, ...
    'password', password);

% Set the jobEnvironmentVariables field separately from the call to struct
% otherwise we'll end up with a 3x2 struct.
jobSubmissionArguments.jobEnvironmentVariables = jobEnvironmentVariables;

function filename = iUnix2PC(filename)
filename = strrep(filename, '/', '\');

