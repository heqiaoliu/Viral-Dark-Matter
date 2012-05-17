function job = createMatlabPoolJob(obj, varargin)
%createMatlabPoolJob Create a Matlab pool job object
%
%   job = createMatlabPoolJob(scheduler) creates a MatlabPool job at the
%   remote location specified in the scheduler. In this case, future
%   modifications to the job object result in a modifying the job at the
%   remote location.
%
%   job = createMatlabPoolJob(..., 'p1', v1, 'p2', v2, ...) creates a job
%   object with the specified property values. If an invalid property name
%   or property value is specified, the object will not be created.
%
%   Note that the property value pairs can be in any format supported by
%   the set function, i.e., param-value string pairs, structures, and
%   param-value cell array pairs.
%
%   When creating a pool job, it is only possible to add one task.
%   
%   Example:
%   % construct a job object
%   jm = findResource( 'scheduler', 'configuration', defaultParallelConfig );
%   j = createMatlabPoolJob( jm, 'Name', 'BatchTest' );
%   % Set the maximum number of workers for the job
%   j.MaximumNumberOfWorkers = 8;
%   % add 1 task to the job
%   createTask( j, @labindex, 1, {} );
%   % Run the job
%   submit( j );
%   % Retrieve the results
%   out = getAllOutputArguments( j )
%
%   See also distcomp.job/createTask

% Copyright 2007-2008 The MathWorks, Inc.

% $Revision: 1.1.6.3 $    $Date: 2008/06/24 17:00:50 $ 

% Ensure we haven't been passed an array of schedulers
if numel(obj) > 1
    error('distcomp:scheduler:InvalidArgument',...
          ['The first input to createJob must be a scalar scheduler ' ...
           'object, not a vector of scheduler objects']);
end


job = obj.pCreateJob(obj.DefaultMatlabPoolJobConstructor, varargin{:});