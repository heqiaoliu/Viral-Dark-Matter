function job = createMatlabPoolJob(jm, varargin)
%createMatlabPoolJob Create a parallel job object
%
%    job = createMatlabPoolJob(scheduler) creates a MatlabPool job object at the
%    the data location for the identified scheduler, or in the job
%    manager. Future modifications to the job object result in a remote call
%    to the job manager or modification to data at the scheduler's data
%    location.
%    
%    job = createMatlabPoolJob(..., 'p1', v1, 'p2', v2, ...) creates a MatlabPool
%    job object with the specified property values. If an invalid property
%    name or property value is specified, the object will not be created.
%    
%    job = createMatlabPoolJob(..., 'configuration', 'ConfigurationName',...)
%    creates a MatlabPool job object with the property values specified in the
%    configuration ConfigurationName. 
%    
%    Example:
%    % Construct a MatlabPool job object.
%    jm = findResource('scheduler', 'type', 'jobmanager', ...
%                      'LookupURL', 'JobMgrHost');
%    j = createMatlabPoolJob(jm, 'Name', 'testMatlabPooljob');
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
%    See also distcomp.jobmanager/createJob

% Copyright 2007 The MathWorks, Inc.

% $Revision: 1.1.6.3 $    $Date: 2008/06/24 17:01:25 $

% Ensure we haven't been passed a jobmanager array
if numel(jm) > 1
    error('distcomp:jobmanager:InvalidArgument',...
    'The first input to createJob must be a scalar jobmanager object, not a vector of jobmanager objects');
end

job = jm.pCreateJob(com.mathworks.toolbox.distcomp.workunit.JobMLType.MATLABPOOL_JOB, varargin{:});
