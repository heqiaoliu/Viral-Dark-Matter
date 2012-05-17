function val = pSetLogLevel(task, val)
; %#ok Undocumented
%PSETLOGLEVEL Set the level at which task execution will be logged
%
%  VAL = PSETLOGLEVEL(TASK, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2008/02/02 13:01:15 $ 

if val < 0
    error('distcomp:task:InvalidProperty', 'LogLevel must be a non-negative integer');
end

try
    if ~isempty(task.TaskInfo)
        task.TaskInfo.setLogLevel(val);
    elseif task.HasProxyObject
        task.ProxyObject.setLogLevel(task.UUID, val);
    end
catch err
    throw(distcomp.handleJavaException(task, err));
end    
% Do not hold anything locally
val = 0;