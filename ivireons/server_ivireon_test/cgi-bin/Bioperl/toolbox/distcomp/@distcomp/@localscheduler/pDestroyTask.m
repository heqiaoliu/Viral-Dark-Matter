function pDestroyTask(obj, task)
; %#ok Undocumented
%pDestroyTask allow scheduler to kill task
%
%  pDestroyTask(SCHEDULER, TASK)

%  Copyright 2006 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $    $Date: 2006/12/06 01:35:14 $

% We shouldn't actually destroy a paralleljob's task
if isa(task.Parent, 'distcomp.simplejob')
    pCancelOrDestroyTask( obj, task, @destroy );
else
    pCancelOrDestroyTask( obj, task, @cancel );
end