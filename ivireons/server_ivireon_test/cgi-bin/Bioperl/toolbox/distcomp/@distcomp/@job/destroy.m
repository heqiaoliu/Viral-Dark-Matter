function destroy(job)
%destroy  Remove a job object from its jobmanager and memory
%
%    destroy(j) removes the job object, j, from the local session, and removes
%    the job from the job manager memory or from your scheduler's
%    DataLocation.  When the job is destroyed, any references to it become
%    invalid. An invalid object should be removed from the workspace with the
%    CLEAR command.
%    
%    If multiple references to an object exist in the workspace, destroying 
%    one reference to that object invalidates the remaining references to it.
%    These remaining references should be cleared from the workspace with the
%    CLEAR command.
%    
%    The task objects contained in a job will also be destroyed when a job
%    object is destroyed. Any references to those task objects will also be
%    invalid.
%    
%    If j is an array of job objects and one of the objects cannot be
%    destroyed, the other objects in the array will be destroyed and a
%    warning will be returned.
%    
%    Example:
%    % Create a job object.
%    jm = findResource('scheduler', 'type', 'jobmanager', ...
%                      'LookupURL', 'JobMgrHost');
%    j = createJob(jm, 'Name', 'myjob');
%    t = createTask(j, @rand, 1, {10});
%    % Destroy the job object.
%    destroy(j);
%    clear j t
%    
%    See also distcomp.jobmanager/createJob, distcomp.task/destroy

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.7 $    $Date: 2008/05/05 21:36:12 $ 

% Need the root to remove things from the hashtable
root = distcomp.getdistcompobjectroot;

for i = 1:numel(job)
    % Defaults to also deleting this object - there may be some error conditions 
    % under which we wish to preserve the local udd object.
    DO_DELETE_UDD = true;
    thisJob = job(i);
    % Get the proxies that we should remove from the root hashtable
    try
        uuids = pReturnUUID([thisJob ; thisJob.Tasks]);
    catch err %#ok<NASGU> 
        uuids = [];
    end
    try
        thisJob.ProxyObject.destroy(thisJob.UUID);
    catch err
        err = distcomp.handleJavaException(thisJob, err);
        % if the job wasn't found, then delete the UDD object, and
        % don't error; otherwise rethrow the error
        if ~strcmp(err.identifier, 'distcomp:job:NotFound')
            throw(err);
        end     
    end
    if DO_DELETE_UDD
        delete(thisJob);
        root.removeObjectFromHashtable(uuids);
    end
end
