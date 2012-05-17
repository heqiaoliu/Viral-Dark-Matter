function state = sgeGetJobState(scheduler, job, state)
%sgeGetJobState Gets the state of a job on a cluster.
%
% Set your schedulers's GetJobStateFcn to this function using the following
% command (see README):
%     set(sched, 'GetJobStateFcn', @sgeGetJobState);

%  Copyright 2006-2008 The MathWorks, Inc.

mlock;
persistent jobsToMonitorNames;

if isempty(jobsToMonitorNames)
    jobsToMonitorNames = {};
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
