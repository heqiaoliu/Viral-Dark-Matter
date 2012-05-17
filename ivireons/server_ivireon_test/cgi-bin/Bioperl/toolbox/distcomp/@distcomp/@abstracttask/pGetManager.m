function manager = pGetManager(task)
; %#ok Undocumented
%PGETMANAGER A short description of the function
%
%  MANAGER = PGETMANAGER(TASK)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:35:35 $ 

manager = task.up.up;
if isempty(manager)
    error('distcomp:task:InvalidState', 'Task seems to have lost attachment to a Scheduler');
end