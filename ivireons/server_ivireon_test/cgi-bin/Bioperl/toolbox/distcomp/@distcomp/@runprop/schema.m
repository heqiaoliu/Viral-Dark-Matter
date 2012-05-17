function schema
%SCHEMA defines the distcomp.runnerdefaults class
%

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.10.5 $  $Date: 2008/11/04 21:16:08 $


hThisPackage = findpackage('distcomp');
hThisClass   = schema.class(hThisPackage, 'runprop');
% Make this a pass-by-value object
%set(hThisClass, 'Handle', 'off')

% Define the fields that are needed to run a task - most of these fields
% need to be setup before we can instanciate a real task runner
schema.prop(hThisClass, 'StorageConstructor', 'string');

schema.prop(hThisClass, 'StorageLocation', 'string');

schema.prop(hThisClass, 'JobLocation', 'string');

schema.prop(hThisClass, 'TaskLocation', 'string');

schema.prop(hThisClass, 'DependencyDirectory', 'string');

schema.prop(hThisClass, 'HasSharedFilesystem', 'bool');

schema.prop(hThisClass, 'AppendPathDependencies', 'bool');

schema.prop(hThisClass, 'AppendFileDependencies', 'bool');

schema.prop(hThisClass, 'IsFirstTask', 'bool');

schema.prop(hThisClass, 'LocalSchedulerName', 'string');

schema.prop(hThisClass, 'DecodeArguments', 'MATLAB array');

schema.prop(hThisClass, 'ExitOnTaskFinish', 'bool');

schema.prop(hThisClass, 'CleanUpDependencyDirOnTaskFinish', 'bool');
