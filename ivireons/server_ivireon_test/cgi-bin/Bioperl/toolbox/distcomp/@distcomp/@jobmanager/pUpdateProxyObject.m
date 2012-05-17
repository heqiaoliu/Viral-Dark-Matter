function pUpdateProxyObject(objs, proxies)
; %#ok Undocumented
%pUpdateProxyObject insert a new java proxy object into this UDD wrapper
%
%  pUpdateProxyObject(OBJS, PROXIES)

%  Copyright 2004-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.5 $    $Date: 2008/03/31 17:07:36 $ 

for i = 1:numel(objs)
    thisJM = objs(i);
    thisProxy = proxies(i);
    % Let's try a trick to see if the current proxy is working
    try
        thisJM.ProxyObject.getState;
        PROXY_INACTIVE = false;
    catch err % #ok<NAGSU>
        PROXY_INACTIVE = true;
    end        
    % Update the cached proxies
    if PROXY_INACTIVE
        try
            % Set this objects information from the actual proxy
            thisJM.ProxyObject = thisProxy;        
            thisJM.JobAccessProxy = thisProxy.getJobAccess;
            thisJM.ParallelJobAccessProxy = thisProxy.getParallelJobAccess;
            thisJM.TaskAccessProxy = thisProxy.getTaskAccess;
        catch err
            % Catch a possible ProxySerialization exception
            throw(distcomp.handleJavaException(thisJM, err));
        end
        % Now propagate the changes to the children correctly
        nextJob = thisJM.down;
        % Define a fake parent changed event to send to each job
        jobEvent.NewParent = thisJM;
        while ~isempty(nextJob)
            % Call the event callback directly to update the job proxies
            nextJob.pSetMyProxyObject(jobEvent);
            % And iterate over the jobs tasks
            nextTask = nextJob.down;
            % Define a fake parent changed event to pass to each task
            taskEvent.NewParent = nextJob;
            while ~isempty(nextTask)
                % Call the event callback directly to update the task proxies
                nextTask.pSetMyProxyObject(taskEvent);
                % Get the next task
                nextTask = nextTask.right;
            end
            % Get the next job
            nextJob = nextJob.right;
        end
    end
end
