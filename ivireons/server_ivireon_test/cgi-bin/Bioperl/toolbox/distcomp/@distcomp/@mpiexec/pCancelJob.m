function OK = pCancelJob( obj, job )
; %#ok Undocumented
%pCancelJob - cancel the job by killing the mpiexec process

%  Copyright 2000-2006 The MathWorks, Inc.
%  $Revision: 1.1.10.3 $    $Date: 2008/05/05 21:36:33 $ 

% Cancel jobs by looking for the pid and killing it. We shouldn't even be here
% unless we think that the job state is running, queued or unavailable.

OK = false;

[wasSubmitted, isMpi, isAlive, pid, whyNotAlive] = obj.pInterpretJobSchedulerData( job ); %#ok

if ~wasSubmitted
    OK = true;
    return
end

if ~isMpi
    % Not an MPIEXEC job - we really shouldn't cancel this
    warning( 'distcomp:mpiexec:InvalidScheduler', ...
             'Unable to cancel job %d because it is not an MPIEXEC job', job.ID );
    return
end

if isAlive
    % yes, we can cancel
    try
        dct_psfcns( 'kill', pid );
    catch err
        % Failed to kill - maybe permissions?
        warning( 'distcomp:mpiexec:cantcancel', ...
                 'Unable to cancel job %d by kill process with PID %d. The reason given was: %s', ...
                 job.ID, pid, err.message );
        % return false
        return
    end
    if dct_psfcns( 'isalive', pid )
        % then the "kill" will have warned - return OK == false
        return 
    else
        % Set the PID to -1 so that it never gets checked again
        jsd = job.pGetJobSchedulerData;
        jsd.pid = -1;
        job.pSetJobSchedulerData( jsd );
        
        OK = true;
        return
    end
else
    % Why wasn't the job alive?
    if strcmp( whyNotAlive.reason, 'wrongclient' )
        % Not OK - warn and return false
        warning( 'distcomp:mpiexec:cantcancel', ...
                 ['MPIEXEC can only cancel jobs on the host where the job was ', ...
                  'submitted (%s).'], whyNotAlive.description );
        return
    else
        % The pid simply isn't alive any more, nothing for us to do
        OK = true;
        return
    end
end
