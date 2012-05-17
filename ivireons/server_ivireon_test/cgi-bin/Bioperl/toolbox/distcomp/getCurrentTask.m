function currentTask = getCurrentTask
%getCurrentTask Get task object currently being evaluated in this worker session
%
%    task = getCurrentTask returns the task object that is currently being
%    evaluated by the worker session.
%
%    If the function is executed in a MATLAB session that is not a worker,
%    you get an empty result.
%
%    Example:
%    % Find the current task
%    task = getCurrentTask;
%    % Get task ID to find its rank 
%    id = get(task, 'ID');
%
%    See also findResource, getCurrentJobmanager, getCurrentWorker, getCurrentJob

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.3 $    $Date: 2006/06/27 22:33:23 $ 

try
    root = distcomp.getdistcompobjectroot;
    currentTask = root.CurrentTask;
catch
    warning('distcomp:getCurrentTask:InvalidState', 'Unexpected error trying to invoke getCurrentTask');
    currentTask = [];
end
