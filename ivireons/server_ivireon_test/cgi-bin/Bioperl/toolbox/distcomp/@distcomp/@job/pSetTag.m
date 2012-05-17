function val = pSetTag(job, val)
; %#ok Undocumented
%PSETTAG A short description of the function
%
%  VAL = PSETTAG(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.6 $    $Date: 2008/02/02 13:00:05 $ 

proxyJob = job.ProxyObject;
if ~isempty(proxyJob)
    try
        proxyJob.setTag(job.UUID, dctJavaArray(java.lang.String(val)));
    catch err
        throw(distcomp.handleJavaException(job, err));
    end
end
% Do not hold anything locally
val = '';