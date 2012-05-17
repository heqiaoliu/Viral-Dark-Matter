function varargout = dfeval(dfcn, varargin)
%DFEVAL  Distributed FEVAL
%   [y1,..,yn] = DFEVAL(F,x1,...,xn, pv1,...pvn) is used to do the
%   equivalent of an FEVAL except in a cluster of machines using the
%   Parallel Computing Toolbox.  DFEVAL evaluates the function specified
%   by a function handle or function name, F, at the given arguments,
%   x1,...,xn. F may be either a function handle, a function name or a cell
%   array of function handles / function names where the length of the cell
%   array is equal to the number of tasks to be executed.  x1,...,xn are
%   the inputs to the function F and are specified as cell arrays where the
%   number of elements in the cell array equal the number of tasks to be
%   executed. The size of x1,...,xn must all be the same.The results are
%   returned to y1,..,yn where y1,...yn are column-based cell arrays whose
%   elements correspond to each task which was created.
%
%   For example, y=dfeval(@rand,{1 2 3}) will create 3 tasks which return
%   1x1, 2x2, 3x3 random matrices.  Equivalently, y=dfeval(@rand,{2 2},{1 2})
%   will create 2 tasks which return random matrices of size 2x1 and 2x2.
%   Finally, the command y=dfeval({@rand @zeros},{2 2},{1 2}) would create
%   two tasks where the first tasks creates a 2x1 random array and the
%   second task creates a 2x2 array of zeros.
%
%   Additional arguments may also be passed to this function for
%   configuring different properties associated with the job.  These
%   additional arguments are specified as y=dfeval( ..., P1, V1,
%   ..., Pn, Vn) where valid properties and property values are:
%
%    - Distributed Computing Job Object property value pairs specified as
%      string pairs or structures.
%    - 'JobManager' - Value is equal to the name of the job manager to be
%      used.
%    - 'LookupURL' - Value is 'host:port' as defined by the findResource
%      command
%    - 'StopOnError' - true| {false} - If true, any error that occurs
%      during execution in the cluster will cause the job to stop executing.
%      The default value is 'false' which means that any errors that occur
%      will produce a warning but will not stop function execution.
%    - 'Configuration' - Value is the name of a configuration that will be
%      used when creating the scheduler, job and task objects. See the
%      "Programming with User Configurations" section in the documentation.
%
%   Please note that there are limitations that apply when you are using dfeval:
%
%    - You can pass property values to the job object; but you cannot set any 
%      task-specific properties, including callback functions, unless you use 
%      configurations.
%    - All the tasks in the job must have the same number of input arguments.
%    - All the tasks in the job must have the same number of output arguments.
%    - If you are using a third-party scheduler instead of the job manager, you
%      must use configurations in your call to DFEVAL. See Programming with User 
%      Configurations in the Parallel Computing Toolbox documentation.
%    - You do not have direct access to the job manager, job, or task objects, 
%      i.e., there are no objects in your MATLAB workspace to manipulate (though 
%      you can get them using FINDRESOURCE and the properties of the scheduler
%      object). Note that DFEVALASYNC returns a job object.
%    - Without access to the objects and their properties, you do not have control
%      over the handling of errors, except via the 'StopOnError' flag
%
%   For example:
%       y = dfeval(@rand, {3, 3, 3}, 'Configuration', 'myconfig')
%       creates three random matrices of size 3x3 using the scheduler identified
%       by the configuration 'myconfig'.
%
%
%       y = dfeval(@rand,{3 3 3}, ...
%            'JobManager','MyJobManager','Timeout',10,'StopOnError',true);
%       creates three random matrices of size 3x3 using MyJobManager to
%       execute tasks where the tasks timout after 10 seconds and the
%       function will stop if an error occurs while any of the tasks are
%       executing.
%
%       [x, y] = dfeval(@myFunction, {1 2 3 4}, {5 6 7 8}, ...
%           'JobManager','MyJobManager', ...
%           'FileDependencies', {'myFunction', 'myOtherFunction'});
%       calls the function myFunction four times on the cluster managed by
%       MyJobManager. The input arguments to each task evaluating myFunction
%       are 1 and 5 for one worker, 2 and 6 for another, etc.
%
%       As the function myFunction is evaluated, it calls the function
%       myOtherFunction.  Because the MATLAB code for both of these
%       functions is required, both MATLAB files are included in the job's
%       FileDependencies property so that they are passed from the local
%       (client) machine to the cluster nodes that perform the evaluations.
%
%
%   See also FEVAL, DFEVALASYNC.

%   Copyright 2004-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.8 $  $Date: 2010/05/10 17:02:59 $


%% Check arguments, but don't use standard nargchk/nargoutchk so users don't
% get confused between input/output arguments to dfeval and nargin/nargout
% required by their function handle.  Use the detailed message option for
% checkNumberOfArguments.
parallel.internal.cluster.checkNumberOfArguments('output', 1, inf, nargout, mfilename, true);
parallel.internal.cluster.checkNumberOfArguments('input', 2, inf, nargin, mfilename, true);

%% Create, submit and return
jobObj = dfevalasync(dfcn,nargout,varargin{:});

waitForState(jobObj,'finished');
data = getAllOutputArguments(jobObj);

errorMessages = get(jobObj.Tasks, {'ErrorMessage'});
% Retain only the non-empty error messages, if any.
errorMessages = errorMessages(~cellfun(@isempty, errorMessages));

if ~isempty(errorMessages)
    % Indent the task error so that is visually separated from the error
    % we are throwing here.
    indMsg = regexprep(errorMessages{1}, '^(.)', '    $1', 'lineanchors');
    error('distcomp:dfeval:TaskErrored', ...
        ['Job %d encountered the following error:\n%s\n', ...
        'Data must be manually retrieved from the job, \n', ...
        'and it also needs to be manually destroyed.'], ...
        get(jobObj,'ID'), indMsg);
end

if size(data,2) < nargout
    % We only reach this situation in corner cases such as when the task
    % function throws errors with empty error messages.
    error('distcomp:dfeval:TooManyOutputArgs', ...
        ['Requested number of output arguments is greater than the number\n' ...
        'of output arguments returned by the tasks.  Data must be manually\n' ...
        'retrieved from job %d.\n', ...
        'The job also needs to be manually destroyed.'], get(jobObj,'ID'));
end

% The data comes back in a NxM array and it needs to be reformatted
% into M Nx1 outputs.
varargout = cell(1, nargout);
for i = 1:nargout
    varargout{i} = data(:, i);
end

% No error messages, and we were able to retrieve all the data that the
% user asked for, so we destroy the job.
[~, undoc] = pctconfig();
if ~undoc.preservejobs
    jobObj.destroy;
end
