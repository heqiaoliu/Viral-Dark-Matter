function manager = pGetManager(job)
; %#ok Undocumented
%PGETMANAGER A short description of the function
%
%  MANAGER = PGETMANAGER(JOB)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2006/06/27 22:34:02 $ 

manager = job.up;
if isempty(manager)
    error('distcomp:job:InvalidState', 'Job seems to have lost attachment to a Scheduler');
end