function schans = pGetSockets(obj, expNlabs)
; %#ok Undocumented
%   Either return a socket, or throw an error. Rewrite the error message in case
%   we throw an error.
%   The parallel job must have been created before calling this method.

%   Copyright 2006-2008 The MathWorks, Inc.

% Loop whilst waiting for the job to connect back. The ServerSocketChannel
% within ConnectionManager is set to not block.
startTime = clock();

count = 0;

while count < expNlabs
    [currChan, nlabs, labidx] = iGetSingleSocket(obj, startTime);
    if count == 0
        schans = javaArray('java.nio.channels.SocketChannel', nlabs);
    end
    schans(labidx) = currChan;
    count = count + 1;
    if ~isfinite(expNlabs)
        expNlabs = nlabs;
    end
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [currChan, nlabs, labidx] = iGetSingleSocket(obj, startTime)
WAITING_FOR_SOCKET = true;
constants = distcomp.getInteractiveConstants;

accepted = [];

lastJobCheckTime = clock;

while WAITING_FOR_SOCKET
    
    accepted           = obj.ConnectionManager.activelyAccept();
    WAITING_FOR_SOCKET = isempty( accepted );
    
    if WAITING_FOR_SOCKET && etime(clock, startTime) > obj.JobStartupTimeout
        iThrowTimeoutError(obj);
    end
    
    allowedToStart = com.mathworks.toolbox.distcomp.pmode.SessionFactory.sAllowedToStart.getAndSet(true);
    if ~allowedToStart
        dctSchedulerMessage(1, 'Interrupting session startup.');
        error('distcomp:interactive:Interrupted', ...
            'Interactive session startup was interrupted.');
    end
    
    if WAITING_FOR_SOCKET
        pause( 0.01 );
    else
        dctSchedulerMessage(2, 'Received a socket connection.');
    end
  
    if etime( clock, lastJobCheckTime ) > constants.serverSocketSoTimeout/1000;
        dctSchedulerMessage(3, 'Checking parallel job status.');
        iThrowIfBadParallelJobStatus(obj);
        lastJobCheckTime = clock;
    end

end % while WAITING_FOR_SOCKET

currChan = accepted.socketChannel;
labidx   = accepted.processInstance.getLabIndex();
nlabs    = accepted.extraInfo;

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function iThrowIfBadParallelJobStatus(obj)
% Throw an error if the parallel job is not running.
jobState = iGetJobState(obj.ParallelJob);
if iIsJobWaitingOrRunning(jobState)
    % Job is still queued or running, so there is nothing for us to do here.
    return;
end
dctSchedulerMessage(1, iGetJobStatusDescription(obj.ParallelJob));
if strcmpi(jobState, 'destroyed')
    error('distcomp:interactive:JobError', ...
          'The interactive parallel job has been destroyed.');
end
if strcmpi(jobState, 'unavailable')
    error('distcomp:interactive:JobError', ...
          ['The interactive parallel job is unavailable.\n', ...
           'Most likely, the parallel job has been destroyed.']);
end
% We now know that the job has completed and that we have a valid job object. 
msg = iGetErrorMessage(obj.ParallelJob);

try
    failed = strcmpi(state, 'failed');
catch err %#ok<NASGU>
    failed = false;
end
if ~isempty(msg)
    error('distcomp:interactive:JobError', ...
          ['The interactive parallel job errored with the following '...
           'message:\n\n%s'], msg);
end
if failed
    error('distcomp:interactive:JobError', ...
          ['The interactive parallel job failed without any ' ...
           'messages.']);
else
    error('distcomp:interactive:JobError', ...
          ['The interactive parallel job finished without any ' ...
           'messages.']);
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function iThrowTimeoutError(obj)
% Throw an error due to timeout exceeded.
try
    running = strcmpi(obj.ParallelJob.State, 'running');
catch err %#ok<NASGU>
    running = false;
end
if running
    error('distcomp:interactive:TimeoutExceeded', ...
          ['The labs did not connect to the client within the allowed time ' ...
           'of %d seconds.\n'], ...
          obj.JobStartupTimeout);
else
    error('distcomp:interactive:TimeoutExceeded', ...
          ['The parallel job did not start within the allowed time ' ...
           'of %d seconds.\n'], ...
          obj.JobStartupTimeout);
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function waitingOrRunning = iIsJobWaitingOrRunning(jobState)
% Check if the job has finished - if so something has gone wrong.
waitingOrRunning = any(strcmpi(jobState, {'running' 'queued'}));

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function msg = iGetErrorMessage(pjob)
% Return the error message of the task causing the job to fail.  
% Never throw an error.
try
    msgs = get(pjob.Tasks, {'ErrorMessage'}); % Always returns a cell array.
    % The task that caused the job to failed is the one that should
    % not start with the string secondaryFailureMsg.  We also exclude empty
    % error messages.
    secondaryFailureMsg = 'The parallel job was cancelled because the task';
    realCause = cellfun(@isempty, regexp(msgs, secondaryFailureMsg)) ...
        & ~cellfun(@isempty, msgs);
    % If all is well, realCause is not empty.
    if any(realCause)
        msg = msgs{find(realCause, 1, 'first')};
    else
        % Our analysis failed, so just use the first non-empty error message
        % instead.
        msg = msgs{find(~cellfun(@isempty, msgs), 1, 'first')};
    end
catch err %#ok<NASGU>
    msg = '';
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function jobState = iGetJobState(pjob)
try
    jobState = pjob.State;
catch err %#ok<NASGU>
    jobState = 'unavailable';
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function msg = iGetJobStatusDescription(pjob)
try
    state = pjob.State;
    stateMsg = sprintf('Job state is ''%s''', state);
catch err %#ok<NASGU>
    stateMsg = 'Could not retrieve the job state.';
end
try 
    msgs = get(pjob.Tasks, {'ErrorMessage'});
    ind = ~cellfun(@isempty, msgs);
    
    if any(ind)
        % Create a matrix containing alternatingly the ids and messages.
        ids = get(pjob.Tasks(ind), {'ID'});
        msgs = msgs(ind);
        idsAndMsgs = [ids(:)'; msgs(:)'];
        errorMsgs = sprintf('Error message for task id %d: %s\n', idsAndMsgs{:});
    else
        errorMsgs = 'No task error messages.';
    end
catch err %#ok<NASGU>
    errorMsgs = 'Could not retrieve the task error messages.';
end

try
    sched = pjob.parent;
    if ismethod(sched, 'getDebugLog')
        logMsg = sprintf('Parallel job debug log:\n%s', ...
                         sched.getDebugLog(pjob));
    else
        logMsg = 'No debug log with this scheduler.';
    end
catch err %#ok<NASGU>
    logMsg = 'Could not retrieve the debug log.';
end

msg = sprintf('%s\n', stateMsg, errorMsgs, logMsg);
