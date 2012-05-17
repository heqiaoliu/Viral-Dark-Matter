function OKout = waitForState(job, state, timeout)
%waitForState Wait for job object to change state
%
%    waitForState(j) blocks execution in the client session until the job
%    identified by the job object j reaches the 'finished' state. This occurs
%    when all its tasks are finished processing on remote workers.
%    
%    waitForState(j, 'State') blocks execution in the client session until the
%    job object changes state to the value of 'state'. For a job object the
%    valid states are 'queued', 'running' and 'finished'.
%    
%    OK = waitForState(j, 'State', timeout) blocks execution until timeout
%    seconds elapse or the job reaches the specified 'State', whichever
%    happens first. OK is true if state has been reached or false in case
%    of a timeout.
%    
%    If a job has previously been in state 'State', then waitForState will
%    return immediately. For example, if a job in the 'finished' state is asked
%    to waitForState(job, 'queued'), then the call will return immediately.
%    
%    Example:
%    % Create a job object.
%    jm = findResource('scheduler', 'type', 'jobmanager', ...
%                          'LookupURL', 'JobMgrHost');
%    j = createJob(jm);
%    % Add a task object that generates a 10x10 random matrix.
%    t = createTask(j, @rand, 1, {10,10});
%    % Run the job.
%    submit(j);
%    % Wait until the job is finished.
%    waitForState(j, 'finished');
%    
%    See also distcomp.task/waitForState uiwait waitfor

% Copyright 1984-2008 The MathWorks, Inc.

% $Revision: 1.1.8.8 $  $Date: 2008/11/04 21:15:29 $

% Ensure that only one job has been passed in
if numel(job) > 1
    error('distcomp:job:InvalidArgument', 'The function waitForState requires a single job input');
end

% This allows us to use the WorkUnit.*_STATE variables below which are defined
% in this Class
import com.mathworks.toolbox.distcomp.workunit.WorkUnit;

% Get the defined execution states
type = findtype('distcomp.jobexecutionstate');
Values = type.Values;
Strings = type.Strings;

if nargin < 2
    state = Strings{WorkUnit.FINISHED_STATE == Values};
elseif ~ischar(state)
    error('distcomp:job:InvalidArgument', 'The state input to waitForState must be a string');
end

if nargin < 3
    timeout = Inf;
elseif ~isnumeric(timeout) || ~isscalar(timeout) || timeout < 0
    error('distcomp:job:InvalidArgument', 'The timeout value must be a non-negative scalar double');
end

switch state
    case Strings{WorkUnit.QUEUED_STATE == Values}
        eventName = 'PostQueue';
    case Strings{WorkUnit.RUNNING_STATE == Values}
        eventName = 'PostRun';
    case Strings{WorkUnit.FINISHED_STATE == Values}
        eventName = 'PostFinish';
    otherwise
        error('distcomp:job:InvalidArgument', ...
            ['The state input to waitForState must be one of '''...
            Strings{WorkUnit.QUEUED_STATE == Values} ...
            ''', ''' ...
            Strings{WorkUnit.RUNNING_STATE == Values} ...
            ''' or ''' ...
            Strings{WorkUnit.FINISHED_STATE == Values} ...
            '''']);
end

try
    % Remember that events are not always attached
    job.pRegisterForEvents;
    try
        % Lets check if we have already reached or gone beyond the requested state
        currentIndex = find(strcmp(job.State, Strings));
        desiredIndex = find(strcmp(state, Strings));
        % We assume that the evolution of state is defined by the order of strings
        % in the enum type
        if currentIndex < desiredIndex
            % Instantiate a lock on eventName - This will start listening for eventName
            % from here on
            lock = distcomp.eventwaiter(handle.listener(job, eventName, ''));
            % Wait on the lock - note this might throw a CTRL-C
            OK = lock.waitForEvent(timeout);
            % Explicit delete otherwise the listener above gets left behind in the waitfor
            delete(lock);
        else
            OK = true;
        end
    catch err
        % ALWAYS detach from the event adaptor
        job.pUnregisterForEvents;
        rethrow(err);
    end
    % Detach from the event adaptor
    job.pUnregisterForEvents;
catch err
    % The job object might become invalid during the waitForEvent. Only
    % bother with errors if the job is still valid
    if ishandle(job)
        rethrow(err);
    end
end
% Only return a value if asked to allow waitForState(j) to not have ans
if nargout > 0
    OKout = OK;
end
