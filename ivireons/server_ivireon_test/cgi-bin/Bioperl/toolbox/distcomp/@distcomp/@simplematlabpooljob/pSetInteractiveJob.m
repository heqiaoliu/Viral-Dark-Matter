function pSetInteractiveJob(job, state)
; %#ok Undocumented
%pSetInteractiveJob 
%
%  pSetInteractiveJob(JOB, STATE)

%  Copyright 2008 The MathWorks, Inc.


if state
    mode = 1; 
else
    mode = 0; 
end

serializer = job.Serializer;
if ~isempty(serializer)
    serializer.putField(job, 'execmode', mode)
end
