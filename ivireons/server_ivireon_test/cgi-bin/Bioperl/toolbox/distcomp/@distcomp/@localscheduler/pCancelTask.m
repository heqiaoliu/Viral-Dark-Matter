function OK = pCancelTask( obj, task ) 
; %#ok Undocumented
%pCancelTask allow scheduler to cancel task
% 
%  pCancelTask(SCHEDULER, TASK)

%  Copyright 2006-2007 The MathWorks, Inc.

%  $Revision: 1.1.6.2 $    $Date: 2007/09/14 16:02:49 $

OK = pCancelOrDestroyTask( obj, task, @cancel );