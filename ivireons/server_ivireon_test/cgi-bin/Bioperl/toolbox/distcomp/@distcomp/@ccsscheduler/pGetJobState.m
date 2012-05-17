function state = pGetJobState(ccs, job, state)
%pGetJobState - deferred call to ask the scheduler for state information
%
%  STATE = pGetJobState(SCHEDULER, JOB, STATE)

%  Copyright 2006-2009 The MathWorks, Inc.

%  $Revision: 1.1.6.3 $    $Date: 2009/04/15 22:57:55 $

% Only ask the scheduler what the job state is if it is queued or running
if strcmp(state, 'queued') || strcmp(state, 'running')
    % Get the information about the actual scheduler used
    data = job.pGetJobSchedulerData;
    if isempty(data)
        return
    end
    % Is the job actually a Microsoft scheduler job?
    if ~isa(data, 'distcomp.MicrosoftJobSchedulerData')
        return
    end
    s = ccs.pGetTempConnectionToScheduler(data.SchedulerName, data.APIVersion);
    try
        schedulerState = s.getJobStateByID(data.SchedulerJobID);
    catch err %#ok<NASGU>
        % Failed to retrieve the schedulerState, so leave the state alone
        return;
    end
    
    state = schedulerState;
    % Set the state on the job if the scheduler reports that it
    % is in the finished or failed state.
    if strcmpi(state, 'finished') || strcmpi(state, 'failed')
        job.pSetState(state);
    end
end
