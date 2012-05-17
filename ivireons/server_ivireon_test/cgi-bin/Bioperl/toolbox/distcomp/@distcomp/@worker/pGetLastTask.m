function val = pGetLastTask(obj, val)
; %#ok Undocumented
%pGetLastJob 
%
%  VAL = pGetLastJob(OBJ, VAL)

%  Copyright 2000-2008 The MathWorks, Inc.

%  $Revision: 1.1.8.5 $    $Date: 2008/08/26 18:13:47 $ 

proxyWorker = obj.ProxyObject;
try
    proxies = proxyWorker.getLastJobAndTask;
    jobProxy  = proxies.getJobID();
    taskProxy = proxies.getTaskID();
    [found, lastJob] = findObjectInHashtable(distcomp.getdistcompobjectroot, jobProxy);
    if found
        val = distcomp.createObjectsFromProxies(taskProxy, @distcomp.task, lastJob);
    end
catch
    % TODO
end
