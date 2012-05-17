function val = pSetInteractiveAuthentication(jm, val)
; %#ok Undocumented
% Set the flag for interactive authentication.
% If set to true the user might get prompted for passwords.
% If set to false no password prompts appear and any action requiring
% authentication will fail.

%  Copyright 2009-2010 The MathWorks, Inc.

%  $Revision: 1.1.6.2 $    $Date: 2010/02/25 08:01:31 $ 

proxyManager = jm.ProxyObject;
if ~isempty(proxyManager)
    try
        proxyManager.getCredentialConsumerFactory().setInteractive(val);
        jm.JobAccessProxy.getCredentialConsumerFactory().setInteractive(val);
        jm.ParallelJobAccessProxy.getCredentialConsumerFactory().setInteractive(val);
        jm.TaskAccessProxy.getCredentialConsumerFactory().setInteractive(val);
    catch err
        throw(distcomp.handleJavaException(jm, err));
    end
end
val = false;
