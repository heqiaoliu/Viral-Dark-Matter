function schema
%SCHEMA defines the distcomp.abstracttask class
%

%   Copyright 2005-2008 The MathWorks, Inc.

%   $Revision: 1.1.10.4 $  $Date: 2008/06/24 17:00:56 $


hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('abstractdataentity');
hThisClass   = schema.class(hThisPackage, 'abstracttask', hParentClass);


p = schema.prop(hThisClass, 'Function', 'MATLAB callback');
p.AccessFlags.AbortSet  = 'off';
p.SetFunction = @pSetFunction;
p.GetFunction = @pGetFunction;

p = schema.prop(hThisClass, 'NumberOfOutputArguments', 'double');
p.AccessFlags.AbortSet  = 'off';
p.SetFunction = @pSetNumberOfOutputArguments;
p.GetFunction = @pGetNumberOfOutputArguments;

p = schema.prop(hThisClass, 'InputArguments', 'MATLAB array');
p.AccessFlags.AbortSet  = 'off';
p.SetFunction = @pSetInputArguments;
p.GetFunction = @pGetInputArguments;

p = schema.prop(hThisClass, 'OutputArguments', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.AbortSet  = 'off';
p.SetFunction = @pSetOutputArguments;
p.GetFunction = @pGetOutputArguments;

p = schema.prop(hThisClass, 'CaptureCommandWindowOutput', 'bool');
p.AccessFlags.AbortSet  = 'off';
p.SetFunction = @pSetCaptureCommandWindowOutput;
p.GetFunction = @pGetCaptureCommandWindowOutput;

p = schema.prop(hThisClass, 'CommandWindowOutput', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.AbortSet  = 'off';
p.SetFunction = @pSetCommandWindowOutput;
p.GetFunction = @pGetCommandWindowOutput;

p = schema.prop(hThisClass, 'State', 'distcomp.taskexecutionstate');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.AbortSet  = 'off';
p.SetFunction = @pSetState;
p.GetFunction = @pGetState;

p = schema.prop(hThisClass, 'Error', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetError;
p.SetFunction = @pSetError;
p.AccessFlags.Init = 'on';
p.FactoryValue = MException('', '');

p = schema.prop(hThisClass, 'ErrorMessage', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.AbortSet  = 'off';
p.SetFunction = @pSetErrorMessage;
p.GetFunction = @pGetErrorMessage;

p = schema.prop(hThisClass, 'ErrorIdentifier', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.AbortSet  = 'off';
p.SetFunction = @pSetErrorIdentifier;
p.GetFunction = @pGetErrorIdentifier;

p = schema.prop(hThisClass, 'CreateTime', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.AbortSet  = 'off';
% Set at initialisation time
p.GetFunction = @pGetCreateTime;

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

p = schema.prop(hThisClass, 'Parent', 'handle');
p.AccessFlags.PublicSet = 'off';
p.GetFunction = @pGetParent;

schema.prop(hThisClass, 'UserData', 'MATLAB array');
