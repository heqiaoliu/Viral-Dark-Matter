function val = pGetJobs(scheduler, val)
; %#ok Undocumented
%PGETJOBS A short description of the function
%
%  VAL = PGETJOBS(SCHEDULER, VAL)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:35:00 $ 

try
    % Get the parent string information from the object
    schedulerLocation = scheduler.pGetEntityLocation;
    % Find proxies for objects parented by scheduler location
    [proxies, constructors] = scheduler.Storage.findProxies(schedulerLocation);
    % Read the requested constructor from the locations
    % Create a wrapper around the new location
    val = distcomp.createObjectsFromProxies(...
        proxies, constructors, scheduler, 'rootsearch');
catch
    % TODO
end
