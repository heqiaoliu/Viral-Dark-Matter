function pDestroyJob(obj, job)
; %#ok Undocumented
%pDestroyJob allow scheduler to kill job 
%
%  pDestroyJob(SCHEDULER, JOB)

%  Copyright 2008-2010 The MathWorks, Inc.

%  $Revision: 1.1.6.2 $    $Date: 2010/05/10 17:03:12 $ 

% Get the defined callback function from the object
[destroyJobFcn, args] = pGetFunctionAndArgsFromCallback(obj, obj.DestroyJobFcn);

% Define situations where we are NOT going to run any user function

% 1. No callback function defined
% 2. The job has not a submitted generic scheduler job
shortcutCallbackFcn = isempty(destroyJobFcn) || ~obj.pIsSubmittedGenericSchedulerJob(job);

if shortcutCallbackFcn
    return
end

% Call the user supplied function
try
    feval(destroyJobFcn, obj, job, args{:});
catch err
    warning('distcomp:genericscheduler:DestroyJobFcnError', ...
            'The user supplied DestroyJobFcn (%s) threw an error.\nThe nested error is:\n\n%s', ...
            obj.pFunc2Str(destroyJobFcn), err.getReport());    
end