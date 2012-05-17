function schema
%SCHEMA defines the distcomp.abstractjob class
%

%   Copyright 2005 The MathWorks, Inc.

%   $Revision: 1.1.10.1 $  $Date: 2005/12/22 17:47:34 $


hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('abstractdataentity');
hThisClass   = schema.class(hThisPackage, 'abstractjob', hParentClass);

p = schema.prop(hThisClass, 'DefaultTaskConstructor', 'MATLAB array');
p.AccessFlags.AbortSet  = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = @distcomp.simpletask;

p = schema.prop(hThisClass, 'JobSchedulerData', 'MATLAB array');
p.AccessFlags.AbortSet  = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p.GetFunction = @pGetJobSchedulerData;
p.SetFunction = @pSetJobSchedulerData;

p = schema.prop(hThisClass, 'ProductKeys', 'MATLAB array');
p.AccessFlags.AbortSet  = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
% Set at initialisation time
p.GetFunction = @pGetProductKey;

p = schema.prop(hThisClass, 'UserName', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.AbortSet  = 'off';
% Set at initialisation time
p.GetFunction = @pGetUserName;

p = schema.prop(hThisClass, 'Tag', 'string');
p.AccessFlags.AbortSet  = 'off';
p.SetFunction = @pSetTag;
p.GetFunction = @pGetTag;

p = schema.prop(hThisClass, 'State', 'distcomp.jobexecutionstate');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.AbortSet  = 'off';
p.SetFunction = @pSetState;
p.GetFunction = @pGetState;

p = schema.prop(hThisClass, 'CreateTime', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.AbortSet  = 'off';
% Set at initialisation time
p.GetFunction = @pGetCreateTime;

p = schema.prop(hThisClass, 'SubmitTime', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.AbortSet  = 'off';
p.SetFunction = @pSetSubmitTime;
p.GetFunction = @pGetSubmitTime;

p = schema.prop(hThisClass, 'StartTime', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.AbortSet  = 'off';
p.SetFunction = @pSetStartTime;
p.GetFunction = @pGetStartTime;

p = schema.prop(hThisClass, 'FinishTime', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.AbortSet  = 'off';
p.SetFunction = @pSetFinishTime;
p.GetFunction = @pGetFinishTime;

p = schema.prop(hThisClass, 'Tasks', 'handle vector');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetTasks;

p = schema.prop(hThisClass, 'FileDependencies', 'string vector');
p.AccessFlags.AbortSet  = 'off';
p.SetFunction = @pSetFileDependencies;
p.GetFunction = @pGetFileDependencies;

p = schema.prop(hThisClass, 'PathDependencies', 'string vector');
p.AccessFlags.AbortSet  = 'off';
p.SetFunction = @pSetPathDependencies;
p.GetFunction = @pGetPathDependencies;

p = schema.prop(hThisClass, 'JobData', 'MATLAB array');
p.AccessFlags.AbortSet  = 'off';
p.SetFunction = @pSetJobData;
p.GetFunction = @pGetJobData;

p = schema.prop(hThisClass, 'Parent', 'handle');
p.AccessFlags.PublicSet = 'off';
p.GetFunction = @pGetParent;

p = schema.prop(hThisClass, 'UserData', 'MATLAB array');
