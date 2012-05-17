function currentJob = getCurrentJob
%getCurrentJob Get the job to which the current task belongs
%
%    job = getCurrentJob returns a reference to the job that contains the
%    current task. This function will return an empty array if executed in a
%    MATLAB session that is not a worker.  This function can be used to access
%    the job data associated with a number of tasks.
%
%    Example:
%    % Find the current job
%    job = getCurrentJob;
%    % Get job data
%    jobData = get(job, 'JobData');
%
% See also findResource, getCurrentJobmanager, getCurrentWorker, getCurrentTask

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.2 $    $Date: 2006/06/11 17:04:44 $ 

try
    root = distcomp.getdistcompobjectroot;
    currentJob = root.CurrentJob;
catch
    warning('distcomp:getCurrentJob:InvalidState', 'Unexpected error trying to invoke getCurrentJob');
    currentJob = [];
end
