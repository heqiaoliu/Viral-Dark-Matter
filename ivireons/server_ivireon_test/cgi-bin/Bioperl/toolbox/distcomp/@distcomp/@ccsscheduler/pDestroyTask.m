function pDestroyTask(obj, task)
%pDestroyTask allow scheduler to kill task
%
%  pDestroyTask(SCHEDULER, TASK)

%  Copyright 2006 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2006/06/11 16:58:06 $ 

pCancelTask(obj, task);