function val = pSetMaximumNumberOfRetries(task, val)
; %#ok Undocumented
%PSETMAXIMUMNUMBEROFRETRIES Sets the maximum number of task rerun attempts
%
%  VAL = PSETMAXIMUMNUMBEROFRETRIES(TASK, VAL)

%  Copyright 2008 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2008/05/19 22:45:28 $

if val < 0
    error('distcomp:task:InvalidProperty', ...
          'MaximumNumberOfRetries must be a non-negative integer');
end

try
    if ~isempty(task.TaskInfo)
        task.TaskInfo.setMaximumNumberOfRetries(val);
    elseif task.HasProxyObject
        task.ProxyObject.setMaximumNumberOfRetries(task.UUID, val);
    end
catch err
    throw(distcomp.handleJavaException(task, err));
end    
% Do not hold anything locally
val = 0;
