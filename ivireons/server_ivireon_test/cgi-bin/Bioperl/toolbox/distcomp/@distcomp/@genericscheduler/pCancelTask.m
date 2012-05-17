function OK = pCancelTask(obj, task)
; %#ok Undocumented
%pCancelTask allow scheduler to cancel task
%
%  OK = pCancelTask(SCHEDULER, TASK)
%
% The return argument OK is used to indicate if the function managed to
% cancel the task or not - this will be used to write to the state of
% the task.

%  Copyright 2008-2010 The MathWorks, Inc.

%  $Revision: 1.1.6.2 $    $Date: 2010/05/10 17:03:11 $ 

% Get the defined callback function from the object
[cancelTaskFcn, args] = pGetFunctionAndArgsFromCallback(obj, obj.CancelTaskFcn);

% Define situations where we are NOT going to run any user function

% 1. No callback function defined
% 2. The job has not a submitted generic scheduler job
shortcutCallbackFcn = isempty(cancelTaskFcn) || ~obj.pIsSubmittedGenericSchedulerJob(task.up);

if shortcutCallbackFcn
    OK = true;
    return
end

% Call the user supplied function
try
    OK = feval(cancelTaskFcn, obj, task, args{:});
catch err
    OK = false;
    warning('distcomp:genericscheduler:CancelTaskFcnError', ...
            'The user supplied CancelTaskFcn (%s) threw an error.\nThe nested error is:\n\n%s', ...
            obj.pFunc2Str(cancelTaskFcn), err.getReport());    
end
% Check that the user has returned a logical
if ~(islogical(OK) && numel(OK) == 1)
    warning('distcomp:genericscheduler:InvalidState', ...
            'The user supplied CancelTaskFcn (%s) must return a scalar logical.', obj.pFunc2Str(cancelTaskFcn) );
    OK = false;
end