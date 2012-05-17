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
proxyJob = job.ProxyObject;
if ~isempty(proxyJob)
   try
      proxyJob.setMATLABExecutionMode(job.UUID, mode);
   catch err
      throw(distcomp.handleJavaException(job, err));
   end
end