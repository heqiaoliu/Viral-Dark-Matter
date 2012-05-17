function submit(job)
%submit  Queue a job in scheduler
%
%    submit(j) queues the job object, j, in the scheduler queue.  The
%    scheduler used for this job was determined when the job was created.
%    
%    When a job contained in a job manager is submitted, the job's State
%    property is set to queued, and the job is added to the list of jobs
%    waiting to be executed.
%    
%    The jobs in the waiting list are executed in a first in, first out
%    manner; that is, the order in which they were submitted, except when
%    the sequence is altered by promote, demote, cancel, or destroy.
%
%    Example:
%    % Find a job manager running on the host JobMgrHost.
%    jm = findResource('scheduler', 'type', 'jobmanager', ...
%                      'LookupURL', 'JobMgrHost');
%    % Create a job object.
%    j = createJob(jm);
%    % Add a task object to be evaluated for the job.
%    t = createTask(j, @myfunction, 1, {10, 10});
%    % Queue the job object in the job manager.
%    submit(j);
%    
%    See also distcomp.jobmanager/createJob, distcomp.jobmanager/findJob

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.4 $    $Date: 2008/02/02 13:00:09 $ 

% Ensure that only one job has been passed in
if numel(job) > 1
    error('distcomp:job:InvalidArgument', 'The function submit requires a single job input');
end

% Get the Manager of the job to actually submit on
jm = job.pGetManager;
% Submit this job
try
    jm.pSubmitJob(job);
catch err
    throw(distcomp.handleJavaException(job, err));
end
