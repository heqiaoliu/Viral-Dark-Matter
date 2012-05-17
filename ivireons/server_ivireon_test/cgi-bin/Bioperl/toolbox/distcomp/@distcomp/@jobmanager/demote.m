function demote(jm, job)
%demote  Demote a job that is queued in a job manager.
%
% demote(jobmanger, job) demotes the job object job that is queued in a job 
% queue. If the job object is not the last job in the queue, the position 
% of job and the next job object are exchanged.
%
% See also distcomp.jobmanager/createJob, distcomp.jobmanger/findJob,
%          distcomp.jobmanager/promote, distcomp.job/submit

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.4 $    $Date: 2008/02/02 13:00:16 $ 


% Ensure we haven't been passed a job array
if numel(job) > 1
    error('distcomp:jobmanager:InvalidArgument',...
    'The input to demote must be a scalar job object, not a vector of job objects');
end

% Ensure that the job is parented by this jobmanager
if ~isequal(job.Parent, jm)
    error('distcomp:jobmanager:InvalidArgument',...
    'The job to be demoted must exist on the job manager');    
end

try
    uuid = job.pReturnUUID;
    jm.ProxyObject.demote(uuid(1));
catch err
    throw(distcomp.handleJavaException(jm, err));
end
