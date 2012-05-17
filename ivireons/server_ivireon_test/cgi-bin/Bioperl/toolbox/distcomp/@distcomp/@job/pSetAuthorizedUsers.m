function val = pSetAuthorizedUsers(job, val)
; %#ok Undocumented
%pSetAuthorizedUsers Change the users authorized to perform privileged
%                    actions on the job.

%  Copyright 2009 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2009/12/22 18:51:34 $ 

for i = 1:numel(job)
    thisJob = job(i);
    thisProxy = thisJob.ProxyObject;
    if ~isempty(thisProxy)
        % The following check must be in here because creation of a distcomp.job
        % calls this method with an empty value, but must not error.
        if ~iscell(val)
            error('distcomp:job:InvalidProperty', 'User list must be a cell');
        end
        % Need to ensure the cell array of strings is 1 x nStrings
        % otherwise the java layer gets upset
        val = reshape(val, 1, numel(val));
        try
            thisProxy.setAuthorisedUsers(thisJob.UUID, val);
        catch err
            throw(distcomp.handleJavaException(thisJob, err));
        end
    end
end
% Do not hold anything locally
val = '';
