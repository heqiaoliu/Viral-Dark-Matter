function val = pGetCaptureCommandWindowOutput(task, val)
; %#ok Undocumented
%PGETCAPTURECOMMANDWINDOWOUTPUT A short description of the function
%
%  VAL = PGETCAPTURECOMMANDWINDOWOUTPUT(TASK, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.4 $    $Date: 2006/06/27 22:39:12 $ 

proxyTask = task.ProxyObject;
try
    val = proxyTask.getCaptureCommandWindowOutput(task.UUID);
catch
	% TODO
end
