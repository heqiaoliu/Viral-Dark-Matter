function schema
%SCHEMA defines the distcomp.worker class
%

% Copyright 2004-2008 The MathWorks, Inc.

hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('abstractjobqueue');
hThisClass   = schema.class(hThisPackage, 'worker', hParentClass);

p = schema.prop(hThisClass, 'State', 'distcomp.workerexecutionstate');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetState;

p = schema.prop(hThisClass, 'JobManager', 'handle');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetJobManager;

p = schema.prop(hThisClass, 'Computer', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetComputer;

p = schema.prop(hThisClass, 'CurrentJob', 'handle');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetCurrentJob;

p = schema.prop(hThisClass, 'CurrentTask', 'handle');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetCurrentTask;

p = schema.prop(hThisClass, 'PreviousJob', 'handle');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetLastJob;

p = schema.prop(hThisClass, 'PreviousTask', 'handle');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetLastTask;
