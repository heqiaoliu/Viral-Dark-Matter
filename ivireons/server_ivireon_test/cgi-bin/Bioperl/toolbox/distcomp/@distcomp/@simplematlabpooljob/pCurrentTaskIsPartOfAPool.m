function isPoolTask = pCurrentTaskIsPartOfAPool(job)
; %#ok Undocumented
%pCurrentTaskIsPartOfAPool 

% This function will tell the caller if this particular instance of the job on
% a worker is a pool task or not.

% Copyright 2008 The MathWorks, Inc.

% $Revision: 1.1.6.1 $    $Date: 2008/08/08 12:51:42 $

isPoolTask = job.IsPoolTask;
