function val = pGetTask(job, val)
%pGetTask Return a handle to the first task

% Copyright 2007 The MathWorks, Inc.

% $Revision: 1.1.6.1 $    $Date: 2007/10/10 20:41:17 $

if ~isempty(job.ProxyObject)
    try
        % Get the java task from the job
        proxyTasks = job.ProxyObject.getTasks(job.UUID);
        if isempty(proxyTasks(1))
            val = [];
        else
            val = distcomp.createObjectsFromProxies(proxyTasks(1, 1), ...
                                                    @distcomp.task, job);
        end
    catch
        % TODO - error thrown in here?
    end
else
    % TODO - what if ProxyObject is empty?
end