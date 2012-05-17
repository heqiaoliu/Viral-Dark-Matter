function val = pGetWorker(task, val)
; %#ok Undocumented
%pGetWorker A short description of the function
%
%  VAL = pGetWorker(TASK, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2006/06/27 22:39:30 $ 

proxyTask = task.ProxyObject;
try
    proxyWorker = proxyTask.getWorker(task.UUID);
    if ~isempty(proxyWorker(1))
        val = distcomp.createObjectsFromProxies(proxyWorker(1), @distcomp.worker, distcomp.getdistcompobjectroot);
    end
catch
    % TODO
end
