function schema
%SCHEMA defines the distcomp.task class
%

% Copyright 2004-2008 The MathWorks, Inc.

hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('proxyobject');
hThisClass   = schema.class(hThisPackage, 'task', hParentClass);

p = schema.prop(hThisClass, 'ID', 'int32');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetID;

p = schema.prop(hThisClass, 'Function', 'MATLAB callback');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetFunction;
p.SetFunction = @pSetFunction;

p = schema.prop(hThisClass, 'NumberOfOutputArguments', 'int32');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetNumberOfOutputArguments;
p.SetFunction = @pSetNumberOfOutputArguments;

p = schema.prop(hThisClass, 'InputArguments', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetInputArguments;
p.SetFunction = @pSetInputArguments;

p = schema.prop(hThisClass, 'OutputArguments', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.AbortSet  = 'off';
p.AccessFlags.Serialize = 'off';
p.GetFunction = @pGetOutputArguments;

p = schema.prop(hThisClass, 'CaptureCommandWindowOutput', 'bool');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetCaptureCommandWindowOutput;
p.SetFunction = @pSetCaptureCommandWindowOutput;

p = schema.prop(hThisClass, 'CommandWindowOutput', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetCommandWindowOutput;

p = schema.prop(hThisClass, 'LogLevel', 'int32');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetLogLevel;
p.SetFunction = @pSetLogLevel;

p = schema.prop(hThisClass, 'LogOutput', 'string');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetLogOutput;

p = schema.prop(hThisClass, 'State', 'distcomp.taskexecutionstate');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetState;

% Need to define a default value for Error that is 'no error'
% so reset lasterr and put in a FactoryValue
p = schema.prop(hThisClass, 'Error', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.AbortSet  = 'off';
p.AccessFlags.Serialize = 'off';
p.GetFunction = @pGetError;
p.AccessFlags.Init = 'on';
p.FactoryValue = MException('', '');

p = schema.prop(hThisClass, 'ErrorMessage', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetErrorMessage;

p = schema.prop(hThisClass, 'ErrorIdentifier', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetErrorIdentifier;

p = schema.prop(hThisClass, 'Timeout', 'double');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetTimeout;
p.SetFunction = @pSetTimeout;

p = schema.prop(hThisClass, 'CreateTime', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetCreateTime;

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

p = schema.prop(hThisClass, 'Worker', 'handle');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetWorker;

p = schema.prop(hThisClass, 'Parent', 'handle');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetParent;

p = schema.prop(hThisClass, 'FailedAttemptInformation', 'handle vector');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetFailedAttemptInformation;

p = schema.prop(hThisClass, 'AttemptedNumberOfRetries', 'double');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetAttemptedNumberOfRetries;

p = schema.prop(hThisClass, 'MaximumNumberOfRetries', 'double');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetMaximumNumberOfRetries;
p.SetFunction = @pSetMaximumNumberOfRetries;

p = schema.prop(hThisClass, 'UserData', 'MATLAB array');	 
p.AccessFlags.Serialize = 'off';	 
 % Make Userdata local by storing on the UDD object	 
 % p.GetFunction = @pGetUserData;	 
 % p.SetFunction = @pSetUserData;

p = schema.prop(hThisClass, 'RunningFcn', 'MATLAB callback');
p.SetFunction = @iSetRunningFcn;

p = schema.prop(hThisClass, 'FinishedFcn', 'MATLAB callback');
p.SetFunction = @iSetFinishedFcn;

% Sometimes we want to set information on a TaskInfo object rather than
% on the actual proxy object - This allows us to aggregate a number of 
% individual set calls together without incurring any RMI overhead. If 
% this property is NOT empty then the set function should endeavor to 
% set on this property rather than on the proxy object
p = schema.prop(hThisClass, 'TaskInfo', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';

% Some of the properties that will end up in the TaskInfo object of this
% task are backed by mxArray data that needs to persist until the TaskInfo
% object is finished with. To do this the data should be stored in this
% cache - this will be a cell array that can grow or shrink appropriately
p = schema.prop(hThisClass, 'TaskInfoCache', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.AccessFlags.Init      = 'on';
p.FactoryValue = {};


schema.event(hThisClass, 'PostRun');
schema.event(hThisClass, 'PostFinish');

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function val = iSetRunningFcn(obj, val)
obj.pSetCallbackFcn('PostRun', val);
%--------------------------------------------------------------------------
function val = iSetFinishedFcn(obj, val)
obj.pSetCallbackFcn('PostFinish', val);
