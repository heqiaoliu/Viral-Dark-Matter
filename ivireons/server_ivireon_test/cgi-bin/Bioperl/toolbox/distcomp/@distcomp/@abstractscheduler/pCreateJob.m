function job = pCreateJob(scheduler, jobConstructor, varargin)
; %#ok Undocumented
%pCreateJob private job creation function that can be overloaded 
%
%  JOB = PCREATEJOB(SCHEDULER, JOBCONSTRUCTOR, VARARGIN)

% Copyright 2005-2006 The MathWorks, Inc.

try
    % Get the parent string information from the object
    schedulerLocation = scheduler.pGetEntityLocation;
    % Ask the storage to create the relevant job type
    proxy = scheduler.Storage.createProxies(schedulerLocation, 1, jobConstructor);
    % Create a wrapper around the new location
    job = distcomp.createObjectsFromProxies(...
        proxy, jobConstructor, scheduler, 'norootsearch');
catch err
    throwAsCaller(err);
end

try
    % Request the entity initialise the new location
    job.pInitialiseLocation(proxy,  scheduler.ClusterSize);
    % If we have any extra parameters then set them here
    if numel(varargin) > 0
        set(job, varargin{:});
    end
    % Ensure that all construction tasks are completed
    job.pFinalizeConstruction;    
catch err
    % Invalid parameter or value - destroy the job and rethrow the
    % error
    destroy(job);
    throwAsCaller(err);
end