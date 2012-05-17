function runprop = lsfSimpleDecodeFcn(runprop)
% lsfDecodeFcn

% Copyright 2006-2010 The MathWorks, Inc.

% Get the environment variables that were set in the submit function
% LSF will transfer these across
storageConstructor = getenv('STORAGE_CONSTRUCTOR');
storageLocation = getenv('STORAGE_LOCATION');
jobLocation = getenv('JOB_LOCATION');
taskLocation = getenv('TASK_LOCATION')

% Use the taskLocation appended to the current tempdir for the dependency
% directory
dependencyDir = [tempdir taskLocation];

%
% Set runprop properties from the local variables:
set(runprop, ...
        'StorageConstructor', storageConstructor, ...
        'StorageLocation', storageLocation, ...
        'JobLocation', jobLocation, ....
        'TaskLocation', taskLocation, ...
        'DependencyDirectory', dependencyDir);