function job = createJob(obj, varargin)
; %#ok Undocumented
%createJob  Create a job object
%
% job = createJob(scheduler) creates a job object at the remote location 
% specified in scheduler. In this case, future modifications to the job 
% object result in a modifying the job at the remote location.
%
% job = createJob(..., 'p1', v1, 'p2', v2, ...) creates a job object with
% the specified property values. If an invalid property name or property 
% value is specified, the object will not be created.
%
% Note that the property value pairs can be in any format supported by the
% set function, i.e., param-value string pairs, structures, and param-value
% cell array pairs.
%
% Example:
%     % Construct a job object.
%     jm = findResource('scheduler', 'name', 'lsf');
%     j = createJob(jm, 'Name', 'testjob');
%     % Add tasks to the job.
%     for i = 1:10
%         createTask(j, 'rand', {10});
%     end
%     % Run the job.
%     submit(j);
%     % Retrieve job results.
%     out = getAllOutputArguments(j);
%     % Display the random matrix.
%     disp(out{1, 1});
%     % Destroy the job.
%     destroy(j);
%
% See also distcomp.job/createTask, distcomp.jobmanager/findJob, distcomp.job/submit

%  Copyright 2005-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.5 $    $Date: 2008/06/24 17:00:49 $ 

% Ensure we haven't been passed an array of schedulers
if numel(obj) > 1
    error('distcomp:scheduler:InvalidArgument',...
    'The first input to createJob must be a scalar scheduler object, not a vector of scheduler objects');
end

% Defer to the private job creator which might be overloaded for
% different schedulers
job = obj.pCreateJob(obj.DefaultJobConstructor, varargin{:});
