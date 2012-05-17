function val = pGetSubmitTime(job, val)
; %#ok Undocumented
%pGetSubmitTime A short description of the function
%
%  VAL = pGetSubmitTime(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.5 $    $Date: 2006/06/27 22:37:01 $ 

proxyJob = job.ProxyObject;
if ~isempty(proxyJob)
    try
        val = char(proxyJob.getSubmitTime(job.UUID));
    end
end
