function cancel(job, opt_user_message)
%cancel  Cancel a pending, queued, or running job
%
%    cancel(j) stops the job object, j, that is pending, queued or running.
%    The job's State property is set to finished, , and a cancel is executed
%    on all tasks in the job that are not in the finished state.  Any results
%    that have been computed for the job object are saved and may be accessed
%    normally.  A job object that has been canceled cannot be started again.
%    
%    cancel(j, 'message') cancels the job with an additional user-specified
%    message. This message will be added to the default cancellation message.
%    
%    If the job is running in a job manager, any worker sessions that are
%    evaluating tasks belonging to the job object will be restarted.
%    
%    Example:
%    jm = findResource('scheduler', 'type', 'jobmanager', ...
%                          'LookupURL', 'JobMgrHost'););
%    j  = createJob(jm);
%    cancel(j);
%    
%    See also distcomp.job/submit, distcomp.job/cancel

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.4 $    $Date: 2008/02/02 12:59:49 $ 

currentUser = char(java.lang.System.getProperty('user.name'));
currentHost = char(java.net.InetAddress.getLocalHost.getCanonicalHostName);
message = sprintf('Job cancelled by user: %s on machine: %s', currentUser, currentHost);
if nargin >= 2
   message = sprintf( '%s\nwith message: %s', message, opt_user_message );
end
for i = 1:numel(job)
    try
        job(i).ProxyObject.cancel(job(i).UUID, message)
    catch err
        throw(distcomp.handleJavaException(job(i), err));
    end
end
