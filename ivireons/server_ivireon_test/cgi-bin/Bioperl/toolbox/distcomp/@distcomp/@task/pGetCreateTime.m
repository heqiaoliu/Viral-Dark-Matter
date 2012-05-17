function val = pGetCreateTime(task, val)
; %#ok Undocumented
%PGETSTARTTIME A short description of the function
%
%  VAL = PGETSTARTTIME(TASK, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.5 $    $Date: 2006/06/27 22:39:14 $ 

proxyTask = task.ProxyObject;
try
    val = char(proxyTask.getCreateTime(task.UUID));
catch
	% TODO
end
