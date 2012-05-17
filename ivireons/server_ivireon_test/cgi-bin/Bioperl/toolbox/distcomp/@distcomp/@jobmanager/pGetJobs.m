function val = pGetJobs(jm, val)
; %#ok Undocumented
%PGETJOBS A short description of the function
%
%  VAL = PGETJOBS(JM, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.5 $    $Date: 2006/09/27 00:21:20 $ 

try
    % Get the java tasks from the job
    [proxyJobs, jobTypes] = jm.pGetJobsAndTypesFromProxy;
    % Need to get the correct constructor for a job
    constructors = jm.pGetUDDConstructorsForJobTypes(jobTypes);
    % Now try and construct the jobs
    val = distcomp.createObjectsFromProxies(proxyJobs, constructors, jm);
catch
    % TODO
end
