function val = pSetRestartWorker(job, val)
; %#ok Undocumented
%PSETRESTARTWORKER A short description of the function
%
%  VAL = PSETRESTARTWORKER(OBJ, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.5 $    $Date: 2008/02/02 13:00:04 $ 

proxyJob = job.ProxyObject;
if ~isempty(proxyJob)
    try
        proxyJob.setRestartWorker(job.UUID, val);
    catch err
        throw(distcomp.handleJavaException(job, err));
    end
end
% Do not hold anything locally
val = false;