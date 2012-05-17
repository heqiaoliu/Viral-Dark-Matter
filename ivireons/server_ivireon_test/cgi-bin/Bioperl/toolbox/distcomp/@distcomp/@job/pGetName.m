function val = pGetName(job, val)
; %#ok Undocumented
%PGETNAME A short description of the function
%
%  VAL = PGETNAME(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.4 $    $Date: 2006/06/27 22:36:55 $ 

proxyJob = job.ProxyObject;
if ~isempty(proxyJob)
    try
        val = char(proxyJob.getName(job.UUID));
    end
end