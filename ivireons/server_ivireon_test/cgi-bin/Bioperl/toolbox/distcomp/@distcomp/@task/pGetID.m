function val = pGetName(task, val)
; %#ok Undocumented
%PGETID A short description of the function
%
%  VAL = PGETID(TASK, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2006/06/27 22:39:19 $ 

proxyTask = task.ProxyObject;
if ~isempty(proxyTask)
    try
        val = proxyTask.getNum(task.UUID);
    end
end