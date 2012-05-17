function userdata = getJobSchedulerData(scheduler, job) %#ok<INUSL>
%getJobSchedulerData  get specific userdata for a job on a generic scheduler
%
%  USERDATA = GETJOBSCHEDULERDATA(SCHEDULER, JOB)
%
%    The intent of this function, and its partner setJobSchedulerData is to
%    provide generic scheduler interface code with a place to store information
%    about this particular job on the external scheduler. For example, it might
%    be useful to store the external ID of this job, such that the
%    GetJobStateFcn can ask the scheduler what the state of that particular ID
%    is at a later time.
%
%    It is expected that the set variant of this function will be called in
%    the submit function and that the cancel, destroy, and state functions
%    will use the get variant.
%
%    Example:
%    % In the GetJobStateFcn for a generic scheduler you might want to
%    % retrieve the job information that you stored during the submit
%    % function.
%    jobInfo = scheduler.getJobSchedulerData(job);
%
%    See also distcomp.genericscheduler/setJobSchedulerData

%  Copyright 2008 The MathWorks, Inc.

%  $Revision: 1.1.6.3 $    $Date: 2008/08/08 12:51:27 $ 

data = job.pGetJobSchedulerData;
userdata = [];
% Is the job actually a generic job?
if isempty(data) || ~strcmp(data.type, 'generic')
    return
end
userdata = data.userdata;
