function setJobSchedulerData(scheduler, job, userdata) %#ok<INUSL>
%setJobSchedulerData  set specific userdata for a job on a generic scheduler
%
%  SETJOBSCHEDULERDATA(SCHEDULER, JOB, USERDATA)
%
%    The intent of this function, and its partner getJobSchedulerData is to
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
%    % In the SubmitFcn, when some information about the job has been
%    % returned from a call to the external scheduler, you might want to store
%    % that information for later use.
%    scheduler.setJobSchedulerData(job, struct('ExternalID', ID));
%
%    See also distcomp.genericscheduler/getJobSchedulerData

%  Copyright 2008 The MathWorks, Inc.

%  $Revision: 1.1.6.3 $    $Date: 2008/08/08 12:51:28 $ 

job.pSetJobSchedulerData(struct('type', 'generic', 'userdata', {userdata}));
