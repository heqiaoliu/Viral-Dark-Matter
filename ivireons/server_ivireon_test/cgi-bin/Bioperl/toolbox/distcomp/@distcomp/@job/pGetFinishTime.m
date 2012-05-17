function val = pGetFinishTime(job, val)
; %#ok Undocumented
%PGETFINISHTIME A short description of the function
%
%  VAL = PGETFINISHTIME(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.5 $    $Date: 2006/06/27 22:36:49 $ 

proxyJob = job.ProxyObject;
if ~isempty(proxyJob)
    try
        val = char(proxyJob.getFinishTime(job.UUID));
    end
end
