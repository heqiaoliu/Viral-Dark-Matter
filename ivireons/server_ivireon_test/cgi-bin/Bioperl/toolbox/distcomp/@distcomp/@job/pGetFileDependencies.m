function val = pGetFileDependencies(job, val)
; %#ok Undocumented
%PGETTIMEOUT A short description of the function
%
%  VAL = PGETTIMEOUT(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.4 $    $Date: 2006/06/27 22:36:48 $ 

proxyJob = job.ProxyObject;
if ~isempty(proxyJob)
    try
        val = cell(proxyJob.getFileDepPathList(job.UUID));
    end
end