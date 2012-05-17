function out = load(job, varargin)
%LOAD Load workspace variables from batch job.
%   LOAD(JOB) retrieves all variables from a batch job and assigns them 
%   into the current workspace. If the job is not finished, or if the
%   job encountered an error while running then load will throw an
%   error as there is no data available to load.  
%
%   LOAD(JOB, 'X') loads only the variable named X from the job. 
%
%   LOAD(JOB, 'X', 'Y', 'Z')  loads just the specified variables.  The
%   wildcard '*' loads variables that match a pattern (MAT-file only).
%
%   LOAD(JOB, '-REGEXP', 'PAT1', 'PAT2') can be used to load all variables
%   matching the specified patterns using regular expressions. For more
%   information on using regular expressions, type "doc regexp" at the
%   command prompt. 
%
%   S = LOAD(JOB, ...) returns the contents of JOB in variable S. S is a
%   struct containing fields matching the variables retrieved. 
%
%   Examples for pattern matching:
%       load(job, 'a*')                % Load variables starting with "a"
%       load(job, '-regexp', '\d')     % Load variables containing any digits

% Copyright 2007-2010 The MathWorks, Inc.

% $Revision: 1.1.6.5 $  $Date: 2010/04/21 21:14:04 $

% Bail from here if the job is not a batch job
try 
    distcomp.errorIfNotBatchJob(job);
catch exception
    throw(exception)
end

% If load ran anything other than a script, then it is not supported.
% errorIfNotBatchJob has already checked for a single task.
executeScriptFcn = @parallel.internal.cluster.executeScript;
if ~isequal(job.Tasks(1).Function, executeScriptFcn)
    error('distcomp:job:LoadNotSupported', ...
        'Load supports only batch jobs that ran a single script.');
end

% Has the job finished 
jobState = get(job, 'state');
if ~strcmpi(jobState, {'finished' 'failed'})
    error('distcomp:job:InvalidJobState', 'The job is in state %s. To load data from a job it must be finished', jobState);
end

% Did the job fail or the task error
taskError = job.Tasks(1).ErrorMessage;
% Deal first with something going wrong outside user code
if isempty(taskError) && strcmpi(jobState, 'failed')
    error('distcomp:job:ErrorRunningJob',...
        ['The job failed to run correctly but no error message was returned.\n'...
        'This could be because the scheduler failed to start MATLAB correctly on\n'...
        'the cluster, or because the files needed to run the batch job were\n'...
        'unavailable to the MATLAB on the cluster. You may find more information\n'...
        'in the debug log for this job. To find out more about debug logs look at\n'...
        'the getDebugLog function in the documentation.']);
end
% Error occurred in user code and was returned to us
if ~isempty(taskError)
    error('distcomp:job:ErrorRunningJob', ...
        'Error encountered while running the batch job. The error was:\n%s', taskError);
end

workspaceOut = iGetSingleTaskScriptWorkspace(job, varargin{:});
if nargout == 0
    % Get the output variable names
    varNamesOut = fieldnames(workspaceOut);
    % Next populate with the required variables
    for i = 1:numel(varNamesOut)
        assignin('caller', varNamesOut{i}, workspaceOut.(varNamesOut{i}));
    end
else
    out = workspaceOut;
end

% ---------------------------------------------------------------------------------
%
% ---------------------------------------------------------------------------------
function workspaceOut = iGetSingleTaskScriptWorkspace(job, varargin)
% Get the workspace out of a single batch script

% After this we know the job ran successfully - get the first output
% which is the full workspace struct.
workspaceOut = job.Tasks(1).OutputArguments{1};

% Deal with any sub-selection from varargin
if numel(varargin) > 0
    workspaceOut = iSelectVariables(workspaceOut, varargin);
end

% ---------------------------------------------------------------------------------
%
% ---------------------------------------------------------------------------------
function ws = iSelectVariables(ws, args)
% Test that all the inputs we are parsing are strings
isStringFun = @(x) ischar(x) && isvector(x) && size(x, 1) == 1;
if ~all(cellfun(isStringFun, args))
    throwascaller(mexception('distcomp:job:InvalidArgument', 'All inputs to load must be 1 x N strings'));
end
% Three types of args could be passed in -regexp, var* and var.
% We need to partition these. Firstly get all regexp args, which
% will follow an arg of -regexp
regexpIndex = find(strcmp(args, '-regexp'), 1, 'first');
origPatterns = args;
% Did we get a -regexp?
if ~isempty(regexpIndex)
    regexpArgs = args(regexpIndex+1:end);
    args = args(1:regexpIndex-1);
else
    regexpArgs = {};
end
% Remove any invalid strings
valid = ~cellfun('isempty', regexp(args, '^[a-zA-Z\*][a-zA-Z0-9_\*]*$', 'once'));
% Indicate that there are invalid strings
for i = find(~valid)
    warning('distcomp:job:VariablePatternNotFound', 'Variable matching ''%s'' not found', origPatterns{i});
end
% Next, look for anything with a * in it
star = ~cellfun('isempty', regexp(args, '\*', 'once')) & valid;
name  = valid & ~star;
% We end up with 1 set of searchs
% Put ^ at the beginning of the search and $ at the end
nameArgs = regexprep(args(name), '.*', '^$0\$');
% Put ^ at the beginning of the search and $ at the end and replace * with .*
starArgs = regexprep(regexprep(args(star), '\*', '.*'), '.*', '^$0\$');
% Create the complete list of patterns and the original patterns they were
% derived from to print out in error messages
patterns = [nameArgs starArgs regexpArgs];
origPatterns = [origPatterns(name) origPatterns(star) origPatterns(regexpIndex+1:end)];
% Get the field names from the workspace structure
wsNames = fieldnames(ws); 
found = false(numel(wsNames), 1);
% Loop over the patterns looking for variables that fit them
for i = 1:numel(patterns)
    foundThis = ~cellfun('isempty', regexp(wsNames, patterns{i}, 'once'));
    found = found | foundThis;
    if ~any(foundThis)
        warning('distcomp:job:VariablePatternNotFound', 'Variable matching ''%s'' not found', origPatterns{i});
    end
end
% Get the correct variables from the structure
wsVars = struct2cell(ws);
ws = cell2struct(wsVars(found), wsNames(found), 1);

