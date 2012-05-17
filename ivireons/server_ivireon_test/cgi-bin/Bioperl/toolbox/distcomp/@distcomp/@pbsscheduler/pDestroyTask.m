function pDestroyTask(obj, task)
; %#ok Undocumented
%pDestroyTask allow scheduler to kill task
%
%  pDestroyTask(SCHEDULER, TASK)

%  Copyright 2007 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2007/11/09 19:50:56 $ 

pCancelTask(obj, task);
