function OK = pCancelJob(obj, job)
; %#ok Undocumented
%pCancelJob allow scheduler to cancel job 
%
%  OK = pCancelJob(SCHEDULER, JOB)
%
% The return argument OK is used to indicate if the function managed to
% cancel the job or not - this will be used to write to the state of
% the job.

%  Copyright 2008-2010 The MathWorks, Inc.

%  $Revision: 1.1.6.2 $    $Date: 2010/05/10 17:03:10 $ 

% Get the defined callback function from the object
[cancelJobFcn, args] = pGetFunctionAndArgsFromCallback(obj, obj.CancelJobFcn);

% Define situations where we are NOT going to run any user function

% 1. No callback function defined
% 2. The job has not a submitted generic scheduler job
shortcutCallbackFcn = isempty(cancelJobFcn) || ~obj.pIsSubmittedGenericSchedulerJob(job);

if shortcutCallbackFcn
    OK = true;
    return
end

% Call the user supplied function
try
    OK = feval(cancelJobFcn, obj, job, args{:});
catch err
    OK = false;
    warning('distcomp:genericscheduler:CancelJobFcnError', ...
            'The user supplied CancelJobFcn (%s) threw an error.\nThe nested error is:\n\n%s', ...
            obj.pFunc2Str(cancelJobFcn), err.getReport());    
end
% Check that the user has returned a logical
if ~(islogical(OK) && numel(OK) == 1)
    warning('distcomp:genericscheduler:InvalidState', ...
            'The user supplied CancelJobFcn (%s) must return a scalar logical.', obj.pFunc2Str(cancelJobFcn) );
    OK = false;
end