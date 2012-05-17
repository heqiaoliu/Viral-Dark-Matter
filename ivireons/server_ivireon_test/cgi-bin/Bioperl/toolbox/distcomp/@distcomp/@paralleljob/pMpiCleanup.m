function pMpiCleanup( job )
; %#ok Undocumented
%pMpiCleanup - clean up after an MPI job

% Copyright 2004-2007 The MathWorks, Inc.

% $Revision: 1.1.10.6 $ $Date: 2008/08/26 18:13:34 $

% Perform error detection
mpigateway( 'setidle' );
mpigateway( 'setrunning' );

% Call to labBarrier ensures that workers will get stuck in here until
% everyone has finished. This is actually desirable because if we don't
% ensure that all workers clean up correctly, then theres a possibility that
% a worker could complete a task, and not get cleaned up
labBarrier;

% This is the end of a parallel session
mpiParallelSessionEnding;

mpiFinalize;
