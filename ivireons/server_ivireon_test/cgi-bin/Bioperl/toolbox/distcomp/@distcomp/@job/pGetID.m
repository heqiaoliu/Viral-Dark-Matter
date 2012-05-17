function val = pGetName(job, val)
; %#ok Undocumented
%PGETID A short description of the function
%
%  VAL = PGETID(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2006/06/27 22:36:50 $ 

proxyJob = job.ProxyObject;
if ~isempty(proxyJob)
    try
        val = proxyJob.getNum(job.UUID);
    end
end