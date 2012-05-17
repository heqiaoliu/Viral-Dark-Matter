function destroy(tasks)
%destroy  Remove a task object from its job and memory
%
%    destroy(t) removes the task object, t, from the local session, and removes
%    the task from the job manager memory or from your scheduler's
%    DataLocation. When the task is destroyed, any references to it become
%    invalid. An invalid object should be removed from the workspace with the
%    CLEAR command.
%    
%    If multiple references to an object exist in the workspace, destroying
%    one reference to that object invalidates the remaining references to it.
%    These remaining references should be cleared from the workspace with the
%    CLEAR command.
%    
%    Because its data is lost when you destroy an object, destroy should be
%    used after output data has been retrieved from a task object.
%    
%    Example:
%    % Create job and task objects.
%    jm = findResource('scheduler', 'type', 'jobmanager', ...
%                      'LookupURL', 'JobMgrHost');
%    j = createJob(jm, 'Name', 'myjob');
%    t = createTask(j, @rand, 1, {10});
%    % Destroy the task object.
%    destroy(t);
%    clear t
%    
%    See also distcomp.job/createTask, distcomp.job/destroy

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2008/05/05 21:36:46 $ 

% Need the root to remove things from the hashtable
root = distcomp.getdistcompobjectroot;
% Get the proxies that we should remove from the root hashtable
try
    uuids = pReturnUUID(tasks);
catch err %#ok<NASGU>
    uuids = [];
end

for i = 1:numel(tasks)
    % Defaults to also deleting this object
    DO_DELETE_UDD = true;
    try
        % First delete the TaskProxy object - This might throw
        % RemoteException, TaskNotFoundException,
        % JobNotFoundException, JobStateException.
        % Would like to catch JobStateException and not delete the UDD object
        % if that occurs
        tasks(i).ProxyObject.destroy(tasks(i).UUID);
    catch err
        err = distcomp.handleJavaException(tasks(i), err);
        % if the task wasn't found, then delete the UDD object, and
        % don't error; otherwise rethrow the error
        if ~(strcmp(err.identifier, 'distcomp:task:NotFound') || ...
             strcmp(err.identifier, 'distcomp:job:NotFound'))
            throw(err);
        end
    end

    if DO_DELETE_UDD
        delete(tasks(i));
    end
end
% Clean up the hashtable after deleteing all the tasks
root.removeObjectFromHashtable(uuids);
