function resume(jm)
%resume  Resume processing of the queue of the job manager
%
%    resume(jm) resumes processing of the job manager's queue so that jobs that
%    are waiting in the queued state will be run.  This call will do nothing if
%    the job manager is not paused.
%    
%    See also distcomp.jobmanager/pause

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2008/02/02 13:00:29 $ 

LAST_ERROR_THROWN = [];
for i = 1:numel(jm)
    try
        jm(i).ProxyObject.resumeQueue;
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


