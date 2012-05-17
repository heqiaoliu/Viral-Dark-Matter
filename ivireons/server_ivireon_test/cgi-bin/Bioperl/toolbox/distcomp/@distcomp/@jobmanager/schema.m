function schema
%SCHEMA defines the distcomp.jobmanager class
%
% Copyright 2004-2010 The MathWorks, Inc.
% $Revision: 1.1.8.10 $  $Date: 2010/03/01 05:20:14 $

hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('abstractjobqueue');
hThisClass   = schema.class(hThisPackage, 'jobmanager', hParentClass);

p = schema.prop(hThisClass, 'Type', 'string');
p.AccessFlags.PublicSet = 'off';
p.FactoryValue = 'jobmanager';

p = schema.prop(hThisClass, 'ClusterOsType', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PrivateSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet = 'off';
p.GetFunction = @pGetClusterOsType;
p.Description = 'The name of the jobmanagers worker OS type';

p = schema.prop(hThisClass, 'Jobs', 'handle vector');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PrivateSet  = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = handle(-ones(0, 1));
p.GetFunction = @pGetJobs;

p = schema.prop(hThisClass, 'State', 'distcomp.jobmanagerexecutionstate');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetState;

schema.prop(hThisClass, 'UserData', 'MATLAB array');

p = schema.prop(hThisClass, 'ClusterSize', 'double');
p.AccessFlags.PublicSet  = 'off';
p.AccessFlags.PrivateSet  = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetClusterSize;

p = schema.prop(hThisClass, 'NumberOfBusyWorkers', 'double');
p.AccessFlags.PublicSet  = 'off';
p.AccessFlags.PrivateSet  = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetNumberOfBusyWorkers;
p.Description = 'The number of busy workers associated with this JobManager.';

p = schema.prop(hThisClass, 'BusyWorkers', 'handle vector');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetBusyWorkers;

p = schema.prop(hThisClass, 'NumberOfIdleWorkers', 'double');
p.AccessFlags.PublicSet  = 'off';
p.AccessFlags.PrivateSet  = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetNumberOfIdleWorkers;
p.Description = 'The number of idle workers associated with this JobManager.';

p = schema.prop(hThisClass, 'IdleWorkers', 'handle vector');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetIdleWorkers;

p = schema.prop(hThisClass, 'JobAccessProxy', 'com.mathworks.toolbox.distcomp.workunit.JobAccessProxy');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';

p = schema.prop(hThisClass, 'ParallelJobAccessProxy', 'com.mathworks.toolbox.distcomp.pml.ParallelJobAccessProxy');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';

p = schema.prop(hThisClass, 'TaskAccessProxy', 'com.mathworks.toolbox.distcomp.workunit.TaskAccessProxy');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';

p = schema.prop(hThisClass, 'CachedName', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';

p = schema.prop(hThisClass, 'LookupURL', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';

p = schema.prop(hThisClass, 'IsUsingSecureCommunication', 'bool');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pIsUsingSecureCommunication;

p = schema.prop(hThisClass, 'SecurityLevel', 'double');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetSecurityLevel;

p = schema.prop(hThisClass, 'UserName', 'string');
p.AccessFlags.PublicSet = 'on';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetUserName;
p.SetFunction = @pSetUserName;

p = schema.prop(hThisClass, 'PromptForPassword', 'bool');
p.AccessFlags.PublicSet = 'on';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetInteractiveAuthentication;
p.SetFunction = @pSetInteractiveAuthentication;
