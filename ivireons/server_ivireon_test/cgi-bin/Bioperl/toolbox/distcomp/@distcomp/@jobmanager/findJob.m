function varargout = findJob(jobmanagers, varargin)
%findJob  Find job objects belonging to a jobmanager object
%
% jobs = findJob(jm) finds all jobs in a jobmanager, jm and is identical to
% get(jm, 'Jobs');
%
% jobs = findJob(jm, 'p1', v1, 'p2', v2, ...) gets a 1 x N array of job
% objects belonging to a jobmanager jm. The returned job objects will be
% only those having the specified property-value pairs.
%
% [pending, queued, running, finished] = findJob(jm) returns the jobs from
% the jobmanager jm in four output variables, grouped by their current state.
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
% See also distcomp.jobmanager/createJob, findResource, distcomp.job/findTask, 
%          distcomp.job/submit

% Copyright 2004-2006 The MathWorks, Inc.

% Always have at least one output argument
varargout = cell(max(nargout, 1), 1);
if nargout < 2
    for i = 1:numel(jobmanagers)        
        varargout{1} = [varargout{1} ; jobmanagers(i).Jobs];
    end
elseif nargout == 4
    for i = 1:numel(jobmanagers)
        thisJm = jobmanagers(i);
        jobs = iGetJobsByState(thisJm);
        varargout{1} = [varargout{1} ; jobs{1}];
        varargout{2} = [varargout{2} ; jobs{2}];
        varargout{3} = [varargout{3} ; jobs{3}];
        varargout{4} = [varargout{4} ; jobs{4}];
    end
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
function jobs = iGetJobsByState(jm)
try
    % Get the job execution state enumeration
    enum = findtype('distcomp.jobexecutionstate');
    % Find the state as an integer from the enumeration
    [found, index] = ismember({'pending' 'queued' 'running' 'finished'}, enum.Strings);
    states = enum.Values(index(found));
    % Initialize the job output cell array
    jobs = cell(numel(states), 1);
    % Get the java tasks from the job
    [proxyJobs, jobTypes] = jm.pGetJobsAndTypesFromProxy(states);
    % Create the jobs correctly
    for i = 1:numel(proxyJobs)
        % Need to get the correct constructor for a job
        constructors = jm.pGetUDDConstructorsForJobTypes(jobTypes{i});
        % Now try and construct the jobs
        jobs{i} = distcomp.createObjectsFromProxies(proxyJobs{i}, constructors, jm);
    end
catch err
    throw(distcomp.handleJavaException(jm, err));
end
end
