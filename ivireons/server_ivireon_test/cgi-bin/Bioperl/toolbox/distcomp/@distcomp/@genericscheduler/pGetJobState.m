function state = pGetJobState(obj, job, state)
; %#ok Undocumented
%pGetJobState - deferred call to ask the scheduler for state information
%
%  STATE = pGetJobState(SCHEDULER, JOB, STATE)

%  Copyright 2008-2010 The MathWorks, Inc.

%  $Revision: 1.1.6.3 $    $Date: 2010/05/10 17:03:14 $ 

persistent validJobStates
if isempty(validJobStates)
    % Get the defined execution states from the enum
    type = findtype('distcomp.jobexecutionstate');
    validJobStates = type.Strings;
end

% Get the defined callback function from the object
[getJobStateFcn, args] = pGetFunctionAndArgsFromCallback(obj, obj.GetJobStateFcn);

% Define situations where we are NOT going to run any user function

% 1. No callback function defined
% 2. If the job is still pending then we have not called submit yet
% 3. If we are already in the user function for this job
% 4. The job has not a submitted generic scheduler job
shortcutCallbackFcn = isempty(getJobStateFcn) || ...
                        strcmp(state, 'pending') || ...
                        ismember(job, obj.JobsWithGetJobStateFcnRunning) || ...
                        ~obj.pIsSubmittedGenericSchedulerJob(job);

if shortcutCallbackFcn 
    % Return with the state that has been supplied from storage, without calling
    % any user supplied function.
    return
end

% If we are going to run the user function we need to ensure we don't re-enter
% the user code, so store the job handle in JobsWithGetJobStateFcnRunning and
% make sure we remove it at the end
obj.JobsWithGetJobStateFcnRunning(end+1) = job;
% NOTE - this has to re-direct to a method call because only methods can access
% the JobsWithGetJobStateFcnRunning property.
cleanup = onCleanup(@() pRemoveJobFromRunningList(obj, job));

% Having done the above it is safe to call the user function, and for the user to
% CTRL-C out of their code, as the cleanup will ensure that the job is removed
try
    userSuppliedState = feval(getJobStateFcn, obj, job, state, args{:});
catch err
    warning('distcomp:genericscheduler:GetJobStateFcnError', ...
            'The user supplied GetJobStateFcn (%s) threw an error.\nThe nested error is:\n\n%s', ...
            obj.pFunc2Str(getJobStateFcn), err.getReport());
    userSuppliedState = state;
end

% Check that the user has returned a string
if ~(ischar(userSuppliedState) && isvector(userSuppliedState) && size(userSuppliedState, 1) == 1)
    warning('distcomp:genericscheduler:InvalidState', ...
            'The user supplied GetJobStateFcn (%s) must return a string.', obj.pFunc2Str(getJobStateFcn) );
    userSuppliedState = state;
else
    % Check that the user returned string value is a valid state
    if ~ismember(userSuppliedState, validJobStates)
        warning('distcomp:genericscheduler:InvalidState', ...
                ['The user supplied GetJobStateFcn (%s) returned an invalid state string (%s).\n' ...
                 'See the documentation on generic schedulers for a list of valid states.'], ...
                 obj.pFunc2Str(getJobStateFcn), userSuppliedState);
        userSuppliedState = state;
    end
end

% Return what the user asked us to return
state = userSuppliedState;

% Set the state on the job if the scheduler reports that it
% is in the finished or failed state.
if strcmpi(state, 'finished') || strcmpi(state, 'failed')
    job.pSetState(state);
end
