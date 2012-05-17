function job = createParallelJob(varargin)
%createParallelJob  Create parallel job
%
%    job = createParallelJob() creates a parallel job using the scheduler 
%    identified by the default parallel configuration and sets the property 
%    values of the job as specified in the default configuration.
%    
%    job = createParallelJob('p1', v1, 'p2', v2, ...) creates a parallel
%    job with the specified property values. If an invalid property
%    name or property value is specified, the object is not created.
%    These values will override any values in the default configuration
%    
%    job = createParallelJob(..., 'configuration', 'ConfigurationName',...)
%    creates a parallel job using the scheduler identified by the configuration 
%    and sets the property values of the job as specified in that
%    configuration. 
%    
%    Example:
%    % Construct a parallel job object with a specific name.
%    j = createParallelJob('Name', 'testparalleljob');
%    % Add the task to the job.
%    createTask(j, @labindex, 1, {});
%    % Set the number of workers required for parallel execution.
%    j.MinimumNumberOfWorkers = 5;
%    j.MaximumNumberOfWorkers = 10;
%    % Run the job.
%    submit(j);
%    % Wait until the job is finished.
%    waitForState(j, 'finished');
%    % Retrieve job results.
%    out = getAllOutputArguments(j);
%    % Display the output.
%    celldisp(out);
%    % Destroy the job.
%    destroy(j);
%    
%    See also distcomp.jobmanager/createJob, defaultParallelConfig

%  Copyright 2007 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2007/11/09 19:49:09 $ 

try 
    job = generalCreateJob(@createParallelJob, varargin);
catch exception
    throw(exception);
end