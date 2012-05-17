function val = pGetStartTime(job, val)
; %#ok Undocumented
%PGETSTARTTIME A short description of the function
%
%  VAL = PGETSTARTTIME(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.5 $    $Date: 2006/06/27 22:36:59 $ 

proxyJob = job.ProxyObject;
if ~isempty(proxyJob)
    try
        val = char(proxyJob.getStartTime(job.UUID));
    end
end
