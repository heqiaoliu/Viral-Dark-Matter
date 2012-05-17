function OK = pCancelOrDestroyTask( obj, task, cancelOrDestroy )
; %#ok Undocumented
%pCancelOrDestroyTask - cancel the task

%  Copyright 2006-2009 The MathWorks, Inc.

%  $Revision: 1.1.6.4 $    $Date: 2009/07/14 03:52:59 $


job = task.Parent;
% Get the information about the actual scheduler used
data = job.pGetJobSchedulerData;
if isempty(data)
    % This indicates that the job has not been submitted - in which
    % case it is acceptable to cancel the job
    OK = true;
    return
end
% Is the job actually a local job?
if ~strcmp(data.type, 'local')
    % Not a local job - we really shouldn't cancel this
    warning('distcomp:localscheduler:InvalidScheduler', 'Unable to cancel task because it is not a local scheduler task');
    OK = false;
    return
end
% Do we own this job?
if ~isequal(data.submitProcInfo, obj.ProcessInformation)
    % Warning only if the job is still running.
    state = task.State;    
    if distcomp.taskStateIsAfter(state, 'pending') && distcomp.taskStateIsBefore(state, 'finished')
        % Not a local job from this scheduler
        warning('distcomp:localscheduler:InvalidScheduler', 'Unable to cancel task because it was not created by this local scheduler');
    end
    OK = false;
    return
end

IDindex = find(data.taskIDs == task.ID, 1);
taskUUID = data.taskUUIDs{IDindex};
% Did we find the relevant taskID?
if isempty(taskUUID) || numel(taskUUID) > 1
    OK = false;
    warning('distcomp:localscheduler:UnknownError', 'Cannot find task in local scheduler');
    return 
end
try
    % Need the local scheduler java object
    s = obj.LocalScheduler;
    % Get the actual command from the local scheduler
    command = s.getCommand(taskUUID);
    % If we didn't find that one then loop
    if ~isempty(command)
        % Cancel the command
        cancelOrDestroy(command);
    end
    % We succeeded
    OK = true;
catch err
    warning('distcomp:localscheduler:UnknownError', 'Unable to cancel job on local scheduler. Reason given:\n%s', err.message);
    OK = false;
end