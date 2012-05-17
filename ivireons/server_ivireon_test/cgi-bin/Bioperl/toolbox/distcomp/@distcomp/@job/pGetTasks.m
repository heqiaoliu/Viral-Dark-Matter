function val = pGetTasks(job, val)
; %#ok Undocumented
%PGETTASKS A short description of the function
%
%  VAL = PGETTASKS(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.5 $    $Date: 2006/09/27 00:21:06 $ 

if ~isempty(job.ProxyObject)
    try
        % Get the java tasks from the job
        proxyTasks = job.ProxyObject.getTasks(job.UUID);
        val = distcomp.createObjectsFromProxies(proxyTasks(1), @distcomp.task, job);
    catch
        % TODO - error thrown in here?        
    end
else
    % TODO - what if ProxyObject is empty?
end