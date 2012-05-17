function OK = pCancelJob(obj, job)
; %#ok Undocumented
%pCancelJob allow scheduler to cancel job 
%
%  pCancelJob(SCHEDULER, JOB)

%  Copyright 2007-2008 The MathWorks, Inc.

%  $Revision: 1.1.6.2 $    $Date: 2008/05/05 21:36:41 $ 

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
    % Is the job actually an PBS job?
    if ~strcmp(data.type, 'pbs')
        % Not a PBS job - we really shouldn't cancel this
        warning('distcomp:pbsscheduler:InvalidScheduler', 'Unable to cancel job because it is not a PBS job');
        OK = false;
        return
    end
    % Finally let's get the actual jobIDs
    jobIDs = data.pbsJobIds;
    
    % Ask PBS to kill these
    for ii=1:length( jobIDs )
        [FAILED, out] = obj.pPbsSystem(sprintf('qdel "%s"', jobIDs{ii}));
        OK = ~FAILED;
        % Did PBS think it managed to kill this job?
        if FAILED
            % Some returns from PBS shouldn't really be treated as failures
            ACCEPTABLE_ERROR = obj.pIsAcceptableQdelError(out);
            % Cancel succeeded if it was an ACCEPTABLE_ERROR
            OK = ACCEPTABLE_ERROR;
            % Not an acceptable error - issue a warning, and return - don't attempt to
            % qdel others.
            if ~ACCEPTABLE_ERROR
                warning('distcomp:pbsscheduler:UnableToFindService', ...
                        'Unable to cancel job because the PBS script command ''qdel''\nthrew an error. The reason given is \n %s', out);
                return
            end
        end
    end
catch err
    % If an error is thrown we were not able to cancel the job
    OK = false;
    warning('distcomp:pbsscheduler:SchedulerError', ...
            'Unable to cancel job because the scheduler threw an error. Nested error:\n%s', err.message);
end