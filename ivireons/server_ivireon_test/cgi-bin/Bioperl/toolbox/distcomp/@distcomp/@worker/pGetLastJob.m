function val = pGetLastJob(obj, val)
; %#ok Undocumented
%pGetLastJob 
%
%  VAL = pGetLastJob(OBJ, VAL)

%  Copyright 2000-2008 The MathWorks, Inc.

%  $Revision: 1.1.8.5 $    $Date: 2008/08/26 18:13:46 $ 

proxyWorker = obj.ProxyObject;
try
    proxies = proxyWorker.getLastJobAndTask;
    jobProxy = proxies.getJobID();
    [found, val] = findObjectInHashtable(distcomp.getdistcompobjectroot, jobProxy);
    val = val(found);
catch
    % TODO
end
