function runprop = lsfJobArrayDecodeFcn(runprop)
% lsfDecodeFcn

% Copyright 2006-2010 The MathWorks, Inc.

% Get the environment variables that were set in the submit function
% LSF will transfer these across
storageConstructor = getenv('STORAGE_CONSTRUCTOR');
storageLocation = getenv('STORAGE_LOCATION');
jobLocation = getenv('JOB_LOCATION');
% Get the index of this job in the LSF job array - this index will give
% use the correct environment variable that defines our particular 
% taskLocation.
TASK_ID = getenv('LSB_JOBINDEX')
taskLocation = getenv(sprintf('T%s', TASK_ID))

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