function val = pSetCredentialStore(jm, val)
; %#ok Undocumented
% Set the credential store in the job manager proxy (and all the access
% proxies).

%  Copyright 2009-2010 The MathWorks, Inc.

%  $Revision: 1.1.6.2 $    $Date: 2010/02/25 08:01:30 $ 

proxyManager = jm.ProxyObject;
if ~isempty(proxyManager)
    try
        proxyManager.setCredentialStore(val);
        jm.JobAccessProxy.setCredentialStore(val);
        jm.ParallelJobAccessProxy.setCredentialStore(val);
        jm.TaskAccessProxy.setCredentialStore(val);
    catch err
        throw(distcomp.handleJavaException(jm, err));
    end
end
val = [];
