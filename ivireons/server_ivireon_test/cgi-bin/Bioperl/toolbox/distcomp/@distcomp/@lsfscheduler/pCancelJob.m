function OK = pCancelJob(obj, job)
; %#ok Undocumented
%pCancelJob allow scheduler to cancel job 
%
%  pCancelJob(SCHEDULER, JOB)

%  Copyright 2005-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.5 $    $Date: 2008/05/05 21:36:20 $ 

try
    % Default cancel status
    OK = false;
    % Get the information about the actual scheduler used
    data = job.pGetJobSchedulerData;
    if isempty(data)
        % This indicates that the job has not been submitted - in which
        % case it is acceptable to cancel the job
        OK = true;
        return
    end
    % Is the job actually an LSF job?
    if ~strcmp(data.type, 'lsf')
        % Not an LSF job - we really shouldn't cancel this
        warning('distcomp:lsfscheduler:InvalidScheduler', 'Unable to cancel job because it is not an LSF job');
        OK = false;
        return
    end
    % Finally let's get the actual jobID
    jobID = data.lsfID;
    % Ask LSF about this job
    [FAILED, out] = dctSystem(sprintf('bkill %d', jobID));
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
                'Unable to cancel job because the LSF script command ''bkill''\nthrew an error. The reason given is \n %s', out);
            return
        end
    end
catch err
    % If an error is thrown we were not able to cancel the job
    OK = false;
    warning('distcomp:lsfscheduler:SchedulerError', ...
        'Unable to cancel job because the scheduler threw an error. Nested error:\n%s', err.message);
end