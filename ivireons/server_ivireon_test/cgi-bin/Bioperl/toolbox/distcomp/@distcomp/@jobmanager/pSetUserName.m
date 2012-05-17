function val = pSetUserName(jm, val)
; %#ok Undocumented
% Set the user identity of the current user in the job manager proxy.

%  Copyright 2009-2010 The MathWorks, Inc.

%  $Revision: 1.1.6.2 $    $Date: 2010/02/25 08:01:32 $ 

import com.mathworks.toolbox.distcomp.auth.credentials.UserIdentity;
if isa(val, 'UserIdentity')
    userIdentity = val;
else
    userIdentity = UserIdentity(val);
end

proxyManager = jm.ProxyObject;
if ~isempty(proxyManager)
    if isempty(val)
        error('distcomp:auth:InvalidUsername', ...
              'The username must not be empty.');
    end

    try
        proxyManager.setCurrentUser(userIdentity);
        jm.JobAccessProxy.setCurrentUser(userIdentity);
        jm.ParallelJobAccessProxy.setCurrentUser(userIdentity);
        jm.TaskAccessProxy.setCurrentUser(userIdentity);
    catch err
        throw(distcomp.handleJavaException(jm, err));
    end
end
val = '';
