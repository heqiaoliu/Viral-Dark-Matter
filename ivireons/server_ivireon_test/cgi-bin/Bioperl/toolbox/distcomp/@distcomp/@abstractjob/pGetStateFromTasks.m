function state = pGetStateFromTasks(job)
; %#ok Undocumented
%pGetStateFromTasks - determine the state of this job from the task states 
%
%  STATE = PGETSTATEFROMTASKS(JOB)

%  Copyright 2005-2009 The MathWorks, Inc.

%  $Revision: 1.1.10.4 $    $Date: 2009/10/12 17:27:37 $ 

serializer = job.Serializer;
% Don't bother looking at all the tasks unless the job is at least queued -
% if it is pending then all the tasks wil be pending. This does imply that
% State must be set to queued when the job is submitted. Also bail if the
% job says it is finished
jobState = char(serializer.getField(job, 'state'));
state = jobState;

switch state
    case {'pending' 'finished' 'failed'}
        return
end

% We shall try and determine if this job should be treated as queued, 
% running or finished.
try
    % Get the parent of this job and make sure it's an abstract scheduler
    scheduler = job.Parent;
    if ~isa(scheduler, 'distcomp.abstractscheduler')
        return
    end
    % Get a local copy of all the tasks
    tasks = job.Tasks;
    numTasks = numel(tasks);
    % Loop over the tasks in blocks of some size - this is a tweakable
    % param that should make things go faster as we break if we hit
    % anything other than finished.
    BLOCK_SIZE = 30;
    % Start looking from the end - we know that tasks generally get done
    % from the beginning to the end of the task array thus this should
    % quickly fail.
    currentEnd = numTasks;
    % Would like to know if all tasks are finished.
    ALL_FINISHED = true;
    % Loop while there are tasks to check and all have finished
    while currentEnd > 0 
        % Define the beginning of this bock
        currentStart = max(1, currentEnd - BLOCK_SIZE);
        % Get the state of just that block
        blockState = serializer.getFields(tasks(currentStart:currentEnd), {'state'});
        % This is the logic to determine the actual state of the job - the
        % only situation in which we can break early is when 'running' is
        % encountered.
        
        % If any of the tasks currently think they are running then the job
        % is running - no need for furthur checks
        if any(strcmp(blockState, 'running'))
            state = 'running';
            return
        end
        
        % Only if all tasks are finished should the job be finished - note
        % that && short circuits. Note that failed is also a finished state
        ALL_FINISHED = ALL_FINISHED && ...
            all(strcmp(blockState, 'finished') | strcmp(blockState, 'failed'));
        
        % The next block ends just before this one begins
        currentEnd = currentStart - 1;
    end
    % If all tasks are finished then the job is finished otherwise it's
    % queued - any 'running' tasks would have exited early
    if ALL_FINISHED
        state = 'finished';
    else
        state = 'queued';
    end    
catch %#ok<CTCH>
end
