function pDestroyTask(obj, task)
; %#ok Undocumented
%pDestroyTask allow scheduler to kill task
%
%  pDestroyTask(SCHEDULER, TASK)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.6.2 $    $Date: 2006/06/27 22:38:06 $ 

% Only cancel the task if the job is queued or running
job = task.Parent;
if obj.pShouldCancelJobBeforeDestruction( job )
    pCancelTask(obj, task);
end