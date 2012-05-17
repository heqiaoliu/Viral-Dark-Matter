function val = pGetMaximumNumberOfRetries(task, val)
; %#ok Undocumented
%PGETMAXIMUMNUMBEROFRETRIES Retrieves the maximum number of task rerun attempts
%
%  VAL = PGETMAXIMUMNUMBEROFRETRIES(TASK, VAL)

%  Copyright 2008 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2008/05/19 22:45:25 $

try
    if task.HasProxyObject
        val = task.ProxyObject.getMaximumNumberOfRetries(task.UUID);
    end
catch err
    % Do not throw any errors.
end
