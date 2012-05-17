function OK = pCancelOrDestroyJob( obj, job, cancelOrDestroy )
; %#ok Undocumented
%pCancelOrDestroyJob - cancel or destroy the job 

%  Copyright 2006-2009 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $    $Date: 2009/07/14 03:52:58 $

% Get the information about the actual scheduler used
data = job.pGetJobSchedulerData;
if isempty(data)
    % This indicates that the job has not been submitted - in which
    % case it is acceptable to cancel the job
    OK = true;
    return
end
% Is the job actually an local job?
if ~strcmp(data.type, 'local')
    % Not a local job - we really shouldn't cancel this
    warning('distcomp:localscheduler:InvalidScheduler', 'Unable to cancel job because it is not a local scheduler job');
    OK = false;
    return
end
% Do we own this job?
if ~isequal(data.submitProcInfo, obj.ProcessInformation)
    % Warning only if the job is still running.
    state = job.State;    
    if distcomp.jobStateIsAfter(state, 'pending') && distcomp.jobStateIsBefore(state, 'finished')
        % Not a local job from this scheduler
        warning('distcomp:localscheduler:InvalidScheduler', 'Unable to cancel job because it was not created by this local scheduler');
    end
    OK = false;
    return
end
try
    % Need the local scheduler java object
    s = obj.LocalScheduler;
    % Loop on the contained taskUUIDs
    taskUUIDs = data.taskUUIDs;
    for i = 1:numel(taskUUIDs)
        % Get the actual command from the local scheduler
        command = s.getCommand(taskUUIDs{i});
        % If we didn't find that one then loop
        if isempty(command)
            continue;
        end
        % CancelorDestroy the command
        cancelOrDestroy(command);
    end
    % We succeeded
    OK = true;
catch err
    warning('distcomp:localscheduler:UnknownError', 'Unable to cancel job on local scheduler. Reason given:\n%s', err.message);
    OK = false;
end