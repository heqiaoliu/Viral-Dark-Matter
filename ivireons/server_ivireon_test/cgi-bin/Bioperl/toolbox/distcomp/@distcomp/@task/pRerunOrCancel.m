function pRerunOrCancel(task, opt_user_message)
; %#ok Undocumented
%PRERUNORCANCEL Tries to rerun a task (cancels it if this is failing)
%
%  PRERUNORCANCEL(TASK, OPT_USER_MESSAGE)

%  Copyright 2008 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2008/05/19 22:45:27 $


currentUser = char(java.lang.System.getProperty('user.name'));
currentHost = char(java.net.InetAddress.getLocalHost.getCanonicalHostName);
message = sprintf('Task cancelled by user: %s on machine: %s', ...
                  currentUser, currentHost);
if nargin >= 2
   message = sprintf( '%s\nwith message: %s', message, opt_user_message );
end
for i = 1:numel(task)
    try        
        task(i).ProxyObject.rerunOrCancel(task(i).UUID, message);
    catch
        error(distcomp.handleJavaException(task(i)));
    end
end
