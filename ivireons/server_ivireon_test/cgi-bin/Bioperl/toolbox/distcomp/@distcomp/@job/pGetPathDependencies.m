function val = pGetPathDependencies(job, val)
; %#ok Undocumented
%pGetPathDependencies A short description of the function
%
%  VAL = pGetPathDependencies(JOB, VAL)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:36:57 $ 

proxyJob = job.ProxyObject;
if ~isempty(proxyJob)
    try
        val = cell(proxyJob.getPathList(job.UUID));
    end
end