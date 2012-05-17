function val = pGetRestartWorker(job, val)
; %#ok Undocumented
%PGETRESTARTWORKER A short description of the function
%
%  VAL = PGETRESTARTWORKER(OBJ, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.5 $    $Date: 2006/12/06 01:35:00 $ 

proxyJob = job.ProxyObject;
if ~isempty(proxyJob)
    try
        val = proxyJob.isRestartWorker(job.UUID);
    end
end
