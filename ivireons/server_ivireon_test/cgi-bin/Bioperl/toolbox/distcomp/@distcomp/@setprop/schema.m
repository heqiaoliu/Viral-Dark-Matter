function schema
%SCHEMA defines the distcomp.setprop class
%

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.10.4 $  $Date: 2008/03/31 17:07:53 $


hThisPackage = findpackage('distcomp');
hThisClass   = schema.class(hThisPackage, 'setprop');

% Define the fields that are needed to run a task - most of these fields
% need to be setup before we can instanciate a real task runner
p = schema.prop(hThisClass, 'StorageConstructor', 'string');
p.AccessFlags.PublicSet = 'off';

p = schema.prop(hThisClass, 'StorageLocation', 'string');
p.AccessFlags.PublicSet = 'off';

p = schema.prop(hThisClass, 'JobLocation', 'string');
p.AccessFlags.PublicSet = 'off';

p = schema.prop(hThisClass, 'TaskLocations', 'string vector');
p.AccessFlags.PublicSet = 'off';

p = schema.prop(hThisClass, 'NumberOfTasks', 'double');
p.AccessFlags.PublicSet = 'off';
p.GetFunction = @iGetNumberOfTasks;

% These two fields will hold the executable string and the arguments
% for the executable. They are separated this way to allow for easier
% quoteing when being passed to third party objects.
p = schema.prop(hThisClass, 'MatlabExecutable', 'string');
p.AccessFlags.PublicSet = 'off';

p = schema.prop(hThisClass, 'MatlabArguments', 'string');
p.AccessFlags.PublicSet = 'off';

function val = iGetNumberOfTasks(obj, val) %#ok
val = numel(obj.TaskLocations);
