function val = pGetCurrentTask(obj, val)
; %#ok Undocumented
%pGetCurrentJob 
%
%  VAL = pGetCurrentJob(OBJ, VAL)

%  Copyright 2000-2008 The MathWorks, Inc.

%  $Revision: 1.1.8.5 $    $Date: 2008/08/26 18:13:45 $ 

proxyWorker = obj.ProxyObject;
try
    proxies = proxyWorker.getCurrentJobAndTask;
    jobProxy  = proxies.getJobID();
    taskProxy = proxies.getTaskID();
    [found, currentJob] = findObjectInHashtable(distcomp.getdistcompobjectroot, jobProxy);
    if found
        val = distcomp.createObjectsFromProxies(taskProxy, @distcomp.task, currentJob);
    end
catch
    % TODO
end
