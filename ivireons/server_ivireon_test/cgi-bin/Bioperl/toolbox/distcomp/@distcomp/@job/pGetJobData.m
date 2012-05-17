function val = pGetJobData(job, val) %#ok<INUSD>
; %#ok Undocumented
%PGETJOBDATA A short description of the function
%
%  VAL = PGETJOBDATA(JOB, VAL)

%  Copyright 2000-2008 The MathWorks, Inc.

%  $Revision: 1.1.8.8 $    $Date: 2008/09/13 06:51:31 $ 

import com.mathworks.toolbox.distcomp.workunit.WorkUnit;

val = [];
proxyJob = job.ProxyObject;
if ~isempty(proxyJob)
    try
        % Only use the jobData cache if the job is not pending - since the
        % JobData cannot change after this
        USE_CACHE = double(proxyJob.getState(job.UUID)) > WorkUnit.PENDING_STATE;
        % If we are using the cache and it has something in it then use it
        if USE_CACHE && ~isempty(job.JobDataCache) 
            val = job.JobDataCache;
        else
            % Call the getJobScopeData with a null proxy as this will be
            % sent for us
            dataItem = proxyJob.getJobScopeData(job.UUID);
            data = dataItem(1).getData;
            if ~isempty(data) && data.limit > 0
                val = distcompdeserialize(data);
            end
            dataItem(1).delete();
            % Make sure to cache the value if we have been ased to
            if USE_CACHE
                job.JobDataCache = val;
            end
        end
    catch err
        distcomp.handleGetLargeDataError(job, err);
    end
end
