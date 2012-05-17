function pSubmitJob(mpiexec, job)
; %#ok Undocumented
%pSubmitJob - submit a job for mpiexec
%
%  pSubmitJob(SCHEDULER, JOB)

%  Copyright 2005-2006 The MathWorks, Inc.
%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:38:12 $ 

% mpiexec cannot handle a non-shared filesystem
if ~isa( job, 'distcomp.simpleparalleljob' )
    error( 'distcomp:mpiexec:notsupported', ...
           'MPIEXEC scheduler only supports parallel jobs' );
end
