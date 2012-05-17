function val = pSetCaptureCommandWindowOutput(task, val)
; %#ok Undocumented
%PSETCAPTURECOMMANDWINDOWOUTPUT A short description of the function
%
%  VAL = PSETCAPTURECOMMANDWINDOWOUTPUT(TASK, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.5 $    $Date: 2008/02/02 13:01:10 $ 

try
    if ~isempty(task.TaskInfo)
        task.TaskInfo.setCaptureCommandWindowOutput(val);
    elseif task.HasProxyObject
        task.ProxyObject.setCaptureCommandWindowOutput(task.UUID, val);
    end
catch err
    throw(distcomp.handleJavaException(task, err));
end
% Do not hold anything locally
val = 0;