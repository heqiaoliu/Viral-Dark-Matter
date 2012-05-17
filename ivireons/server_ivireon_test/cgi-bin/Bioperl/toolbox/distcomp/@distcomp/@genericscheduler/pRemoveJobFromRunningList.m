function pRemoveJobFromRunningList(obj, job)
; %#ok Undocumented
%pRemoveJobFromRunningList 
%

%  Copyright 2008 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2008/05/19 22:45:05 $ 

obj.JobsWithGetJobStateFcnRunning = setdiff(obj.JobsWithGetJobStateFcnRunning, job);