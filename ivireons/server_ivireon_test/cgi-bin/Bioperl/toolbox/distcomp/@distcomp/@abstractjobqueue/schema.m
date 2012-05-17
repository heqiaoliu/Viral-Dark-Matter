function schema
%SCHEMA defines the distcomp.jobmanager class
%

% Copyright 2004-2006 The MathWorks, Inc.

hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('proxyobject');
hThisClass   = schema.class(hThisPackage, 'abstractjobqueue', hParentClass);

p = schema.prop(hThisClass, 'Name', 'string');
p.AccessFlags.PublicSet  = 'off';
p.AccessFlags.PrivateSet  = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet = 'off';
p.GetFunction = @pGetName;
p.Description = 'The name given to the manager when the service was registered.';

p = schema.prop(hThisClass, 'Hostname', 'string');
p.AccessFlags.PublicSet  = 'off';
p.AccessFlags.PrivateSet  = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet = 'off';
p.GetFunction = @pGetHostname;
p.Description = 'The hostname of the machine running the JobQueue.';

p = schema.prop(hThisClass, 'HostAddress', 'string vector');
p.AccessFlags.PublicSet  = 'off';
p.AccessFlags.PrivateSet  = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet = 'off';
p.GetFunction = @pGetHostAddress;
p.Description = 'The IP address of the machine running the JobQueue.';

% These callbacks will actually get managed by listeners held in the
% EventListeners property. These fields mirror the callbacks in the three
% particular listeners, and hence the callback action is driven directly by
% those listeners. This has the benefit that internally we can use send and
% listen and not worry about the older Fcn type callbacks.
%
% p = schema.prop(hThisClass, 'JobCreatedFcn', 'MATLAB callback');
% p.SetFunction = @iSetJobCreatedFcn;
% p.Description = 'The function to call when a job is submitted to the job queue.';
% 
% p = schema.prop(hThisClass, 'JobQueuedFcn', 'MATLAB callback');
% p.SetFunction = @iSetJobQueuedFcn;
% p.Description = 'The function to call when a job is submitted to the job queue.';
% 
% p = schema.prop(hThisClass, 'JobRunningFcn', 'MATLAB callback');
% p.SetFunction = @iSetJobRunningFcn;
% p.Description = 'The function to call when a job is starts running.';
% 
% p = schema.prop(hThisClass, 'JobFinishedFcn', 'MATLAB callback');
% p.SetFunction = @iSetJobFinishedFcn;
% p.Description = 'The function to call when a job finishes running.';

%--------------------------------------------------------------------------
% The properties below are internal to the object and represent the actual
% java objects used by the class methods and properties
%--------------------------------------------------------------------------

% These events are all sent with distcomp.JobEventData in the event argument
schema.event(hThisClass, 'JobPostCreate');
schema.event(hThisClass, 'JobPostQueue');
schema.event(hThisClass, 'JobPostRun');
schema.event(hThisClass, 'JobPostFinish');

schema.event(hThisClass, 'JobPostChange');

%{
%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function val = iSetJobCreatedFcn(obj, val)
warning('distcomp:abstractjobqueue:NotImplemented', 'Not Implemented yet');
%--------------------------------------------------------------------------
function val = iSetJobQueuedFcn(obj, val)
obj.pSetCallbackFcn('JobPostQueue', val);
%--------------------------------------------------------------------------
function val = iSetJobRunningFcn(obj, val)
obj.pSetCallbackFcn('JobPostRun', val);
%--------------------------------------------------------------------------
function val = iSetJobFinishedFcn(obj, val)
obj.pSetCallbackFcn('JobPostFinish', val);
%}
