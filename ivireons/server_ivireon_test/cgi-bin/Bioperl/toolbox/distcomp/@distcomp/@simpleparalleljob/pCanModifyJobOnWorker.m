function x = pCanModifyJobOnWorker( job )
; %#ok Undocumented
%pCanModifyJobOnWorker - are we currently allowed to modify the job
%    This function should be overridden if a particular job subtype knows a
%    reason why they should not be allowed to modify the job on the worker.

%  Copyright 2000-2006 The MathWorks, Inc.
%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:38:57 $ 

% A parallel job can only modify the job on the worker if we're lab 1.
x = ( labindex == 1 );
