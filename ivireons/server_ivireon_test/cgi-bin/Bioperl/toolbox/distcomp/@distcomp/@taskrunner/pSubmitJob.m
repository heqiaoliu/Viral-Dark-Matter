function pSubmitJob(scheduler, job) %#ok<INUSD>
; %#ok Undocumented
%pSubmitJob Default submit behaviour for schedulers that haven't overridden this method
%
%  pSubmitJob(SCHEDULER, JOB)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.6.2 $    $Date: 2008/01/10 21:10:10 $ 

error('distcomp:taskrunner:UnableToSubmit', ...
      'This scheduler type does not support the ability to submit new jobs on the worker');

