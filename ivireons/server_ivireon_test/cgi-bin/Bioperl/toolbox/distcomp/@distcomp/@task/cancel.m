function cancel(task, opt_user_message)
%cancel  Cancel a pending or running task.
%
%    cancel(t) stops the task object, t, that is currently in the pending
%    or running state. The task's State property is set to finished, and
%    no output arguments are returned. An error message stating that the
%    task was canceled is placed in the task object's ErrorMessage
%    property, and the worker session running the task is restarted.
%    
%    Example:
%    % Create a task and later cancel it.
%    jm = findResource('scheduler', 'type', 'jobmanager', ...
%                      'LookupURL', 'JobMgrHost');
%    j  = createJob(jm);
%    t  = createTask(j, @rand, 1, {3, 4});
%    cancel(t);
%    
%    See also distcomp.job/cancel

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2008/02/02 13:00:53 $ 

currentUser = char(java.lang.System.getProperty('user.name'));
currentHost = char(java.net.InetAddress.getLocalHost.getCanonicalHostName);
message = sprintf('Task cancelled by user: %s on machine: %s', currentUser, currentHost);
if nargin >= 2
   message = sprintf( '%s\nwith message: %s', message, opt_user_message );
end
for i = 1:numel(task)
    try        
        task(i).ProxyObject.cancel(task(i).UUID, message);
    catch err
        throw(distcomp.handleJavaException(task(i), err));
    end
end
