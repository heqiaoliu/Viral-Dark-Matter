function pPreTaskEvaluate(task)
; %#ok Undocumented
%pPreTaskEvaluate 
%
%  pPreTaskEvaluate(TASK)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:35:43 $ 

try
    set(task, ...
        'StartTime', char(java.util.Date), ...
        'State', 'running');
catch
end