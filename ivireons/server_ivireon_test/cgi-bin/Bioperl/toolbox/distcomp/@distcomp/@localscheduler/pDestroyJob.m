function pDestroyJob(obj, job)
; %#ok Undocumented
%pDestroyJob allow scheduler to kill job 
%
%  pDestroyJob(SCHEDULER, JOB)

%  Copyright 2006 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $    $Date: 2006/12/06 01:35:13 $

pCancelOrDestroyJob(obj, job, @destroy);