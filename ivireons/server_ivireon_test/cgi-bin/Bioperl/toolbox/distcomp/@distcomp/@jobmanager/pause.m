function pause(jm, varargin)
%pause  Pause the job manager queue
%
%    pause(jm) pauses the job manager's queue so that jobs waiting in the
%    queued state will not run. Jobs that are already running also pause,
%    after completion of tasks that are already running. No further jobs
%    or tasks will run until the resume function is called for the job
%    manager.
%    The pause function does nothing if the job manager is already paused.
%    
%    See also distcomp.jobmanager/resume

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2008/02/02 13:00:27 $ 

LAST_ERROR_THROWN = [];
for i = 1:numel(jm)
    try
        jm(i).ProxyObject.pauseQueue;
    catch err
        if ~isempty(LAST_ERROR_THROWN)
            warn = distcomp.handleJavaException(jm(i), LAST_ERROR_THROWN);
            warning(warn.identifier, warn.message);
        end
        LAST_ERROR_THROWN = err;
    end
end

if ~isempty(LAST_ERROR_THROWN)
    throw(distcomp.handleJavaException(jm, LAST_ERROR_THROWN));
end

