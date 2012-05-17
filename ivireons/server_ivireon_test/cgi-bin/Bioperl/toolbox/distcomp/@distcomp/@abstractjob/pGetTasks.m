function val = pGetTasks(job, val)
; %#ok Undocumented
%pGetTasks 
%
%  VAL = pGetTasks(JOB, VAL)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:34:11 $ 

serializer = job.Serializer;

if ~isempty(serializer)
    try
        % Get the parent string information from the object
        jobLocation = job.pGetEntityLocation;
        % Find proxies for objects parented by scheduler location
        proxies = job.Serializer.Storage.findProxies(jobLocation);
        % Create a wrapper around the new location
        val = distcomp.createObjectsFromProxies(...
            proxies, job.DefaultTaskConstructor, job, 'rootsearch');
    catch
        %TODO
    end
end