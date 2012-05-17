function OK = pCancelJob(obj, job)
; %#ok Undocumented
%pCancelJob allow scheduler to cancel job 
%
%  OK = pCancelJob(SCHEDULER, JOB)
%
% The return argument OK is used to indicate if the function managed to
% cancel the job or not - this will be used to write to the state of
% the job.

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.2 $    $Date: 2006/06/11 16:56:57 $ 

% Since this function doesn't make any attempt to actually cancel the
% the job indicate that to the job
warning('distcomp:scheduler:unsupported', 'This scheduler cannot cancel running jobs.');
OK = false;
