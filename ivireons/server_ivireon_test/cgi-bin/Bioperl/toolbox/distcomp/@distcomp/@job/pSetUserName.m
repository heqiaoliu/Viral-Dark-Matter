function val = pSetUserName(job, val)
; %#ok Undocumented
%PSETUSERNAME Change the owner of a job by resetting its username
%
%  PSETUSERNAME(JOB, VAL)

%  Copyright 2009 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2009/12/22 18:51:35 $ 

for i = 1:numel(job)
    thisJob = job(i);
    thisProxy = thisJob.ProxyObject;
    if ~isempty(thisProxy)
        % The following check must be in here because creation of a distcomp.job
        % calls this method with an empty value, but must not error.
        if isempty(val)
            error('distcomp:job:InvalidProperty', 'UserName must not be empty');   
        end
        try
            thisProxy.setUserName(thisJob.UUID, dctJavaArray(java.lang.String(val)));
        catch err
            throw(distcomp.handleJavaException(thisJob, err));
        end
    end
end
% Do not hold anything locally
val = '';
