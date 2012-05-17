function schema
%SCHEMA defines the distcomp.genericscheduler class
%

%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.10.5 $  $Date: 2008/05/19 22:45:07 $


hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('abstractscheduler');
hThisClass   = schema.class(hThisPackage, 'genericscheduler', hParentClass);

p = schema.prop(hThisClass, 'MatlabCommandToRun', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = 'worker';


p = schema.prop(hThisClass, 'SubmitFcn', 'MATLAB callback');
p.AccessFlags.AbortSet = 'off';

p = schema.prop(hThisClass, 'ParallelSubmitFcn', 'MATLAB callback');
p.AccessFlags.AbortSet = 'off';

p = schema.prop(hThisClass, 'GetJobStateFcn', 'MATLAB callback');
p.AccessFlags.AbortSet = 'off';

p = schema.prop(hThisClass, 'CancelJobFcn', 'MATLAB callback');
p.AccessFlags.AbortSet = 'off';

p = schema.prop(hThisClass, 'CancelTaskFcn', 'MATLAB callback');
p.AccessFlags.AbortSet = 'off';

p = schema.prop(hThisClass, 'DestroyJobFcn', 'MATLAB callback');
p.AccessFlags.AbortSet = 'off';

p = schema.prop(hThisClass, 'DestroyTaskFcn', 'MATLAB callback');
p.AccessFlags.AbortSet = 'off';

% This field holds the current jobs for which we are calling the GetStateFcn. This
% allows us to control the behaviour of recursion into the callback.
p = schema.prop(hThisClass, 'JobsWithGetJobStateFcnRunning', 'MATLAB array');
p.AccessFlags.AbortSet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = handle([]);

