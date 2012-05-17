function destroy(tasks)
; %#ok Undocumented
%destroy  Remove a task object from its scheduler
%
% destroy(t) removes the task object, t from the local session, and removes
% the task from the storage location. When the task is destroyed, it becomes
% an invalid object. An invalid object should be removed from the workspace
% with the clear command.
%
% If multiple references to an object exist in the workspace, destroying 
% one reference to that object invalidates the remaining references to it.
% These remaining references should be cleared from the workspace with the
% clear command.
%
% If t is an array of task objects and one of the objects cannot be
% destroyed, the remaining objects in the array will be destroyed and a
% warning will be returned.
%
% Example:
%     jm = findResource('jobmanager');
%     j = createJob(jm, 'Name', 'myjob');
%     t = createTask(j, @rand, {10});
%     destroy(t);
%     clear j t
%
% See also distcomp.jobmanager/createJob, distcomp.task/destroy

%  Copyright 2005-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.5 $    $Date: 2008/05/05 21:35:46 $ 

% Need the root to remove things from the hashtable
root = distcomp.getdistcompobjectroot;
% Get the proxies that we should remove from the root hashtable
try
    uuids = pReturnUUID(tasks);
catch exception %#ok<NASGU>
    uuids = [];
end

for i = 1:numel(tasks)
    thisTask = tasks(i);
    % Defaults to also deleting this object - there may be some error conditions 
    % under which we wish to preserve the local udd object.
    DO_DELETE_UDD = true;
    try
        jobState = thisTask.Parent.State;
        if ~strcmp(jobState, 'pending')
            % Give the scheduler a chance to destroy it's version of the job -
            % but never let this get in the way of actually removing the job
            try
                scheduler = thisTask.pGetManager;
                scheduler.pDestroyTask(thisTask);
            catch err
                warning('distcomp:task:SchedulerError', ...
                    'Unable to cancel task because the scheduler threw an error. Nested error:\n%s', err.message);
            end
        end
        thisTask.Serializer.Storage.destroyLocation(thisTask.pGetEntityLocation);
    catch err
        % TODO
        rethrow(err)
    end

    if DO_DELETE_UDD
        delete(thisTask);
    end
end
% Clean up the hashtable after deleteing all the tasks
root.removeObjectFromHashtable(uuids);
