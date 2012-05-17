function destroy(jobs)
; %#ok Undocumented
%destroy  Remove a job object from its jobmanager
%
% destroy(j) removes the job object, j from the local session, and removes
% the job from the job manager memory. When the job is destroyed, it becomes
% an invalid object. An invalid object should be removed from the workspace
% with the clear command.
%
% If multiple references to an object exist in the workspace, destroying 
% one reference to that object invalidates the remaining references to it.
% These remaining references should be cleared from the workspace with the
% clear command.
%
% The task objects contained in a job will also be destroyed when a job
% object is destroyed. This means that any references to those task objects
% will also be invalid.
%
% If j is an array of job objects and one of the objects cannot be
% destroyed, the remaining objects in the array will be destroyed and a
% warning will be returned.
%
% Example:
%     jm = findResource('jobmanager');
%     j = createJob(jm, 'Name', 'myjob');
%     t = createTask(j, @rand, {10});
%     destroy(j);
%     clear j t
%
% See also distcomp.jobmanager/createJob, distcomp.task/destroy

%  Copyright 2005-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.6 $    $Date: 2008/10/02 18:40:26 $ 

% Need the root to remove things from the hashtable
root = distcomp.getdistcompobjectroot;

for i = 1:numel(jobs)
    thisJob = jobs(i);
    % Defaults to also deleting this object - there may be some error conditions 
    % under which we wish to preserve the local udd object.
    DO_DELETE_UDD = true;
    % Get the proxies that we should remove from the root hashtable
    try
        uuids = pReturnUUID([thisJob ; thisJob.Tasks]);
    catch exception %#ok<NASGU>
        uuids = [];
    end
    try
        % Get the job state - only ask scheduler to do something if it isn't pending
        serializer = thisJob.Serializer;
        % If the data on disk is corrupt this might error
        try
            jobState = serializer.getFields(thisJob, {'state'});
        catch exception %#ok<NASGU>
            jobState = '';
        end
        % Only forward jobs for which we managed to read the state and it
        % isn't pending or finished
        if ~( isempty(jobState) || distcomp.jobStateIsAtOrBefore(jobState, 'pending') )
            % Give the scheduler a chance to destroy it's version of the job -
            % but never let this get in the way of actually removing the job
            try
                scheduler = thisJob.pGetManager;
                scheduler.pDestroyJob(thisJob);
            catch err
                warning('distcomp:job:SchedulerError', ...
                    'Unable to cancel job because the scheduler threw an error. Nested error:\n%s', err.message);                
            end
        end
        serializer.Storage.destroyLocation(thisJob.pGetEntityLocation);
    catch err
        % TODO
        rethrow(err)
    end

    if DO_DELETE_UDD
        delete(thisJob);
        root.removeObjectFromHashtable(uuids);
    end
end
