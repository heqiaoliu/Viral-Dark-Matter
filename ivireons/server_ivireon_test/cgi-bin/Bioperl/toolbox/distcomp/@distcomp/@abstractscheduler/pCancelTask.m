function OK = pCancelTask(obj, task)
; %#ok Undocumented
%pCancelTask allow scheduler to cancel task
%
%  OK = pCancelTask(SCHEDULER, TASK)
%
% The return argument OK is used to indicate if the function managed to
% cancel the task or not - this will be used to write to the state of
% the task.

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.2 $    $Date: 2006/06/11 16:56:58 $ 

% Since this function doesn't make any attempt to actually cancel the
% the task indicate that to the task
warning('distcomp:scheduler:unsupported', 'This scheduler cannot cancel running tasks.');
OK = false;
