function pSubmitJob(jm, job)
; %#ok Undocumented
%pSubmitJob A short description of the function
%
%  pSubmitJob(JM, JOB)

%  Copyright 2000-2009 The MathWorks, Inc.

%  $Revision: 1.1.8.6 $    $Date: 2009/12/03 19:00:08 $ 
try
    job.pPrepareJobForSubmission;
    jobAccessProxy = jm.pGetJobAccessProxy;
    workersToUse = [];
    jobAccessProxy.submit(job.UUID, workersToUse);
catch err
    % let caller handle error
    rethrow(err);
end
