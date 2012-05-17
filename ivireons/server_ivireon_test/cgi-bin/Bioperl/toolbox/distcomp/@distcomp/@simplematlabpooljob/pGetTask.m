function val = pGetTask(job, val)
; %#ok Undocumented
%pGetTask Return a handle to the first task

% Copyright 2007 The MathWorks, Inc.

% $Revision: 1.1.6.1 $    $Date: 2007/10/10 20:41:32 $ 

serializer = job.Serializer;

if ~isempty(serializer)
    try
        % Get the parent string information from the object
        jobLocation = job.pGetEntityLocation;
        % Find proxies for objects parented by scheduler location
        proxies = job.Serializer.Storage.findProxies(jobLocation);
        % Create a wrapper around the new location
        if isempty(proxies)
            val = [];
        else
            val = distcomp.createObjectsFromProxies(...
                proxies(1), job.DefaultTaskConstructor, job, 'rootsearch');
        end
    catch
        %TODO
    end
end
