function val = pGetLogLevel(task, val)
; %#ok Undocumented
%PGETLOGLEVEL The level at which the task execution will be logged
%
%  VAL = PGETLOGLEVEL(TASK, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.6.2 $    $Date: 2008/02/02 13:01:04 $ 

proxyTask = task.ProxyObject;
try
    val = proxyTask.getLogLevel(task.UUID);
catch err
    throw(distcomp.handleJavaException(task, err));
end
