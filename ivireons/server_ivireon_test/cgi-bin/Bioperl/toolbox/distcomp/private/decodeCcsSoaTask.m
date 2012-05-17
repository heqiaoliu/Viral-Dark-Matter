function runprop = decodeCcsSoaTask(runprop)

% Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2010/03/22 03:42:43 $

dctSchedulerMessage(2, 'In decodeCcsSoaTask');

% We only expect a single nargin in runprop.Varargin.  This is the serialized 
% arguments received over the IPC channel
serializedArgs = runprop.DecodeArguments{1};
% get the taskLocation from the serialized arguments
[taskLocation, performJobInit, dependencyDir] = iDeserializeArgs(serializedArgs);

% Get the other runprop fields from the environment variables.
storageConstructor = getenv('MDCE_STORAGE_CONSTRUCTOR');
storageLocation = getenv('MDCE_STORAGE_LOCATION');
jobLocation = getenv('MDCE_JOB_LOCATION');

% Never remove the dependency dir.  This will be done in C# code
set(runprop, ...
    'StorageConstructor', storageConstructor, ...
    'StorageLocation', storageLocation, ...
    'JobLocation', jobLocation, ....
    'TaskLocation', taskLocation, ...
    'LocalSchedulerName', 'hpcserver', ...    
    'DependencyDirectory', dependencyDir, ...
    'ExitOnTaskFinish', false, ...
    'AppendPathDependencies', performJobInit, ...
    'AppendFileDependencies', performJobInit, ...
    'IsFirstTask', performJobInit, ...
    'CleanUpDependencyDirOnTaskFinish', false);

    

function [taskLocation, performJobInit, dependencyDir] = iDeserializeArgs(serializedArgs)
dctSchedulerMessage(2, 'About to deserialize args')
% The serializedArgs will consist of multiple strings delimited by a newline character.
argsStr = char(serializedArgs);
% We expect only 3 args: <tasklocation>\n<isFirstTask>\n<dependencyDir>
args = strread(argsStr, '%s', 'delimiter', '\n');
if length(args) ~= 3
    error('distcomp:ccsscheduler:BadSerializedArgs', ...
        'Incorrect number of arguments in serialized string. Expected 3, got %d', length(args));
end

[taskLocationStr, performJobInitStr, dependencyDirStr] = args{:};

% get rid of any leading/trailing whitespace from the raw strings
taskLocation = strtrim(taskLocationStr);
dependencyDir = strtrim(dependencyDirStr);
performJobInitStr = strtrim(performJobInitStr);

try
    % Convert the performJobInit value from string to number and then to logical
    performJobInit = logical(str2double(performJobInitStr));
catch err
    newErr = MException('distcomp:ccsscheduler:BadSerializedArgs', ...
        'Unable to convert performJobInitStr to logical');
    newErr = newErr.addCause(err);
    throw(newErr);
end
