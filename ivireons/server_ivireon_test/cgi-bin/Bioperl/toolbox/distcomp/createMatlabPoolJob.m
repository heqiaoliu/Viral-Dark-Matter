function job = createMatlabPoolJob(varargin)
%createMatlabPoolJob Create matlabpool job
%
%    job = createMatlabPoolJob() creates a MatlabPool job using the scheduler 
%    identified by the default parallel configuration.
%    
%    job = createMatlabPoolJob('p1', v1, 'p2', v2, ...) creates a MatlabPool
%    job with the specified property values. If an invalid property
%    name or property value is specified, the object is not created.
%    These values will override any values in the default configuration
%    
%    job = createMatlabPoolJob(..., 'configuration', 'ConfigurationName',...)
%    creates a MatlabPool job using the scheduler identified by the configuration 
%    and sets the property values of the job as specified in that
%    configuration.  
%    
%    Example:
%    % Construct a MatlabPool job object.
%    j = createMatlabPoolJob('Name', 'testMatlabPooljob');
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

% Copyright 2007 The MathWorks, Inc.

% $Revision: 1.1.6.2 $    $Date: 2007/12/10 21:27:40 $

try 
    job = generalCreateJob(@createMatlabPoolJob, varargin);
catch exception
    throw(exception);
end
