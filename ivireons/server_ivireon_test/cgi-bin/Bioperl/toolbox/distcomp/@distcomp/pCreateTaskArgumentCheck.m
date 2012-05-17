function [taskFcn, numArgsOut, argsIn, setArgs] = pCreateTaskArgumentCheck(job, taskFcn, numArgsOut, argsIn, varargin)
; %#ok Undocumented

%  Copyright 2006-2010 The MathWorks, Inc.

%  $Revision: 1.1.6.4 $    $Date: 2010/03/22 03:41:48 $ 

% Check arguments, but don't use standard nargchk so users don't
% get confused between input/output arguments to createTask and nargin/nargout
% required by their function handle.
parallel.internal.cluster.checkNumberOfArguments('input', 3, inf, nargin, 'createTask');

if nargin < 4
    argsIn = {};
end

% Ensure we haven't been passed a job array
if numel(job) > 1
    error('distcomp:job:InvalidArgument',...
    'The first input to createTask must be a scalar job object, not a vector of job objects');
end

% First check the input arguments
if ~iscell(argsIn) 
    error('distcomp:job:InvalidArgument','InputArguments parameter must be a cell array');
end
% Are all the input arguments also cell arrays? If they are then this is a
% vectorized call and should be treated as such
IS_VECTORIZED = ~isempty(argsIn) && all(cellfun(@iscell, argsIn(:)));
SINGLETON_EXPANSION = true;
% -----------
% Check argsIn
% -----------
% Need different error checking for the 2 different input cases
if IS_VECTORIZED
    if ~all(cellfun(@isvector, argsIn(:)) | cellfun(@isempty, argsIn(:)))
        error('distcomp:job:InvalidArgument','InputArguments parameter must be a cell array of vector cell arrays, or a vector cell array');
    end
else
    if ~(isvector(argsIn) || isempty(argsIn))
        error('distcomp:job:InvalidArgument','InputArguments parameter must be a cell array of vector cell arrays, or a vector cell array');
    end
    % Convert to a 1 x 1 cell array
    argsIn = {argsIn};
end
% -----------
% Check taskFcn
% -----------
% Is the task function correctly sized
if ~iscell(taskFcn)
    % Make task function the same size as the argsIn
    taskFcn = repmat({taskFcn}, size(argsIn));
else
    SINGLETON_EXPANSION = false;
    % Need to check that task function is of the correct size
    if ~isequal(size(taskFcn), size(argsIn))
        error('distcomp:job:InvalidArgument', 'Cell array of input functions must be the same size as the cell array of input arguments');
    end
end
% Get class of all input task functions
taskClass = cellfun(@class, taskFcn, 'uniformOutput', false);
if ~all(ismember(taskClass(:), {'function_handle', 'char'}))
    error('distcomp:job:InvalidArgument','Function must be a cell array of function_handle or string');
end
% -----------
% Check numArgsOut
% -----------
if ~isnumeric(numArgsOut) || isempty(numArgsOut)
    error('distcomp:job:InvalidArgument','NumberOfOutputArguments must be a numeric value or vector');
end
if numel(numArgsOut) == 1
    % Expand
    numArgsOut = repmat(numArgsOut, size(argsIn));
else
    SINGLETON_EXPANSION = false;
    % Need to check that numArgsOut is of the correct size
    if ~isequal(size(numArgsOut), size(argsIn))
        error('distcomp:job:InvalidArgument', 'NumberOfOutputArguments must be the same size as the cell array of input arguments');
    end
end
if any(numArgsOut(:) < 0)
    error('distcomp:job:InvalidProperty', 'NumberOfOutputArguments must be a non-negative value');
end

setArgs = varargin;