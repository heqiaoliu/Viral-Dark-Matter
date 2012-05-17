function val = pGetCurrentJob(obj, val)
; %#ok Undocumented
%pGetCurrentJob 
%
%  VAL = pGetCurrentJob(OBJ, VAL)

%  Copyright 2000-2008 The MathWorks, Inc.

%  $Revision: 1.1.8.5 $    $Date: 2008/08/26 18:13:44 $ 

proxyWorker = obj.ProxyObject;
try
    proxies = proxyWorker.getCurrentJobAndTask;
    jobProxy = proxies.getJobID();
    [found, val] = findObjectInHashtable(distcomp.getdistcompobjectroot, jobProxy);
    val = val(found);
catch
    % TODO
end
