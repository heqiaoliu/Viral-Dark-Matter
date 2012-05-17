function job = createJob(jm, varargin)
%createJob  Create job object in scheduler and client
%
%    job = createJob(scheduler) creates a job object at the data location
%    for the identified scheduler, or in the job manager.
%    
%    job = createJob(..., 'p1', v1, 'p2', v2, ...) creates a job object with
%    the specified property values. If an invalid property name or property 
%    value is specified, the object will not be created.
%    
%    If you are using a third-party scheduler instead of a job manager,
%    the job's data is stored in the location specified by the scheduler's
%    DataLocation property.
%    
%    job = createJob(..., 'configuration', 'ConfigurationName', ...)
%    creates a job object with the property values specified in the
%    configuration ConfigurationName. 
%
%    Example:
%    % Construct a job object.
%    jm = findResource('scheduler', 'type', 'jobmanager', ...
%                          'LookupURL', 'JobMgrHost');
%    j = createJob(jm, 'Name', 'testjob');
%    % Add tasks to the job.
%    for i = 1:10
%        createTask(j, @rand, 1, {10});
%    end
%    % Run the job.
%    submit(j);
%    % Wait until the job is finished.
%    waitForState(j, 'finished');
%    % Retrieve job results.
%    out = getAllOutputArguments(j);
%    % Display the random matrix.
%    disp(out{1, 1});
%    % Destroy the job.
%    destroy(j);
%
%    See also distcomp.job/createTask, distcomp.jobmanager/findJob, distcomp.job/submit

%  Copyright 2000-2009 The MathWorks, Inc.

%  $Revision: 1.1.8.9 $    $Date: 2009/04/15 22:58:26 $ 

% Ensure we haven't been passed a jobmanager array
if numel(jm) > 1
    error('distcomp:jobmanager:InvalidArgument',...
    'The first input to createJob must be a scalar jobmanager object, not a vector of jobmanager objects');
end

job = jm.pCreateJob(com.mathworks.toolbox.distcomp.workunit.JobMLType.STANDARD_JOB, varargin{:});

