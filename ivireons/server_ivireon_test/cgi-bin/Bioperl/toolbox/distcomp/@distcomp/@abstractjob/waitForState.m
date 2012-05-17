function OKout = waitForState(job, state, timeout)
; %#ok Undocumented
%waitForState Block execution until a specific job state is reached
%
%   waitForState(J) returns when the distributed job identified by the
%   object J reaches the 'finished' state. This occurs when all the job's
%   tasks are finished processing on remote MATLAB Distributed Computing
%   Servers.
%
%   waitForState(J, 'State'), in addition to the previous syntax, blocks
%   execution until the specified state 'State' is reached. For a job 
%   object the valid states are 'queued', 'running' and 'finished'.
%
%   OK = waitForState(J, 'State', timeout), in addition to the previous
%   syntax, blocks until either timeout seconds elapse or 'State' is
%   reached. OK is true if state has been reached, or false in case of a
%   timeout.
%
%   Note that if a job has previously been in state 'State' then
%   waitForState will return immediately. For example if a job in the
%   'finished' state is asked to waitForState(job, 'queued') then the
%   call will return immediately.
%
% Example:
%   % Create a job object.
%   jm = findResource('jobmanager');
%   j = createJob(jm);
%   % Add a task object that generates a 10x10 random matrix.
%   t = createTask(j, @rand, {10,10});
%   % Run the job.
%   submit(j);
%   % Block MATLAB execution until the job is finished
%   waitForState(j, 'finished');
%
% See also distcomp.task/waitForState uiwait waitfor

% Copyright 2005-2008 The MathWorks, Inc.

% $Revision: 1.1.10.7 $  $Date: 2008/11/04 21:15:14 $

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

allowedStates = { ...
    Strings{WorkUnit.QUEUED_STATE == Values} ...
    Strings{WorkUnit.RUNNING_STATE == Values} ...
    Strings{WorkUnit.FINISHED_STATE == Values} ...
    };

switch state
    case allowedStates
    otherwise
        error('distcomp:job:InvalidArgument', ...
            ['The state input to waitForState must be one of '''...
            allowedStates{1} ...
            ''', ''' ...
            allowedStates{2} ...
            ''' or ''' ...
            allowedStates{3} ...
            '''']);
end

try
    startTime = clock;
    while true
        % Lets check if we have already reached or gone beyond the requested state
        currentIndex = find(strcmp(job.State, Strings));
        desiredIndex = find(strcmp(state, Strings));
        OK = (currentIndex >= desiredIndex);
        if OK || etime(clock, startTime) > timeout
            break
        end
        pause(1);
    end
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
