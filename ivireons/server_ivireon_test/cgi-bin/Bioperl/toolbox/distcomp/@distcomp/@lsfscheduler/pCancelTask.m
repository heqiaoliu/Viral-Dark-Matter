function OK = pCancelTask(obj, task)
; %#ok Undocumented
%pCancelTask allow scheduler to cancel task
%
%  pCancelTask(SCHEDULER, TASK)

%  Copyright 2005-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.7 $    $Date: 2008/05/05 21:36:21 $ 

try
    % Default cancel status
    OK = false;
    job = task.Parent;
    % Get the information about the actual scheduler used
    data = job.pGetJobSchedulerData;
    if isempty(data)
        % This indicates that the task has not been submitted - in which
        % case it is acceptable to cancel the job
        OK = true;
       return
    end
    % Is the job actually an LSF job?
    if ~strcmp(data.type, 'lsf')
        % Not an LSF job - we really shouldn't cancel this
        warning('distcomp:lsfscheduler:InvalidScheduler', 'Unable to cancel task because it is not contained in an LSF job');
        OK = false;
        return
    end
    % Finally let's get the actual jobID
    jobID = data.lsfID;
    taskID = task.ID;
    if isa(job, 'distcomp.simpleparalleljob')
        killCommand = sprintf('bkill "%d"', jobID);
    else
        killCommand = sprintf('bkill "%d[%d]"', jobID, taskID);
    end
    % Ask LSF about this job
    [FAILED, out] = dctSystem(killCommand);
    OK = ~FAILED;
    % Did LSF think it managed to kill this job?
    if FAILED
        % Some returns from LSF shouldn't really be treated as failures
        ACCEPTABLE_ERROR = obj.pIsAcceptableBkillError(out);
        % Cancel succeeded if it was an ACCEPTABLE_ERROR
        OK = ACCEPTABLE_ERROR;
        % Not an acceptable error - issue a warning
        if ~ACCEPTABLE_ERROR
            warning('distcomp:lsfscheduler:UnableToFindService', ...
                'Unable to cancel task because the LSF script command ''bkill''\nthrew an error. The reason given is \n %s', out);
            return
        end
    end
catch err
    % If an error is thrown we were not able to cancel the job
    OK = false;   
    warning('distcomp:lsfscheduler:SchedulerError', ...
        'Unable to cancel task because the scheduler threw an error. Nested error:\n%s', err.message);
end
