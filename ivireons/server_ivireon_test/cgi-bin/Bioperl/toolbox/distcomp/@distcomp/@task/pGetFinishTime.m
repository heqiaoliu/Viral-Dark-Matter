function val = pGetFinishTime(task, val)
; %#ok Undocumented
%PGETFINISHTIME A short description of the function
%
%  VAL = PGETFINISHTIME(TASK, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.5 $    $Date: 2006/06/27 22:39:17 $ 

proxyTask = task.ProxyObject;
try
    val = char(proxyTask.getFinishTime(task.UUID));
catch
	% TODO
end
