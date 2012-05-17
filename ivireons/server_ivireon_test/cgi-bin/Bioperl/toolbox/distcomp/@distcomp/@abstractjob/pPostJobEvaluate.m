function pPostJobEvaluate(job)
; %#ok Undocumented
%pPostJobEvaluate
%
%  pPostJobEvaluate(JOB)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:34:14 $ 

% We shall try and determine if this job should be treated as finished.
try
    % Get the parent of this job and make sure it's an abstract scheduler
    scheduler = job.Parent;
    if ~isa(scheduler, 'distcomp.abstractscheduler')
        return
    end
    % Lets try and test to see if we are the last job to execute and set
    % the job to the finished state
    if scheduler.HasSharedFilesystem
        jobStateFromTasks = job.pGetStateFromTasks;        
        % If all the tasks are finished then set the job to finished
        if strcmp(jobStateFromTasks, 'finished')
            job.Serializer.putFields(job, {'state' 'finishtime'}, ...
                {'finished' char(java.util.Date)});            
        end
    end
catch
end