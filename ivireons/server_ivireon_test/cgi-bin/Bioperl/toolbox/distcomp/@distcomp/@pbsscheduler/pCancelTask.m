function OK = pCancelTask(obj, task)
; %#ok Undocumented
%pCancelTask allow scheduler to cancel task
%
%  pCancelTask(SCHEDULER, TASK)

%  Copyright 2007-2008 The MathWorks, Inc.

%  $Revision: 1.1.6.4 $    $Date: 2008/05/05 21:36:42 $ 

try
    job = task.Parent;

    % Get the information about the actual scheduler used
    data = job.pGetJobSchedulerData;
    if isempty(data)
        % This indicates that the task has not been submitted - in which
        % case it is acceptable to cancel the job
        OK = true;
        return
    end

    % Is the job actually an PBS job?
    if ~strcmp(data.type, 'pbs')
        % Not an PBS job - we really shouldn't cancel this
        warning('distcomp:pbsscheduler:InvalidScheduler', 'Unable to cancel task because it is not contained in an PBS job');
        OK = false;
        return
    end
    
    if isa(job, 'distcomp.simpleparalleljob')
        killCommand = sprintf( 'qdel "%s"', data.pbsJobIds{1} );
    else
        % Finally let's get task identifier
        taskID = pCalcTaskIdentifier( obj, task, data );
        killCommand = sprintf( 'qdel "%s"', taskID );
    end
    
    % Ask PBS to kill this job/task
    [FAILED, out] = obj.pPbsSystem(killCommand);
    OK = ~FAILED;

    % Did PBS think it managed to kill this job?
    if FAILED
        % Some returns from PBS shouldn't really be treated as failures
        ACCEPTABLE_ERROR = obj.pIsAcceptableQdelError(out);
        % Cancel succeeded if it was an ACCEPTABLE_ERROR
        OK = ACCEPTABLE_ERROR;
        % Not an acceptable error - issue a warning
        if ~ACCEPTABLE_ERROR
            warning('distcomp:pbsscheduler:UnableToFindService', ...
                    'Unable to cancel task because the PBS script command ''qdel''\nthrew an error. The reason given is \n %s', out);
            return
        end
    end
catch err
    % If an error is thrown we were not able to cancel the job
    OK = false;   
    warning('distcomp:pbsscheduler:SchedulerError', ...
        'Unable to cancel task because the scheduler threw an error. Nested error:\n%s', err.message);
end
