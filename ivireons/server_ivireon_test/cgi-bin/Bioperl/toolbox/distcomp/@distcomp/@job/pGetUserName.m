function val = pGetName(job, val)
; %#ok Undocumented
%PGETUSERNAME A short description of the function
%
%  VAL = PGETUSERNAME(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.4 $    $Date: 2006/06/27 22:37:05 $ 

proxyJob = job.ProxyObject;
try
    val = char(proxyJob.getUserName(job.UUID));
catch
	% TODO
end
