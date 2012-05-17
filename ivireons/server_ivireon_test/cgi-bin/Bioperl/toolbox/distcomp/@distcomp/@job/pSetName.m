function val = pSetName(job, val)
; %#ok Undocumented
%PSETNAME A short description of the function
%
%  VAL = PSETNAME(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.6 $    $Date: 2008/02/02 13:00:01 $ 

proxyJob = job.ProxyObject;
if ~isempty(proxyJob)
    try
        proxyJob.setName(job.UUID, dctJavaArray(java.lang.String(val)));
    catch err
        throw(distcomp.handleJavaException(job, err));
    end
end
% Do not hold anything locally
val = '';