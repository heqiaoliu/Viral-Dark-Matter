function state = pGetJobState(scheduler, job, state)
; %#ok Undocumented
%pGetJobState - deferred call to ask the scheduler for state information
%
%  STATE = pGetJobState(SCHEDULER, JOB, STATE)

%  Copyright 2005-2009 The MathWorks, Inc.

%  $Revision: 1.1.6.6 $    $Date: 2009/10/12 17:27:48 $

[wasSubmitted, isMpi, isAlive, pid, whyNotAlive] = scheduler.pInterpretJobSchedulerData( job ); %#ok

if ~wasSubmitted
    return
end

if ~isMpi
    % Can't tell
    return
end

% If the job is queued, running or unavailable, check with the PID if we can
if strcmp(state, 'queued') || strcmp(state, 'running') || strcmp( state, 'unavailable' )
    
    if isAlive
        % Ok
    else
        if strcmp( whyNotAlive.reason, 'wrongclient' )
            % Can't tell
            return
        else
            % Avoid a race condition - when we enter this function, the file state hasn't
            % been checked yet. So, let's check that and see if it has got to finished.
            serializer = job.pReturnSerializer;
            state = char(serializer.getField(job, 'state'));
            if strcmp( state, 'finished' )
                % Return immediately if we see that the job has indeed finished.
                return
            end
            
            state = 'failed';
            % Ask the tasks what state they think they are in
            jobState = job.pGetStateFromTasks;
            if strcmp(jobState, 'finished')
                state = jobState;
            end
            % Set job and tasks to final state
            job.pSetState( state );
            tasks = job.Tasks;
            for i = 1:numel(tasks)
                if ~strcmp( tasks(i).State, 'finished' )
                    % Only modify tasks that haven't already finished.
                    tasks(i).pSetState( state );
                end
            end
        end
    end
end
