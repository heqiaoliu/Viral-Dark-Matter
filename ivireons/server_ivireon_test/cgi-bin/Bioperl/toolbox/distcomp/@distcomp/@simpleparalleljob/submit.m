function submit(job)
%submit  Queue a job in a job queue service
%
% submit(j) queues the job object, j, in the resource where it currently
% resides. The resource where a job queue resides is determined by how the
% job was created. A job may reside in the local MATLAB session, in a 
% remote job manager service, or in a remote MATLAB worker service. If 
% submit is called with no output arguments, then it is called 
% asynchronously, that is, the call to submit returns before the job is
% finished. An exception to this rule is if the job resides in the local
% MATLAB session, in which case the submit always executes synchronously.
%
% When a job contained in a job manager is submitted, the job's State
% property is set to queued, and the job is added to the list of jobs
% waiting to be executed by the job queue service. The jobs in the waiting
% list will be executed in a first in, first out manner, that is, the order
% in which they were submitted.
%
% Example:
%     % Find a job manager service named jobmanager1.
%     jm = findResource('jobmanager', 'Name', 'jobmanager1');
%     % Create a job object.
%     j = createJob(jm);
%     % Add a task object to be evaluated for the job.
%     t = createTask(j, @myfunction, {10, 10});
%     % Queue the job object in the job manager.
%     submit(j);
%
% See also distcomp.jobmanager/createJob, distcomp.jobmanager/findJob

%  Copyright 2005-2008 The MathWorks, Inc.

%  $Revision: 1.1.6.5 $    $Date: 2008/05/05 21:36:45 $ 

% Ensure that only one job has been passed in
if numel(job) > 1
    error('distcomp:job:InvalidArgument', 'The function submit requires a single job input');
end
if ~strcmp(job.Serializer.getField(job, 'state'), 'pending')
    error('distcomp:job:InvalidState', 'Invalid job state for operation');
end

% Get the Manager of the job to actually submit on
scheduler = job.Parent;
% Submit this job
try
    scheduler.pSubmitParallelJob(job);
catch err
    rethrow(err);
end
