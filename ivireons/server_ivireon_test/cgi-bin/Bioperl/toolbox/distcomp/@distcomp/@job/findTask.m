function varargout = findTask(jobs, varargin)
%findTask  Find task objects belonging to a job object
%
% tasks = findTask(j) finds all tasks for a job, j and is identical to
% get(j, 'Tasks');
%
% tasks = findTask(j, 'p1', v1, 'p2', v2, ...) gets a 1 x N array of task
% objects belonging to a job object j. The returned task objects will be
% only those having the specified property-value pairs.
%
% [pending, running, finished] = findTask(j) returns the tasks from the job
% object in three output variables, outgrouped by their current state.
%
% Note that the property value pairs can be in any format supported by the
% get function, i.e., param-value string pairs, structures, and param-value
% cell array pairs. If a structure is used, the structure field names are
% object property names and the field values are the requested property
% values.
%
% When a property value is specified, it must use the same format that the
% get function returns. For example, if get returns the Name property value
% as MyTask, then findTask will not find that object while searching for a
% Name property value of mytask as the match is case sensitive.
%
% If j is contained in a remote service, findTask will result in a call to
% the remote service. This could result in findTask taking a long time to
% complete, depending on the number of tasks retrieved and the network
% speed. Also, if the remote service is no longer available, an error will
% be thrown.

% Copyright 2004-2006 The MathWorks, Inc.

% Always have at least one output argument
varargout = cell(max(nargout, 1), 1);
if nargout < 2
    for i = 1:numel(jobs)        
        varargout{1} = [varargout{1} ; jobs(i).Tasks];
    end
elseif nargout == 3
    for i = 1:numel(jobs)
        thisJob = jobs(i);
        tasks = iGetTasksByState(thisJob);
        varargout{1} = [varargout{1} ; tasks{1}];
        varargout{2} = [varargout{2} ; tasks{2}];
        varargout{3} = [varargout{3} ; tasks{3}];
    end
else
    error('distcomp:job:InvalidNumberOfOutputs', 'findTask should be called with 1 or 3 output arguments');
end
try
    for i = 1:numel(varargout)
        if ~isempty(varargout{i})
            % Now use find to subselect this list
            varargout{i} = varargout{i}.find(varargin{:}, '-depth', 0);
        end
    end
catch err
    % TODO - some silly arguments in find?
    throw(err);
end

end

%--------------------------------------------------------------------------
% Internal function to find tasks in a particular state
%--------------------------------------------------------------------------
function tasks = iGetTasksByState(job)
try
    % Get the job execution state enumeration
    enum = findtype('distcomp.taskexecutionstate');
    % Find the state as an integer from the enumeration
    [found, index] = ismember({'pending'  'running' 'finished'}, enum.Strings);
    states = enum.Values(index(found));
    % Initialize the job output cell array
    tasks = cell(numel(states), 1);
    % Get the java tasks from the job - ensure that states is a horizontal
    % vector other wise this will not work
    proxyTasks = job.ProxyObject.getTasks(job.UUID, states);
    % Get for the one job UUID - I think this is working round a bug in the
    % java opaque interface
    proxyTasks = proxyTasks(1);
    % Create the jobs correctly
    for i = 1:numel(proxyTasks)
        % Now try and construct the jobs
        tasks{i} = distcomp.createObjectsFromProxies(proxyTasks(i), @distcomp.task, job);
    end
catch err
    throw(distcomp.handleJavaException(job, err));
end

end
