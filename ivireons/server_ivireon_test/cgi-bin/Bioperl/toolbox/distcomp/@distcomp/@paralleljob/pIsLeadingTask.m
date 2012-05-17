function val = pIsLeadingTask( job, task )
; %#ok Undocumented
%pIsLeadingTask - is this task within a parallel job the "leading" one

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.4 $    $Date: 2008/02/02 13:00:45 $ 

% The job manager decides which task is "leading" at submission time.

proxyJob = job.ProxyObject;
if ~isempty(proxyJob)
    try
        val = logical( proxyJob.isLeadingTask( job.UUID, task.UUID ) );
    catch err
        throw(distcomp.handleJavaException(job, err));
    end
end
