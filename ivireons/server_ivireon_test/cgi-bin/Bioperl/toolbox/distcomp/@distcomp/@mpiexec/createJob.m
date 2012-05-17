function nojob = createJob( mpiexec, varargin ) %#ok<INUSD,STOUT>
%createJob - create a standard job
%   This is not supported on an mpiexec scheduler
   
%  Copyright 2005-2010 The MathWorks, Inc.

%  $Revision: 1.1.10.2 $    $Date: 2010/03/22 03:41:54 $ 

    error( 'distcomp:mpiexec:unsupported', ...
           'MPIEXEC scheduler only supports parallel jobs: please use "createParallelJob" or "createMatlabPoolJob".' );
        
