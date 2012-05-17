function val = pGetBusyWorkers(obj, val)
; %#ok Undocumented
%pGetBusyWorkers A short description of the function
%
%  VAL = pGetBusyWorkers(OBJ, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2006/06/27 22:37:26 $ 

proxyManager = obj.ProxyObject;
try
    proxyWorkers = proxyManager.getBusyWorkers;
    val = distcomp.createObjectsFromProxies(proxyWorkers, @distcomp.worker, distcomp.getdistcompobjectroot);
catch
    % TODO
end
