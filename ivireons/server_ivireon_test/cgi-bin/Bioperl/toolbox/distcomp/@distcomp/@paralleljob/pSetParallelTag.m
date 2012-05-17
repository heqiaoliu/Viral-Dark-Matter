function pSetParallelTag( job, val )
; %#ok Undocumented
%pSetParallelTag - set the parallel tag of a parallel job

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.4 $    $Date: 2008/02/02 13:00:49 $ 

proxyJob = job.ProxyObject;
if ~isempty(proxyJob)
   try
      proxyJob.setParallelTag(job.UUID, {val});
   catch err
      throw(distcomp.handleJavaException(job, err));
   end
end
