function pSubmitParallelJob(scheduler, job)
; %#ok Undocumented
%pSubmitJob A short description of the function
%
%  pSubmitJob(SCHEDULER, JOB)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.6.2 $    $Date: 2006/06/27 22:36:39 $ 

% Ensure we have a submit function to try
if isempty(scheduler.ParallelSubmitFcn)
    error('distcomp:genericscheduler:InvalidState', ...
          ['You must define a ParallelSubmitFcn to ', ...
           'use a generic scheduler with parallel jobs'] );
end

% Duplicate the tasks for parallel execution
job.pDuplicateTasks;

scheduler.pSubmitJobCommon( job, scheduler.ParallelSubmitFcn );