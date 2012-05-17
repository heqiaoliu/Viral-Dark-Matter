function val = pSetCredentialConsumerFactory(jm, val)
; %#ok Undocumented
% Set the consumer factory in the job manager proxy (and all access proxies).

%  Copyright 2010 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2010/02/25 08:01:29 $ 

proxyManager = jm.ProxyObject;
if ~isempty(proxyManager)
    try
        proxyManager.setCredentialConsumerFactory(val);
        jm.JobAccessProxy.setCredentialConsumerFactory(val);
        jm.ParallelJobAccessProxy.setCredentialConsumerFactory(val);
        jm.TaskAccessProxy.setCredentialConsumerFactory(val);
    catch err
        throw(distcomp.handleJavaException(jm, err));
    end
end
val = [];
