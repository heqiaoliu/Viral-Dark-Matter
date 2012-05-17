function val = pGetLogOutput(task, val)
; %#ok Undocumented
%PGETLOGOUTPUT Get the logged output from task execution
%
%  VAL = PGETLOGOUTPUT(TASK, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.6.2 $    $Date: 2008/02/02 13:01:06 $ 

proxyTask = task.ProxyObject;
try
    val = char(proxyTask.getLogOutput(task.UUID));
catch err
    throw(distcomp.handleJavaException(task, err));
end
