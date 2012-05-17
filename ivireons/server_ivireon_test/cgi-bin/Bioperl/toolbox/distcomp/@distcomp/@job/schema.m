function schema
%SCHEMA defines the distcomp.job class
%

% Copyright 2004-2009 The MathWorks, Inc.

hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('proxyobject');
hThisClass   = schema.class(hThisPackage, 'job', hParentClass);

p = schema.prop(hThisClass, 'Name', 'string');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetName;
p.SetFunction = @pSetName;

p = schema.prop(hThisClass, 'ID', 'int32');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetID;

p = schema.prop(hThisClass, 'UserName', 'string');
p.AccessFlags.PublicSet = 'on';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetUserName;
p.SetFunction = @pSetUserName;

p = schema.prop(hThisClass, 'AuthorizedUsers', 'MATLAB array');
p.AccessFlags.PublicSet = 'on';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetAuthorizedUsers;
p.SetFunction = @pSetAuthorizedUsers;

p = schema.prop(hThisClass, 'Tag', 'string');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetTag;
p.SetFunction = @pSetTag;

p = schema.prop(hThisClass, 'State', 'distcomp.jobexecutionstate');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetState;

p = schema.prop(hThisClass, 'RestartWorker', 'bool');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetRestartWorker;
p.SetFunction = @pSetRestartWorker;

p = schema.prop(hThisClass, 'Timeout', 'double');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetTimeout;
p.SetFunction = @pSetTimeout;

p = schema.prop(hThisClass, 'MaximumNumberOfWorkers', 'double');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetMaximumNumberOfWorkers;
p.SetFunction = @pSetMaximumNumberOfWorkers;

p = schema.prop(hThisClass, 'MinimumNumberOfWorkers', 'double');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetMinimumNumberOfWorkers;
p.SetFunction = @pSetMinimumNumberOfWorkers;

p = schema.prop(hThisClass, 'CreateTime', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetCreateTime;

p = schema.prop(hThisClass, 'SubmitTime', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetSubmitTime;

p = schema.prop(hThisClass, 'StartTime', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetStartTime;

p = schema.prop(hThisClass, 'FinishTime', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetFinishTime;

p = schema.prop(hThisClass, 'Tasks', 'handle vector');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetTasks;

p = schema.prop(hThisClass, 'FileDependencies', 'string vector');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetFileDependencies;
p.SetFunction = @pSetFileDependencies;

p = schema.prop(hThisClass, 'PathDependencies', 'string vector');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetPathDependencies;
p.SetFunction = @pSetPathDependencies;

p = schema.prop(hThisClass, 'JobData', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetJobData;
p.SetFunction = @pSetJobData;

p = schema.prop(hThisClass, 'Parent', 'handle');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetParent;

% This is a private field to job that can be used to cache JobData
p = schema.prop(hThisClass, 'JobDataCache', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(hThisClass, 'UserData', 'MATLAB array');
p.AccessFlags.PublicSet = 'on';
p.AccessFlags.Serialize = 'off';
% Make Userdata local by storing on the UDD object

p = schema.prop(hThisClass, 'QueuedFcn', 'MATLAB callback');
p.SetFunction = @iSetQueuedFcn;

p = schema.prop(hThisClass, 'RunningFcn', 'MATLAB callback');
p.SetFunction = @iSetRunningFcn;

p = schema.prop(hThisClass, 'FinishedFcn', 'MATLAB callback');
p.SetFunction = @iSetFinishedFcn;

e = schema.event(hThisClass, 'PostQueue');
e = schema.event(hThisClass, 'PostRun');
e = schema.event(hThisClass, 'PostFinish');


%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function val = iSetQueuedFcn(obj, val)
obj.pSetCallbackFcn('PostQueue', val);
%--------------------------------------------------------------------------
function val = iSetRunningFcn(obj, val)
obj.pSetCallbackFcn('PostRun', val);
%--------------------------------------------------------------------------
function val = iSetFinishedFcn(obj, val)
obj.pSetCallbackFcn('PostFinish', val);
