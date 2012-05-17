function state = pbsGetJobState(scheduler, job, state)
%pbsGetJobState Gets the state of a job on a cluster.
%
% Set your schedulers's GetJobStateFcn to this function using the following
% command (see README):
%     set(sched, 'GetJobStateFcn', @pbsGetJobState);

%  Copyright 2006-2008 The MathWorks, Inc.

mlock;
persistent jobsToMonitorNames;

if isempty(jobsToMonitorNames)
    jobsToMonitorNames = {};
end

if isempty(scheduler.UserData)
    if ~iscell(scheduler.SubmitFcn) || length(scheduler.SubmitFcn) < 3
        error('distcomp:genericscheduler:SubmitFcnError',...
            'SubmitFcn must include clusterHost and remoteDataLocation as extra arguments.');
    end    
    scheduler.UserData = { scheduler.SubmitFcn{2} ; scheduler.SubmitFcn{3} };
end

jobName = job.pGetEntityLocation;
if strcmp(state, 'finished')
    jobsToMonitorNames = setxor(jobsToMonitorNames, {jobName});
else
    if strcmp(state, 'queued') || strcmp(state, 'running')
        if ~ismember(jobName, jobsToMonitorNames)
            jobsToMonitorNames = union(jobsToMonitorNames, {jobName});
            jobStateTimer = timer('Period', 10.0, 'ExecutionMode', 'fixedRate');
            set(jobStateTimer, 'TimerFcn', { @copyJobFilesIfFinished, scheduler, job });
            start(jobStateTimer);
        end
    end
end
