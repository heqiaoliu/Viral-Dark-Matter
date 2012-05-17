function pSubmitJob(scheduler, job)
; %#ok Undocumented
%pSubmitJob A short description of the function
%
%  pSubmitJob(SCHEDULER, JOB)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:36:37 $ 

% Ensure we have a submit function to try
if isempty(scheduler.SubmitFcn)
    error('distcomp:genericscheduler:InvalidState', 'You must define a SubmitFcn to use a generic scheduler');
end

scheduler.pSubmitJobCommon( job, scheduler.SubmitFcn );
