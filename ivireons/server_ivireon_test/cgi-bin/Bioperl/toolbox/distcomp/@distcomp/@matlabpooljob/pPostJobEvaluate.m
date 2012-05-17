function pPostJobEvaluate(job)
; %#ok Undocumented
%pPostJobEvaluate

% Copyright 2007-2009 The MathWorks, Inc.

% $Revision: 1.1.6.6 $    $Date: 2009/12/22 18:51:48 $

%dctRegisterMpiFunctions('mwmpi');

task = getCurrentTask;
if ~( isempty( task.ErrorMessage ) && job.PoolShutdownSuccessful)
    % This quits MATLAB hard 
    com.mathworks.toolbox.distcomp.nativedmatlab.ProcessManipulation.abortMATLAB();
end

job.pMpiCleanup;    
