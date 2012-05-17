function OK = pCancelJob(obj, job)
%pCancelJob allow scheduler to cancel job
%
%  pCancelJob(SCHEDULER, JOB)

%  Copyright 2006-2009 The MathWorks, Inc.

%  $Revision: 1.1.6.6 $    $Date: 2009/04/15 22:57:46 $

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

% Return early if the job is finished
jobState = job.pGetStateFromStorage;
if distcomp.jobStateIsAtOrAfter(jobState, 'finished')
    OK = true;
    return
end

% Cancel the job using the scheduler.
try
    % Get a temp connection to scheduler that actually ran the job
    s = obj.pGetTempConnectionToScheduler(data.SchedulerName, data.APIVersion);
    s.cancelJob(data);
    % We succeeded
    OK = true;
catch err
    warning('distcomp:ccsscheduler:UnknownError', 'Unable to cancel job on HPC Server scheduler. Reason given:\n%s', err.message);
    OK = false;
end
