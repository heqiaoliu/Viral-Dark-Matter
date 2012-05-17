function isInteractive = pIsInteractivePool(job)
; %#ok Undocumented
%pIsInteractivePool 

% This function will tell the caller if this particular instance of the job is
% expecting to run an interactive or batch type matlabpool

% Copyright 2008 The MathWorks, Inc.

% $Revision: 1.1.6.1 $    $Date: 2008/12/29 01:48:12 $

isInteractive = job.Serializer.getField(job, 'execmode') == 1;
