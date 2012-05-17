function val = pGetAuthorizedUsers(job, val)
; %#ok Undocumented
%pGetAuthorizedUsers Retrieve all users to perform privileged actions on
%                    this job.

%  Copyright 2009 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2009/12/22 18:51:32 $ 

proxyJob = job.ProxyObject;
try
    val = cell(proxyJob.getAuthorisedUsers(job.UUID));
catch err %#ok<NASGU>
	val = cell(1, 0);
end
