function currentJobmanager = getCurrentJobmanager
%getCurrentJobmanager Get job manager object that distributed current task
%
%    jobmanager = getCurrentJobmanager returns the job manager object that has
%    sent the task currently being evaluated by the worker session.
%
%    If the function is executed in a MATLAB session that is not a worker,
%    you get an empty result.
%
%    If your tasks are distributed by a third-party scheduler instead of a
%    job manager, getCurrentJobmanager returns a distcomp.taskrunner
%    object.
%
%    Example:
%    % Find the current job manager 
%    jm = getCurrentJobmanager;
%    % Get the name of the jobmanager
%    name = get(jm, 'Name');
%
% See also findResource, getCurrentWorker, getCurrentJob, getCurrentTask

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.2 $    $Date: 2006/06/11 17:04:45 $ 

try
    root = distcomp.getdistcompobjectroot;
    currentJobmanager = root.CurrentJobmanager;
catch
    warning('distcomp:getCurrentJobmanager:InvalidState', 'Unexpected error trying to invoke getCurrentJobmanager');
    currentJobmanager = [];
end
