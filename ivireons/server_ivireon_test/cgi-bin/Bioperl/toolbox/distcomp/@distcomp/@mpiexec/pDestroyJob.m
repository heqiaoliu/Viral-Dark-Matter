function pDestroyJob(obj, job)
; %#ok Undocumented
%pDestroyJob allow scheduler to kill job 
%
%  pDestroyJob(SCHEDULER, JOB)

%  Copyright 2005-2006 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $    $Date: 2006/06/27 22:38:05 $ 

if obj.pShouldCancelJobBeforeDestruction( job )
    pCancelJob(obj, job);
end
