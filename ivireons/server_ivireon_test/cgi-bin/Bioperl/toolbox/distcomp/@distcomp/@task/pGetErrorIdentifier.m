function val = pGetErrorIdentifier(task, val)
; %#ok Undocumented
%pGetErrorID A short description of the function
%
%  VAL = PGETERRORMESSAGE(TASK, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.4 $    $Date: 2006/06/27 22:39:15 $ 

proxyTask = task.ProxyObject;
try
    val = char(proxyTask.getErrorIdentifier(task.UUID));
catch
	% TODO
end
