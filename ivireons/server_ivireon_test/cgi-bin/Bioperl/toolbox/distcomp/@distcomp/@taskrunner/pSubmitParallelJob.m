function pSubmitParallelJob(scheduler, job) %#ok<INUSD>
; %#ok Undocumented
%pSubmitJob A short description of the function
%
%  pSubmitJob(SCHEDULER, JOB)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2007/12/10 21:28:03 $ 

try
    pSubmitJob(scheduler, job);
catch e
    throw(e);
end

