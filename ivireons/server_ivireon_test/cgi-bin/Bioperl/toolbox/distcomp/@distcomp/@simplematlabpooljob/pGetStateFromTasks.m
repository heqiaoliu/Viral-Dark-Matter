function state = pGetStateFromTasks(job)
; %#ok Undocumented
%pGetStateFromTasks - determine the state of this job from the task states 
%
%  STATE = PGETSTATEFROMTASKS(JOB)

%  Copyright 2009 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2009/10/12 17:27:50 $ 

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
    % For a matlabpool job the state of the job is just the state of the
    % first task    
    state = serializer.getField(job.Tasks(1), 'state');
catch %#ok<CTCH>
end
