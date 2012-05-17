function pSubmitJob(scheduler, job)
; %#ok Undocumented
%pSubmitJob A short description of the function
%
%  pSubmitJob(SCHEDULER, JOB)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:35:07 $ 

error('distcomp:abstractscheduler:AbstractMethodCall', 'Scheduler sub-classes MUST override this method');

