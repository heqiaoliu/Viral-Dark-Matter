function pSetTaskInfo(task, val)
; %#ok Undocumented
%pSetTaskInfo A short description of the function
%
%  pSetTaskInfo(TASK, VAL)

%  Copyright 2006 The MathWorks, Inc.

%  $Revision: 1.1.6.2 $    $Date: 2007/09/14 16:03:07 $ 

task.TaskInfo = val;
task.TaskInfoCache = {};

