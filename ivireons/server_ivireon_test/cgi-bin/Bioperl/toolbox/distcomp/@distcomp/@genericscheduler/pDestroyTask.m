function pDestroyTask(obj, task)
; %#ok Undocumented
%pDestroyTask allow scheduler to kill task
%
%  pDestroyTask(SCHEDULER, TASK)

%  Copyright 2008-2010 The MathWorks, Inc.

%  $Revision: 1.1.6.2 $    $Date: 2010/05/10 17:03:13 $ 

% Get the defined callback function from the object
[destroyTaskFcn, args] = pGetFunctionAndArgsFromCallback(obj, obj.DestroyTaskFcn);

% Define situations where we are NOT going to run any user function

% 1. No callback function defined
% 2. The job has not a submitted generic scheduler job
shortcutCallbackFcn = isempty(destroyTaskFcn) || ~obj.pIsSubmittedGenericSchedulerJob(task.up);

if shortcutCallbackFcn
    return
end

% Call the user supplied function
try
    feval(destroyTaskFcn, obj, task, args{:});
catch err
    warning('distcomp:genericscheduler:DestroyTaskFcnError', ...
            'The user supplied DestroyTaskFcn (%s) threw an error.\nThe nested error is:\n\n%s', ...
            obj.pFunc2Str(destroyTaskFcn), err.getReport());    
end