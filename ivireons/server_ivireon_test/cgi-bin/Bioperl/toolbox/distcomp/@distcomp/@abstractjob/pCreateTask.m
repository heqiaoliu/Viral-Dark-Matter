function tasks = pCreateTask(job, taskFcns, numArgsOut, argsIn)
; %#ok Undocumented
%pCreateTask private task creation function that can be overloaded 
%
%  TASK = PCREATETASK(JOB, TASKFCN, NUMARGSOUT, ARGSIN)

% Copyright 2005-2006 The MathWorks, Inc.

% How many tasks are we being asked to create
nTasks = numel(taskFcns);
% Get the parent string information from the job
jobLocation = job.pGetEntityLocation;
% Ask the storage to create the relevant task type
proxies = job.Serializer.Storage.createProxies(jobLocation, nTasks);
% Create a wrapper around the new location
tasks = distcomp.createObjectsFromProxies(...
    proxies, job.DefaultTaskConstructor, job, 'norootsearch');
% Loop over the newly created tasks 
for i = 1:nTasks
    % Request the entity initialise the new location
    tasks(i).pInitialiseLocation(proxies(i), taskFcns{i}, numArgsOut(i), argsIn{i});
end
