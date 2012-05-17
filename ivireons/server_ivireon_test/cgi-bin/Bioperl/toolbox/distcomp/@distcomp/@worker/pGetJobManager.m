function val = pGetJobManager(obj, val)
; %#ok Undocumented
%pGetJobManager 
%
%  VAL = pGetJobManager(OBJ, VAL)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:39:53 $ 

proxyWorker = obj.ProxyObject;
try
    proxy = proxyWorker.getJobManager;
    val = distcomp.createObjectsFromProxies(proxy, @distcomp.jobmanager, distcomp.getdistcompobjectroot);
catch
    % TODO
end
