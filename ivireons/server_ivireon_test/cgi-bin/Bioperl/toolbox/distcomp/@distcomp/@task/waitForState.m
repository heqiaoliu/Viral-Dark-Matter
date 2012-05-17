function OKout = waitForState(task, state, timeout)
%waitForState Wait for task object to change state
%
%    waitForState(t) blocks execution in the client session until the task
%    identified by the task object t reaches the 'finished' state.  This occurs
%    when the task is finished processing on a remote worker.
%
%    waitForState(t, 'State') blocks execution in the client session until the
%    task object changes state to the value of 'state'. For a task object the
%    valid states are 'running' and 'finished'.
%
%    OK = waitForState(t, 'State', TIMEOUT) blocks execution until TIMEOUT
%    seconds elapse or the task reaches the specified 'State', whichever
%    happens first. OK is true if state has been reached or false in case
%    of a timeout.
%
%    If a task has previously been in state 'State' then waitForState will
%    return immediately. For example if a task in the 'finished' state is asked
%    to waitForState(task, 'running'), then the call will return immediately.
%
%    Example:
%    % Create a job object.
%    jm = findResource('scheduler', 'type', 'jobmanager', ...
%                      'LookupURL', 'JobMgrHost');
%    j = createJob(jm);
%    % Add a task object that generates a 10x10 random matrix.
%    t = createTask(j, @rand, 1, {10,10});
%    % Run the job.
%    submit(j);
%    % Wait until the task is finished.
%    waitForState(t, 'finished');
%
%    See also distcomp.job/waitForState uiwait waitfor

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2008/11/04 21:16:09 $

% Ensure that only one task has been passed in
if numel(task) > 1
    error('distcomp:task:InvalidArgument', 'The function waitForState requires a single task input');
end

% This allows us to use the WorkUnit.*_STATE variables below which are defined
% in this Class
import com.mathworks.toolbox.distcomp.workunit.WorkUnit;

% Get the defined execution states
type = findtype('distcomp.taskexecutionstate');
Values = type.Values;
Strings = type.Strings;

if nargin < 2
    state = Strings{WorkUnit.FINISHED_STATE == Values};
elseif ~ischar(state)
    error('distcomp:task:InvalidArgument', 'The state input to waitForState must be a string');
end

if nargin < 3
    timeout = Inf;
elseif ~isnumeric(timeout) || ~isscalar(timeout) || timeout < 0
    error('distcomp:task:InvalidArgument', 'The timeout value must be a non-negative scalar double');
end

switch state
    case Strings{WorkUnit.RUNNING_STATE == Values}
        eventName = 'PostRun';
    case Strings{WorkUnit.FINISHED_STATE == Values}
        eventName = 'PostFinish';
    otherwise
        error('distcomp:task:InvalidArgument',...
            ['The state input to waitForState must be one of '''...
            Strings{WorkUnit.RUNNING_STATE == Values} ...
            ''' or ''' ...
            Strings{WorkUnit.FINISHED_STATE == Values} ...
            '''']);
end

try
    % Remember that events are not always attached
    task.pRegisterForEvents;
    try
        % Lets check if we have already reached or gone beyond the requested state
        currentIndex = find(strcmp(task.State, Strings));
        desiredIndex = find(strcmp(state, Strings));
        % We assume that the evolution of state is defined by the order of strings
        % in the enum type
        if currentIndex < desiredIndex
            % Instantiate a lock on eventName - This will start listening for eventName
            % from here on
            lock = distcomp.eventwaiter(handle.listener(task, eventName, ''));
            % Wait on the lock - note this might throw a CTRL-C
            OK = lock.waitForEvent(timeout);
            % Explicit delete otherwise the listener above gets left behind in the waitfor
            delete(lock);
        else
            OK = true;
        end
    catch err
        % ALWAYS detach from the event adaptor
        task.pUnregisterForEvents;
        rethrow(err);
    end
    % Detach from the event adaptor
    task.pUnregisterForEvents;
catch err
    % The task object might become invalid during the waitForEvent. Only
    % bother with errors if the task is still valid
    if ishandle(task)
        rethrow(err);
    end
end
% Only return a value if asked to allow waitForState(j) to not have ans
if nargout > 0
    OKout = OK;
end
