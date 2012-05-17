function val = pGetError(task, val)
; %#ok Undocumented
%PGETERROR A short description of the function
%
%  VAL = PGETERROR(TASK, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2006/09/27 00:21:49 $ 

proxyTask = task.ProxyObject;
try
    errorBytes = proxyTask.getErrorStruct(task.UUID);
    if ~isempty(errorBytes)
        val = distcompdeserialize(errorBytes);
    end
catch
end
