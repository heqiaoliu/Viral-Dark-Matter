function val = pGetTag(job, val)
; %#ok Undocumented
%PGETTAG A short description of the function
%
%  VAL = PGETTAG(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.4 $    $Date: 2006/06/27 22:37:02 $ 

proxyJob = job.ProxyObject;
if ~isempty(proxyJob)
    try
        val = char(proxyJob.getTag(job.UUID));
    end
end