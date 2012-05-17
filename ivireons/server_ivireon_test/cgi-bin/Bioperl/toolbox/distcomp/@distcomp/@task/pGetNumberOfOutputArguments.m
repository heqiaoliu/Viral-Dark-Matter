function val = pGetNumberOfOutputArguments(task, val)
; %#ok Undocumented
%PGETNUMBEROFOUTPUTARGUMENTS A short description of the function
%
%  VAL = PGETNUMBEROFOUTPUTARGUMENTS(TASK, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.4 $    $Date: 2006/06/27 22:39:22 $ 

proxyTask = task.ProxyObject;
try
    val = proxyTask.getNumOutArgs(task.UUID);
catch
	% TODO
end
