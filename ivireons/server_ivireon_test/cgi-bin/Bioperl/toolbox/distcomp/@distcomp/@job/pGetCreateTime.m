function val = pGetCreateTime(job, val)
; %#ok Undocumented
%PGETCREATETIME A short description of the function
%
%  VAL = PGETCREATETIME(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.5 $    $Date: 2006/06/27 22:36:47 $ 

proxyJob = job.ProxyObject;
if ~isempty(proxyJob)
    try
        val = char(proxyJob.getCreateTime(job.UUID));
    end
end