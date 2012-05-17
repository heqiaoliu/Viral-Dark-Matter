function val = pGetParallelInfo( job )
; %#ok Undocumented
%pGetParallelInfo - return all the parallel info for a parallel job

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.4 $    $Date: 2008/02/02 13:00:42 $ 

% Return the parallel job info object.

proxyJob = job.ProxyObject;
if ~isempty(proxyJob)
    try
        val = proxyJob.getParallelJobSetupInfo( job.UUID );
        val = val(1);
    catch err
        throw(distcomp.handleJavaException(job, err));
    end
end
