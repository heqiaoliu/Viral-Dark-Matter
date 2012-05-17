function OK = pCancelJob( obj, job )
; %#ok Undocumented
%pCancelJob - cancel the job 

%  Copyright 2006-2007 The MathWorks, Inc.

%  $Revision: 1.1.6.2 $    $Date: 2007/09/14 16:02:46 $

OK = pCancelOrDestroyJob(obj, job, @cancel);