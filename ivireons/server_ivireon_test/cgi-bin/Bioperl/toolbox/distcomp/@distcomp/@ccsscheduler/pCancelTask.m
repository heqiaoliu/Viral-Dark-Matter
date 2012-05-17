function OK = pCancelTask(obj, task)
%pCancelTask allow scheduler to cancel task
%
%  pCancelTask(SCHEDULER, TASK)

%  Copyright 2006-2009 The MathWorks, Inc.

%  $Revision: 1.1.6.5 $    $Date: 2009/04/15 22:57:47 $

job = task.Parent;
% Get the information about the actual scheduler used
data = job.pGetJobSchedulerData;
if isempty(data)
    % This indicates that the job has not been submitted - in which
    % case it is acceptable to cancel the job
    OK = true;
    return
end
% Is the job actually a Microsoft scheduler job?
if ~isa(data, 'distcomp.MicrosoftJobSchedulerData')
    % Not a Microsoft scheduler job - we really shouldn't cancel this
    warning('distcomp:ccsscheduler:InvalidScheduler', 'Unable to cancel job because it is not an HPC Server scheduler job');
    OK = false;
    return
end
% Was this task from an SOA job?
if data.IsSOAJob
    % We don't know how to cancel individual tasks on an SOA job
    warning('distcomp:ccsscheduler:SoaTaskCancel', 'Unable to cancel tasks on SOA jobs');
    OK = false;
    return
end

% Finally let's get the actual jobID and taskID on the scheduler.
ccsJobID = data.SchedulerJobID;
ccsTaskID = data.getMicrosoftTaskIDFromMatlabID(task.ID);
% Did we find the relevant ccsTaskID?
if isempty(ccsTaskID ) || numel(ccsTaskID ) > 1
    OK = false;
    warning('distcomp:ccsscheduler:cannotFindTask', ...
        'Cannot find task in HPC Server scheduler');
    return;
end

try
    % Now ask the correct server connection to cancel the task
    s = obj.pGetTempConnectionToScheduler(data.SchedulerName, data.APIVersion);
    s.cancelTaskByID(ccsJobID, ccsTaskID);
    % We succeeded
    OK = true;
catch err
    warning('distcomp:ccsscheduler:UnknownError', 'Unable to cancel task on HPC Server scheduler. Reason given:\n%s', err.message);
    OK = false;
end
