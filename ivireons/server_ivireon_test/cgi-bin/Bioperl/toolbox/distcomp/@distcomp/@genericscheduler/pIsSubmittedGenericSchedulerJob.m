function OK = pIsSubmittedGenericSchedulerJob(obj, job) %#ok<INUSL>
; %#ok Undocumented
%pIsSubmittedGenericSchedulerJob true for a submitted generic scheduler job
%

%  Copyright 2008 The MathWorks, Inc.

%  $Revision: 1.1.6.2 $    $Date: 2008/10/02 18:40:30 $ 

data = job.pGetJobSchedulerData;
state = job.pGetStateFromStorage;
% Is the job actually a generic job?
try
    OK = ~isempty(data) && strcmp(data.type, 'generic') && distcomp.jobStateIsAfter(state, 'pending');
catch err %#ok<NASGU>
    OK = false;
end
