function currentWorker = getCurrentWorker
%getCurrentWorker Get worker object currently running this session
%
%    worker = getCurrentWorker returns the worker object representing the
%    session that is currently evaluating the task that calls this
%    function.
%
%    If the function is executed in a MATLAB session that is not a worker
%    or if you are using a third-party scheduler instead of a job manager,
%    you get an empty result.
%
%    Example:
%    % Find the current worker 
%    worker = getCurrentWorker;
%    % Get the name of the worker
%    name = get(worker, 'Name');
%
%    See also findResource, getCurrentJobmanager, getCurrentJob, getCurrentTask

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.2 $    $Date: 2006/06/11 17:04:47 $ 

try
    root = distcomp.getdistcompobjectroot;
    currentWorker = root.CurrentWorker;
catch
    warning('distcomp:getCurrentWorker:InvalidState', 'Unexpected error trying to invoke getCurrentWorker');
    currentWorker = [];
end
