function promote(jm, job)
%promote  Promote a job that is queued in a job manager.
%
% promote(jobmanager, job) promotes the job object job that is queued in a 
% job queue. If the job object is not the last job in the queue, 
% the position of job and the previous job object are exchanged.
%
% See also distcomp.jobmanager/createJob, distcomp.jobmanger/findJob,
%          distcomp.jobmanager/demote, distcomp.job/submit

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.4 $    $Date: 2008/02/02 13:00:28 $ 


% Ensure we haven't been passed a job array
if numel(job) > 1
    error('distcomp:jobmanager:InvalidArgument',...
    'The input to promote must be a scalar job object, not a vector of job objects');
end

% Ensure that the job is parented by this jobmanager
if ~isequal(job.Parent, jm)
    error('distcomp:jobmanager:InvalidArgument',...
    'The job to be promoted must exist on the job manager');    
end

try
    uuid = job.pReturnUUID;
    jm.ProxyObject.promote(uuid(1));
catch err
    throw(distcomp.handleJavaException(jm, err));
end