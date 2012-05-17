function setCurrentTaskInfo(obj, jobmanager, worker, job, task, runprop, handlers)
; %#ok Undocumented
%setCurrentTaskInfo set information about current task for worker MATLAB
%
%  setCurrentTaskInfo(obj, jJobManagerProxy, jWorkerProxy, jJobProxy, jTaskProxy)
% 

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.5 $    $Date: 2008/10/02 18:40:44 $ 


obj.CurrentJobmanager = jobmanager;
obj.CurrentWorker = worker;
obj.CurrentJob = job;
obj.CurrentTask = task;
obj.CurrentRunprop = runprop;
obj.CurrentErrorHandlers = handlers;