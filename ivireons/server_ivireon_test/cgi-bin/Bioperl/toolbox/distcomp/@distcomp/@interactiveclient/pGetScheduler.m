function sched = pGetScheduler(obj, config) %#ok Never use obj.
; %#ok Undocumented
% Find the scheduler we are going to submit the parallel job to. Since
% this is found with a configuration there is no reason that this can't
% be mpiexec, LSF, or CCS.

%   Copyright 2006-2008 The MathWorks, Inc.

try
    sched = distcomp.pGetScheduler(config);
catch err
    if strcmp( err.identifier, 'distcomp:configuration:NoScheduler' )
        % rethrow the exception with a different id. This is for backwards
        % compatibility - this method previously threw the error with the
        % 'interactive' component.
        throw( MException( 'distcomp:interactive:NoScheduler', '%s', err.message ) );
    else
        rethrow(err);
    end
end    
