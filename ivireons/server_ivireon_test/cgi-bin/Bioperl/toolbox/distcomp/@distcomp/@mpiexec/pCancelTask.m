function OK = pCancelTask( obj, task )
; %#ok Undocumented
%pCancelTask allow scheduler to cancel task
% 
%  pCancelTask(SCHEDULER, TASK)
%  This function is not supported for the mpiexec scheduler

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.6.3 $    $Date: 2006/06/27 22:38:04 $ 

% MPIEXEC cancels tasks by cancelling the job
job = task.Parent;
OK = obj.pCancelJob( job );
