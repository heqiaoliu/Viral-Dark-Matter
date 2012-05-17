function pDestroyJob(obj, job)
; %#ok Undocumented
%pDestroyJob allow scheduler to kill job 
%
%  pDestroyJob(SCHEDULER, JOB)

%  Copyright 2007 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2007/11/09 19:50:55 $ 

pCancelJob(obj, job);
