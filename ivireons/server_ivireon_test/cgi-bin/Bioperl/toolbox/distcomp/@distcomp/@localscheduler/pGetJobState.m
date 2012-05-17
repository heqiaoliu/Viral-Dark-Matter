function state = pGetJobState(local, job, state)
; %#ok Undocumented
%pGetJobState - deferred call to ask the scheduler for state information
%
%  STATE = pGetJobState(SCHEDULER, JOB, STATE)

%  Copyright 2006-2009 The MathWorks, Inc.
%  $Revision: 1.1.6.6 $    $Date: 2009/10/12 17:27:45 $


% Only bother asking the scheduler if the state is currently queued or
% running
if ~any(strcmp(state, {'queued' 'running'}))
    return
end
% Get the information about the actual scheduler used
data = job.pGetJobSchedulerData;
if isempty(data) || ~strcmp(data.type, 'local')
    % This indicates that the job has not been submitted or is not local
    return
end
% Test if this job was submitted by this process
if ~isequal( data.submitProcInfo, local.ProcessInformation )
    % Test that this job belongs to this machine - if not ignore
    if ~strcmp(data.submitProcInfo.hostname, local.ProcessInformation.hostname)
        return
    end
    % At this point we know that the hostnames are the same, and that it
    % wasn't submitted by this process we need to check if the process it
    % was submitted by is alive and has the correct name. If so leave
    % alone, otherwise default to a failed job or task
    [pidname, isAlive] = dct_psname( data.submitProcInfo.pid );
    if isAlive && strcmp(pidname, data.submitProcInfo.pidname) 
        return
    end
end
% If the process that submitted this 
% Want to do different things based on the type of job (serial or parallel)
if isa(job, 'distcomp.simplejob')
     state = iGetJobStateForSerialJob(job, data, local.LocalScheduler);
elseif isa(job, 'distcomp.simpleparalleljob')
    state = iGetJobStateForParallelJob(job, data, local.LocalScheduler);
end

if any(strcmp(state, {'finished' 'failed'}))
    job.pSetState(state);
end

function state = iGetJobStateForParallelJob(job, data, javascheduler)
% Get the actual command from the local scheduler - they will all be
% the same UUID so just get that
command = javascheduler.getCommand(data.taskUUIDs{1});
% If we  find that one then ask it what it knows
if ~isempty(command)
    state = char(command.getState());
else
    state = 'failed';
end
if strcmp(state, 'failed')
    % Fall back and check what really happened on disk as we know that 
    % MATLAB can still exit with non-zero exit status and be OK
    jobState = job.pGetStateFromTasks;
    if strcmp(jobState, 'finished')
        state = jobState;
    end
    % Set job and tasks to final state
    job.pSetState( state );
    tasks = job.Tasks;
    for i = 1:numel(tasks)
        if ~strcmp( tasks(i).State, 'finished' )
            tasks(i).pSetState(state);
        end
    end
end
 

function state = iGetJobStateForSerialJob(job, data, javascheduler)
tasks = job.Tasks;
% Treat these are the four possible 
% states, queued, running, finished, failed
numInState = [0 0 0 0];
QUEUED = 1;RUNNING = 2;FINISHED = 3;FAILED = 4;
for i = 1:numel(tasks)
    thisTask = tasks(i);
    IDindex = find(data.taskIDs == tasks(i).ID, 1);
    taskUUID = data.taskUUIDs{IDindex};
    thisTaskFailed = false;
    % This test should never succeed but if it does we should just use
    % the value on disk
    if isempty(taskUUID)
        continue
    end
    command = javascheduler.getCommand(taskUUID);
    if ~isempty(command)
        taskState = char(command.getState);
        switch taskState
            case 'queued'
                numInState(QUEUED) = numInState(QUEUED) + 1;
            case 'running'
                numInState(RUNNING) = numInState(RUNNING) + 1;
            case 'finished'
                numInState(FINISHED) = numInState(FINISHED) + 1;
            case 'failed'
                thisTaskFailed = true;
            otherwise
                
        end
    else
        % Didn't find the task in the local scheduler - task must have
        % failed
       thisTaskFailed = true; 
    end
    if thisTaskFailed
        % When the local scheduler says that a task is in the failed state it is
        % possible that PCT code has finished executing correctly but that
        % MATLAB has exited with a non-zero exit status after we have finished
        % up. To pro-actively search for this situation we get the actual task
        % state here and we DO NOT set a task as failed if it indicates it has
        % finished correctly
        thisTaskState = thisTask.pGetState;
        if strcmp(thisTaskState, 'finished')
            numInState(FINISHED) = numInState(FINISHED) + 1;
        else
            numInState(FAILED) = numInState(FAILED) + 1;
            % Only set the task state if it hasn't already been set.
            if ~strcmp(thisTaskState, 'failed')
                thisTask.pSetState('failed');
            end
        end
    end
end
if numInState(QUEUED) > 0 && all(numInState([RUNNING FINISHED FAILED]) == 0)
    state = 'queued';
    return
end
if any(numInState([QUEUED RUNNING])) > 0
    state = 'running';
    return
end
if numInState(FAILED) == 0
    state = 'finished';
    return
else
    state = 'failed';
    return
end
    
