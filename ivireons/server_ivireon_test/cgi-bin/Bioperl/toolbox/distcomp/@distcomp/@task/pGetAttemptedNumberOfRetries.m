function val = pGetAttemptedNumberOfRetries(task, val)
; %#ok Undocumented
%PGETATTEMPTEDNUMBEROFRETRIES Retrieves the number of task rerun attempts
%
%  VAL = PGETATTEMPTEDNUMBEROFRETRIES(TASK, VAL)

%  Copyright 2008 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2008/05/19 22:45:22 $

try    
    if task.HasProxyObject
        val = task.ProxyObject.getAttemptedNumberOfRetries(task.UUID);
    end
catch err
    % Do not throw any errors.
end
