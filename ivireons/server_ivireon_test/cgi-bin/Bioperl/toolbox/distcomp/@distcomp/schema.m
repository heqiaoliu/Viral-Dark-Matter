function schema
%creates the distcomp user object package

% Copyright 2004-2006 The MathWorks, Inc.


schema.package('distcomp');

% Make sure that we call initclient so that the java security model is in
% place before we try and use any RemoteObjects
initclient;

import com.mathworks.toolbox.distcomp.workunit.WorkUnit;

% NOTE - The order in which the states below are defined in the enums is
% important as it defines an implicit one way movement for jobs and tasks.
% The implications is that a job that is running has previously been queued
% and a job that is finished has been through the previous two states

if isempty(findtype('distcomp.jobmanagerexecutionstate'))
    % These states are determined by the JobManagerProxy's isQueuePaused
    % method
    schema.EnumType('distcomp.jobmanagerexecutionstate', {'unavailable','paused','running'}, [-2 1 0]);
end

% Note that 'failed' occurs after 'finished' - this ensures that a call to
% waitForState('finished') will return if the job or task enters the
% 'failed' state.

if isempty(findtype('distcomp.jobexecutionstate'))
    schema.EnumType('distcomp.jobexecutionstate', ...
        {'unavailable','pending','queued','running','finished','failed','destroyed'}, ...
        [-2 WorkUnit.PENDING_STATE WorkUnit.QUEUED_STATE WorkUnit.RUNNING_STATE WorkUnit.FINISHED_STATE -3 -1]);
end

if isempty(findtype('distcomp.taskexecutionstate'))
    schema.EnumType('distcomp.taskexecutionstate', ...
        {'unavailable','pending','running','finished','failed','destroyed'}, ...
        [-2 WorkUnit.PENDING_STATE WorkUnit.RUNNING_STATE WorkUnit.FINISHED_STATE -3 -1]);
end

if isempty(findtype('distcomp.workerexecutionstate'))
    schema.EnumType('distcomp.workerexecutionstate', {'unavailable','paused','running'}, [-2 1 0]);
end
    
if isempty(findtype('distcomp.workertype'))
    schema.EnumType('distcomp.workertype', ...
                    {'pc', 'unix', 'mixed'}, [1 2 3]);
end

% Define an enum that indicates what type of interactive job we are
% currently undertaking
if isempty(findtype('distcomp.interactivetype'))
    schema.EnumType('distcomp.interactivetype', ...
                    {'none', 'pmode', 'matlabpool'}, ...
                    [0 1 2]);
end
