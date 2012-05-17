function val = pGetNumberOfReruns(task, val)
; %#ok Undocumented
%PGETNUMBEROFRERUNS Retrieves the  number of task reruns
%
%  VAL = PGETNUMBEROFRERUNS(TASK, VAL)

%  Copyright 2008 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2008/05/19 22:45:26 $

try    
    if task.HasProxyObject
        val = numel(pGetRerunInfo(task));
    end
catch
    % TODO
end
