function task = pCreateTask(job, taskFcns, numArgsOut, argsIn)
; %#ok Undocumented
%pCreateTask private task creation function that can be overloaded 
%
%  TASK = PCREATETASK(JOB, TASKFCN, NUMARGSOUT, ARGSIN)

% Copyright 2005-2006 The MathWorks, Inc.
    
if isempty( job.Tasks ) && numel(taskFcns) == 1
   % OK
else
   error( 'distcomp:job:InvalidJobState', ...
          'When setting up a parallel job, only 1 task is allowed' );
end

% Get the parent string information from the job
jobLocation = job.pGetEntityLocation;
% Ask the storage to create the relevant task type
proxy = job.Serializer.Storage.createProxies(jobLocation, 1);
% Create a wrapper around the new location
task = distcomp.createObjectsFromProxies(...
    proxy, job.DefaultTaskConstructor, job, 'norootsearch');
% Request the entity initialise the new location
task.pInitialiseLocation(proxy, taskFcns{1}, numArgsOut(1), argsIn{1});