function varargout = findTask(jobs, varargin)
; %#ok Undocumented
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

% Copyright 2005-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.5 $    $Date: 2008/05/05 21:35:35 $


% Always have at least one output argument
varargout = cell(max(nargout, 1), 1);
if nargout < 2
    for i = 1:numel(jobs)        
        varargout{1} = [varargout{1} ; jobs(i).Tasks];
    end
elseif nargout == 3
    for i = numel(jobs):-1:1
        [p{i}, r{i}, f{i}] = iGetTasksByState(jobs(i));
    end
    varargout{1} = vertcat(p{:});
    varargout{2} = vertcat(r{:});
    varargout{3} = vertcat(f{:});
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
    rethrow(err);
end

end

%--------------------------------------------------------------------------
% Internal function to get tasks in a particular state
%--------------------------------------------------------------------------
function [p, r, f] = iGetTasksByState(job)
% Get the job execution state enumeration
enum = findtype('distcomp.taskexecutionstate');
% Get all the tasks from this job
tasks = job.Tasks;
% Get the states of all the tasks
states = job.Serializer.getFields(tasks, {'state'});
% Convert the states to indices into the enum array of Strings
[found, index] = ismember(states, enum.Strings);
% Check that all the states were valid
if ~all(found)
    % Should never get here
    warning('distcomp:job:InvalidState', 'A task with an unknown state has been detected');
end

statesToFind = {'finished' 'running' 'pending'};
indices = cell(size(statesToFind));

for i = 1:numel(statesToFind)
    % Where in the list is this state
    thisStatesIndex = find(strcmp(enum.Strings, statesToFind{i}));
    % Find all that are at least finished
    indexForThisState = find(index >= thisStatesIndex);
    % Remove these from the list
    index(indexForThisState) = 0;
    % Store in the output
    indices{i} = indexForThisState;
end

p = tasks(indices{3});
r = tasks(indices{2});
f = tasks(indices{1});

end

