function varargout = findJob(schedulers, varargin)
; %#ok Undocumented
%findJob  Find job objects belonging to a scheduler object
%
% jobs = findJob(s) finds all jobs in a scheduler, jm and is identical to
% get(s, 'Jobs');
%
% jobs = findJob(s, 'p1', v1, 'p2', v2, ...) gets a 1 x N array of job
% objects belonging to a scheduler s. The returned job objects will be
% only those having the specified property-value pairs.
%
% [pending, queued, running, finished] = findJob(s) returns the jobs from
% the scheduler s in four output variables, grouped by their current state.
%
% Note that the property value pairs can be in any format supported by the
% get function, i.e., param-value string pairs, structures, and param-value
% cell array pairs. If a structure is used, the structure field names are
% object property names and the field values are the requested property
% values.
%
% When a property value is specified, it must use the same format that the
% get function returns. For example, if get returns the Name property value
% as MyJob, then findJob will not find that object while searching for a
% Name property value of myjob as the match is case sensitive.
%
% If j is contained in a remote service, findJob will result in a call to
% the remote service. This could result in findJob taking a long time to
% complete, depending on the number of tasks retrieved and the network
% speed. Also, if the remote service is no longer available, an error will
% be thrown.
%
% See also distcomp.genericscheduler/createJob, findResource, distcomp.job/findTask,
%          distcomp.job/submit

% Copyright 2005-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.5 $    $Date: 2008/05/05 21:35:44 $

% Always have at least one output argument
varargout = cell(max(nargout, 1), 1);
if nargout < 2
    for i = 1:numel(schedulers)
        varargout{1} = [varargout{1} ; schedulers(i).Jobs];
    end
elseif nargout == 4
    for i = numel(schedulers):-1:1
        [p{i}, q{i}, r{i}, f{i}] = iGetJobsByState(schedulers(i));
    end
    varargout{1} = vertcat(p{:});
    varargout{2} = vertcat(q{:});
    varargout{3} = vertcat(r{:});
    varargout{4} = vertcat(f{:});
else
    error('distcomp:jobmanager:InvalidNumberOfOutputs', 'FindJob should be called with 1 or 4 output arguments');
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
% Internal function to find jobs in a particular state
%--------------------------------------------------------------------------
function [p, q, r, f] = iGetJobsByState(scheduler)
% Get the job execution state enumeration
enum = findtype('distcomp.jobexecutionstate');
% Get all the jobs from this scheduler
jobs = scheduler.Jobs;
% Get the states of all the jobs
states = get(jobs, {'State'});
% Convert the states to indices into the enum array of Strings
[found, index] = ismember(states, enum.Strings);
% Check that all the states were valid
if ~all(found)
    % Should never get here
    warning('distcomp:abstractscheduler:InvalidState', 'A job with an unknown state has been detected');
end

statesToFind = {'finished' 'running' 'queued' 'pending'};
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

p = jobs(indices{4});
q = jobs(indices{3});
r = jobs(indices{2});
f = jobs(indices{1});

end

