function val = pGetIdleWorkers(obj, val)
; %#ok Undocumented
%pGetIdleWorkers A short description of the function
%
%  VAL = pGetIdleWorkers(OBJ, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2006/06/27 22:37:30 $ 

proxyManager = obj.ProxyObject;
try
    proxyWorkers = proxyManager.getIdleWorkers;
    val = distcomp.createObjectsFromProxies(proxyWorkers, @distcomp.worker, distcomp.getdistcompobjectroot);
catch
    % TODO
end
