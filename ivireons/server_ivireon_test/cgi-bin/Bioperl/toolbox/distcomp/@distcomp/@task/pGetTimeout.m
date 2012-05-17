function val = pGetTimeout(task, val)
; %#ok Undocumented
%PGETTIMEOUT A short description of the function
%
%  VAL = PGETTIMEOUT(TASK, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.4 $    $Date: 2006/06/27 22:39:28 $ 

proxyTask = task.ProxyObject;
try
    lVal = proxyTask.getTimeout(task.UUID); 
    % Check if the number is INTMAX for int64
    if isequal(lVal, intmax('int64'))
        val = Inf;
    else
        val = double(lVal) / 1000; % convert to seconds
    end
catch
	% TODO
end
